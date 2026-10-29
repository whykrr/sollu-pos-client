# Milestone R2 Review and Adversarial Audit Report

> **Reviewer:** `reviewer_r2_1` (teamwork_preview_reviewer)  
> **Roles:** Reviewer, Critic  
> **Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
> **Date:** 2026-10-22  
> **Verdict:** **REQUEST_CHANGES**

---

## Review Summary

**Verdict: REQUEST_CHANGES**

Milestone R2 has successfully delivered the vast majority of its architectural requirements: Unified Item Pattern (single products receiving a default `ProductItem` with `variant_combination = null`), complete decoupling of inventory balances when `track_inventory = false`, model and service level enforcement of the causality invariant (`sellable = false => is_show = false`), removal of tenant isolation leaks (`Business::first()` removed from `ModifierGroupController`), route feature gating via `plan.feature:...` middleware, and expansion of `MasterDataSyncService` to export `product_items` and `product_item_variant_group_options`.

However, adversarial stress-testing identified **two critical-to-major defects in the deletion lifecycle** that must be resolved prior to proceeding to Milestone R3:
1. **Critical:** In `ProductService::deleteProduct`, calling `$product->productItems()->delete()` *before* `$product->inventoryItems()->update(['inventory_items.is_active' => false])` causes the `HasManyThrough` query to match zero rows due to Eloquent soft-delete scopes. As a result, **linked `InventoryItem` records are never deactivated** and remain orphaned and active.
2. **Major:** In `ServiceProductController::destroy`, the controller calls `$service->delete()` directly instead of delegating to `ProductService::deleteService($service)`, leaving child `product_items` active and bypassing audit logging.

---

## 1. Observation

### 1.1 Direct Test Suite Verification Commands

All requested verification commands were executed in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`:

1. **ProductManagementTest:**
   ```bash
   php artisan test --compact --filter=ProductManagementTest
   ```
   **Output:**
   ```
   ......
   Tests:    6 passed (64 assertions)
   Duration: 4.06s
   ```

2. **ProductFeatureGatingTest:**
   ```bash
   php artisan test --compact --filter=ProductFeatureGatingTest
   ```
   **Output:**
   ```
   ......
   Tests:    6 passed (18 assertions)
   Duration: 37.10s
   ```

3. **MasterDataSyncTest:**
   ```bash
   php artisan test --compact tests/Feature/API/MasterDataSyncTest.php
   ```
   **Output:**
   ```
   .
   Tests:    1 passed (19 assertions)
   Duration: 2.56s
   ```

4. **ProductControllerTest:**
   ```bash
   php artisan test --compact --filter=ProductControllerTest
   ```
   **Output:**
   ```
   .................................
   Tests:    33 passed (227 assertions)
   Duration: 13.70s
   ```

5. **ServiceProductControllerTest:**
   ```bash
   php artisan test --compact --filter=ServiceProductControllerTest
   ```
   **Output:**
   ```
   .............
   Tests:    13 passed (58 assertions)
   Duration: 7.28s
   ```

6. **Pint Code Formatter:**
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
   **Output:**
   ```json
   {"tool":"pint","result":"passed"}
   ```

---

### 1.2 Code Inspection Observations & Defects Found

#### Finding 1 (Critical): Soft-Delete Scope Invalidation in `ProductService::deleteProduct`
- **Location:** `app/Services/App/Master/ProductService.php:809-822`
- **Code:**
  ```php
  809: public function deleteProduct(Product $product): bool
  810: {
  811:     return DB::transaction(function () use ($product) {
  812:         $before = $product->toArray();
  813: 
  814:         $product->productItems()->delete();
  815:         $product->inventoryItems()->update(['inventory_items.is_active' => false]);
  816:         $deleted = $product->delete();
  817: 
  818:         $this->auditLogService->log($product->business_id, 'product', $product->id, 'deleted', $before, null);
  819: 
  820:         return (bool) $deleted;
  821:     });
  822: }
  ```
- **Observed Behavior:**
  - `ProductItem` uses `Illuminate\Database\Eloquent\SoftDeletes`.
  - Line 814 sets `deleted_at = now()` on all child `product_items`.
  - Line 815 invokes `$product->inventoryItems()`, which is a `HasManyThrough(InventoryItem::class, ProductItem::class, ...)`.
  - Because `ProductItem` is soft-deleted, Eloquent automatically appends `WHERE product_items.deleted_at IS NULL` to the `HasManyThrough` join query.
  - Since all child `product_items` were just soft-deleted on line 814, line 815 matches **zero records**.
  - **Result:** Linked `InventoryItem` records are **never deactivated** (`is_active` remains `true`).
- **Verbatim Test Failure:**
  Running `tests/Feature/Master/AdversarialMilestoneR2Test.php` line 767:
  ```
  FAILED Tests\Feature\Master\AdversarialMilestoneR2Test > soft delete cascades to all product items and deactivates inventory
  InventoryItem must be deactivated
  Failed asserting that true is false.
  at tests/Feature/Master/AdversarialMilestoneR2Test.php:767
  ```

#### Finding 2 (Major): `ServiceProductController::destroy` Bypasses `ProductService::deleteService`
- **Location:** `app/Http/Controllers/App/Master/ServiceProductController.php:154-170`
- **Code:**
  ```php
  154: public function destroy(Product $service): RedirectResponse
  155: {
  156:     $this->authorize(PermissionEnum::SERVICE_DELETE->value);
  157: 
  158:     if ($service->business_id !== auth()->user()->business_id) {
  159:         abort(403);
  160:     }
  161: 
  162:     if (! $service->isService()) {
  163:         abort(404);
  164:     }
  165: 
  166:     $service->delete();
  167: 
  168:     return redirect()->back()->with(
  169:         FlashDataVariable::SUCCESS->value,
  170:         ResourceMessage::DELETE_SUCCESS
  171:     );
  172: }
  ```
- **Observed Behavior:**
  - In `ProductController::destroy`, the controller delegates to `$this->productService->deleteProduct($product)`.
  - `ProductService::deleteService(Product $service)` was explicitly implemented in `ProductService.php:827-839` to soft-delete child `ProductItem` records and record an audit log.
  - However, `ServiceProductController::destroy` still calls `$service->delete()` directly on line 166.
  - **Result:** When a service product is deleted, its child `ProductItem` remains non-deleted and orphaned in `product_items`, and no audit log is written.

#### Finding 3 (Major): Broken Compilation/Signatures in `tests/Feature/Master/AdversarialMilestoneR2Test.php`
- **Location:** `tests/Feature/Master/AdversarialMilestoneR2Test.php:310, 721`
- **Observed Behavior:**
  - Running the whole test directory `php artisan test tests/Feature/Master` encounters 2 failures in `AdversarialMilestoneR2Test.php`:
    - Calling `RawMaterialService::createRawMaterial` with 1 argument instead of 2 (missing `Business $business`).
    - Calling non-existent method `MasterDataSyncService::getOutletMasterData()`.
  - While this was a draft test file, having it reside under `tests/Feature/Master/` causes test suite pollution.

#### Finding 4 (Minor): Legacy Test Failure in `ProductInventoryMultiOutletTest.php`
- **Location:** `tests/Feature/Master/ProductInventoryMultiOutletTest.php:44-74`
- **Observed Behavior:**
  - Running `php artisan test --compact --filter=ProductInventoryMultiOutletTest` fails 3 tests with 302 redirects to `http://app.sollu.test`.
  - Cause: `routes/app/masters.php` has `Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_CATALOG->value)`. The legacy test's `setUp()` did not create an active `Subscription` with plan `PRO`, unlike `ProductControllerTest.php`.

---

## 2. Logic Chain

1. **Premise:** The Unified Item Pattern requires strict lifecycle synchronization: deleting a product or service must cascade soft-delete to its constituent `ProductItem` records, deactivate all linked `InventoryItem` records, and record an audit log.
2. **Observation 1.2 (Finding 1):** In `ProductService::deleteProduct`, line 814 soft-deletes `product_items`. Line 815 queries `$product->inventoryItems()->update(...)`.
3. **Inference:** Because `inventoryItems()` is a `HasManyThrough` via `product_items`, the soft-delete global scope filters out the records that were just soft-deleted. The update query executes:
   ```sql
   UPDATE inventory_items
   SET is_active = false
   WHERE id IN (
       SELECT inventory_items.id
       FROM inventory_items
       INNER JOIN product_items ON product_items.id = inventory_items.product_item_id
       WHERE product_items.product_id = '...'
         AND product_items.deleted_at IS NULL -- <== ZERO ROWS MATCH!
   )
   ```
4. **Conclusion 1:** The inventory items are never updated. This is confirmed by empirical test assertion failure in `tests/Feature/Master/AdversarialMilestoneR2Test.php:767`.
5. **Observation 1.2 (Finding 2):** In `ServiceProductController.php:166`, `$service->delete()` is called directly without deleting child `product_items` or calling `ProductService::deleteService`.
6. **Conclusion 2:** Child service items remain active in `product_items` and will pollute cashier search or inventory audits.
7. **Overall Verdict Deduction:** Since lifecycle soft-deletes leave orphaned active data in both the inventory balance and service catalog layers, changes are required before Milestone R2 can be considered complete.

---

## 3. Verified Claims

| Feature / Invariant | Blueprints & Blueprints Ref | Verified Status | Evidence |
| :--- | :--- | :--- | :--- |
| **Unified Item Pattern** | Plan §4.1 / ORIGINAL_REQUEST §R2 | **PASS** | Every single product creates 1 default `ProductItem` with `variant_combination = null`. Verified in `ProductManagementTest:149-161`. |
| **Inventory Decoupling** | Plan §2, §5.1 / ORIGINAL_REQUEST §R2 | **PASS** | `track_inventory = false` generates 0 rows in `inventory_items` and 0 rows in `inventory_balances`. Verified in `ProductManagementTest:170-174`. |
| **Causality Invariant** | Plan §5.1 / ORIGINAL_REQUEST §R2 | **PASS** | `sellable = false` forces `is_show = false` both in `ProductService` and via Eloquent `saving` event in `Product::booted()` and `ProductItem::booted()`. |
| **Normalized Pivot Sync** | Plan §5.1 / ORIGINAL_REQUEST §R1-R2 | **PASS** | Variant combinations synchronize selected option IDs to `product_item_variant_group_options`. Verified in `ProductManagementTest:280-291`. |
| **Raw Material Invariants** | Plan §5.2.D / ORIGINAL_REQUEST §R2 | **PASS** | `RawMaterialController` strictly enforces `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, and `track_inventory = true`. Blocks deletion if used in active BOM recipe. |
| **Recipe Template & HPP** | Plan §5.2.E / ORIGINAL_REQUEST §R2 | **PASS** | `RecipeTemplateController` manages `RecipeVersion`, BOM items, and estimated HPP calculation per outlet / global average. |
| **Tenant Isolation Fix** | Worker R2 Scope | **PASS** | No `Business::first()` in any master controller. `ModifierGroupController::store()` resolves from `$request->user()->business_id`. |
| **Feature Gating Middleware** | Plan §3, §5.3 / ORIGINAL_REQUEST §R2 | **PASS** | Modifiers protected by `plan.feature:product_modifiers`. Raw materials & recipes protected by `plan.feature:recipe_management`. Micro/Basic tiers blocked with HTTP 403 `is_feature_locked = true`. Verified in `ProductFeatureGatingTest`. |
| **Master Data Sync API** | Plan §5.1.B / ORIGINAL_REQUEST §R2 | **PASS** | `/pos/sync/master` exports `'product_items'`, `'product_item_variant_group_options'`, and backward-compatible `'inventory_item_variant_group_options'`. Verified in `MasterDataSyncTest`. |

---

## 4. Adversarial Challenges & Findings Summary

### Challenge 1: Intermediate Soft Delete on HasManyThrough queries
- **Attack Scenario:** Deleting a product that tracks inventory and verifying whether `inventory_items.is_active` actually changes to `false`.
- **Result:** **FAILED**. As proven in Finding 1, intermediate table soft-delete renders the subsequent `HasManyThrough` update query a no-op.
- **Blast Radius:** Every deleted tracked product leaves orphaned active inventory items in the database.
- **Remediation:** In `ProductService::deleteProduct`:
  ```php
  $itemIds = $product->productItems()->pluck('id');
  InventoryItem::whereIn('product_item_id', $itemIds)->update(['is_active' => false]);
  $product->productItems()->delete();
  $product->delete();
  ```

### Challenge 2: Sibling Controller Parity for Service Deletion
- **Attack Scenario:** Deleting a service product via `DELETE /master/services/{id}` and checking if child `product_items` are soft-deleted.
- **Result:** **FAILED**. As proven in Finding 2, `ServiceProductController::destroy` called `$service->delete()` directly, skipping child items.
- **Blast Radius:** Orphaned active records in `product_items` for every deleted service.
- **Remediation:** In `ServiceProductController::destroy`:
  ```php
  $this->productService->deleteService($service);
  ```

---

## 5. Caveats

- **Frontend Views (Milestone R3):** Controllers return Inertia views `Master/Product/RawMaterial/Index` and `Master/Product/Recipe/Index`. The Vue components themselves are scheduled for design in Milestone R3; backend tests verify JSON/Inertia props without Vue compilation dependencies.
- **Estimated HPP Calculation:** In `RecipeService::calculateEstimatedCost`, if an outlet ID is not provided, the cost calculation uses the average across balances for each ingredient. When an outlet ID is provided, it uses the outlet's specific `average_cost`.

---

## 6. Conclusion

**Verdict: REQUEST_CHANGES**

The core domain logic for Unified Item Pattern, Inventory Decoupling, Feature Gating, and Master Data Sync is well implemented. However, the work product cannot be approved until the two lifecycle deletion defects are fixed:
1. Fix `ProductService::deleteProduct` so that `InventoryItem` records are deactivated before `product_items` are soft-deleted.
2. Fix `ServiceProductController::destroy` to invoke `$this->productService->deleteService($service)`.
3. Clean up the draft/broken test file `tests/Feature/Master/AdversarialMilestoneR2Test.php` so all tests in `tests/Feature/Master` pass.

---

## 7. Verification Method

Once worker_r2 addresses these findings, independent verification can be confirmed with:

1. **Verify Lifecycle Deactivation:**
   ```bash
   php artisan test --compact tests/Feature/Master/AdversarialMilestoneR2Test.php
   ```
   (Must pass with 0 failures, specifically passing `test_soft_delete_cascades_to_all_product_items_and_deactivates_inventory`).

2. **Verify Service Controller Deletion:**
   ```bash
   php artisan test --compact --filter=ServiceProductControllerTest
   ```

3. **Verify Product Management Suite:**
   ```bash
   php artisan test --compact --filter=ProductManagementTest
   ```

4. **Verify Pint Styling:**
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
