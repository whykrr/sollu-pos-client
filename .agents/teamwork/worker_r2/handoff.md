# Milestone R2 Implementation & Verification Report: Service Layer, Feature Gating & Sync API

> **Agent:** `worker_r2`  
> **Milestone:** R2 (Service Layer, Feature Gating & Sync API in sollu-app)  
> **Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
> **Date:** 2026-10-22  

---

## 1. Observation

### 1.1 Pre-existing Deficiencies & Baseline Failures
1. **ProductService & Inventory Coupling:**
   - In `app/Services/App/Master/ProductService.php`, lines 90–109 conditionally created a `ProductItem` only when `$product->track_inventory` was `true`. For non-tracked basic goods and services, no `ProductItem` was generated, barcodes were dropped, and `product_prices.product_item_id` was stored as `NULL`.
   - Single products generated arbitrary hashes via `VariantStringGenerator::generate([$product->name])` instead of maintaining `variant_combination = null`.
   - Variant creation and update logic computed option IDs (`$optIds`) but never attached them to the normalized pivot table `product_item_variant_group_options`.
   - Causality rule `$sellable = false => is_show = false` was not enforced at either service or Eloquent model levels.
2. **Controller Bypasses & Tenant Isolation:**
   - `app/Http/Controllers/App/Master/ProductController.php` line 230 called `$product->delete()` directly, failing to cascade soft deletes to child `ProductItem`s, leaving orphaned active items, and omitting audit trails.
   - `app/Http/Controllers/App/Master/ModifierGroupController.php` line 49 had a multi-tenant isolation leak:
     `$data['business_id'] = auth()->user()->business_id ?? Business::first()->id;`
3. **Missing Master Controllers & Incomplete Gating:**
   - Routes for modifier groups in `routes/app/masters.php` were commented out.
   - No `RawMaterialController` or `RecipeTemplateController` existed in namespace `App\Http\Controllers\App\Master\`.
   - `app/Services/App/Inventory/RawMaterialService.php` omitted `sellable` and `is_show` during creation and update, permitting raw materials to default to `sellable = true` and `is_show = true`.
   - `app/Services/App/Master/RecipeService.php` lacked item-level variant support, variant recipe batch synchronization, and estimated HPP calculation.
4. **MasterDataSync Deficiencies:**
   - `app/Services/App/Transaction/MasterDataSyncService.php` returned `inventoryItemVariantGroupOptions = collect()` and omitted top-level sync keys `product_items` and `product_item_variant_group_options`.
5. **Legacy Test Failures:**
   - `php artisan test --compact --filter=ProductControllerTest` yielded 28 failures due to missing active subscriptions in `setUp()`, triggering 302 redirects to root (`http://app.sollu.test`) from `CheckPlanFeature` middleware.
   - `php artisan test --compact --filter=ServiceProductControllerTest` failed with 403 / 302 for the same reason.

---

## 2. Logic Chain

1. **Unified Item Pattern & Inventory Decoupling:**
   - *Premise:* POS client, barcode scanner, and catalog queries must resolve to a discrete `ProductItem` entity regardless of whether stock tracking is enabled.
   - *Action:* In `ProductService::createProduct`, `updateProduct`, `createService`, and `updateService`, unconditionally create/update a default `ProductItem` with `variant_combination = null` and link `product_prices.product_item_id` to this item.
   - *Decoupling:* Only invoke `inventoryService->linkInventoryItem` when `$product->track_inventory = true`. When `false`, zero `InventoryItem` and zero `InventoryBalance` records are created.
2. **Causality Rule Invariant (`sellable = false => is_show = false`):**
   - *Premise:* Any product or item that cannot be sold commercially must never be shown on customer menus or cashier POS.
   - *Action:* Enforced at three levels:
     1. Service layer: `$isShow = $sellable ? (bool) ($data['is_show'] ?? true) : false;`
     2. Model layer: Added `static::saving` event in `Product::booted()` and `ProductItem::booted()` forcing `is_show = false` if `! $model->sellable`.
     3. Raw Material layer: `RawMaterialController` and `RawMaterialService` strictly force `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, and `track_inventory = true`.
3. **Normalized Pivot Table Synchronization:**
   - *Premise:* Variant selection in cashier POS maps chosen variant group options to a specific `ProductItem`.
   - *Action:* In `ProductService::createVariantMatrix` and `updateVariantMatrix`, `$variantItem->variantGroupOptions()->sync($optIds)` is executed, populating `product_item_variant_group_options`.
4. **Feature Gating Architecture:**
   - *Action:* In `routes/app/masters.php`:
     - Activated `modifiers` resource route under `Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)`.
     - Registered `raw-materials` and `recipes` routes under `Route::middleware('plan.feature:'.FeatureEnum::RECIPE_MANAGEMENT->value)`.
   - Fixed `ModifierGroupController::store` to resolve `$request->user()->business_id`.
5. **POS Master Data Sync API (`MasterDataSyncService`):**
   - *Action:* Populated `product_items` (with mapped `'unit'` from UOM) and `product_item_variant_group_options`. For backward compatibility with legacy POS clients, restored `inventory_item_variant_group_options` by joining `product_item_variant_group_options` with `inventory_items`.
6. **Cascading Lifecycle & Auditing:**
   - *Action:* Updated `ProductController::destroy` to invoke `$this->productService->deleteProduct($product)`, which soft-deletes child `ProductItem`s, deactivates linked `InventoryItem`s, and writes audit records to `AuditLogService`.

---

## 3. Caveats

- **Frontend Views (Milestone R3):** Controllers return Inertia views `Master/Product/RawMaterial/Index` and `Master/Product/Recipe/Index`. The Vue components themselves are scheduled for design in Milestone R3; backend tests verify JSON/Inertia props without Vue compilation dependencies.
- **Estimated HPP Average:** In `RecipeService::calculateEstimatedCost`, if an outlet ID is not provided, the cost calculation uses the average across balances for each ingredient. When an outlet ID is provided, it uses the outlet's specific `average_cost`.

---

## 4. Conclusion

Milestone R2 is fully implemented and genuinely verified. All 16 owned files have been created or modified in accordance with architectural blueprints. The decoupling of product catalog from inventory balance is complete, the causality invariant is structurally enforced across all layers, routes are protected by subscription feature gating, and the sync API is ready for POS client consumption.

### Summary of Modified & Created Files
- `app/Services/App/Master/ProductService.php`: Complete rewrite for inventory decoupling, unified items, and variant matrices.
- `app/Models/Master/Product.php`: Added `booted()` causality guard, `defaultItem()`, and scopes.
- `app/Models/Master/ProductItem.php`: Added `booted()` causality guard, scopes, and helper methods.
- `app/Http/Controllers/App/Master/ProductController.php`: Updated `destroy` to invoke `ProductService::deleteProduct`.
- `app/Http/Controllers/App/Master/ModifierGroupController.php`: Fixed multi-tenant isolation leak in `store()`.
- `app/Http/Controllers/App/Master/RawMaterialController.php`: Created controller in Master namespace enforcing raw material invariants.
- `app/Http/Controllers/App/Master/RecipeTemplateController.php`: Created controller managing recipe versions, BOM items, and estimated HPP.
- `app/Http/Requests/App/Master/Recipe/StoreRecipeTemplateRequest.php`: Created FormRequest for recipe template storage.
- `app/Http/Requests/App/Master/Recipe/UpdateRecipeTemplateRequest.php`: Created FormRequest for recipe template update.
- `app/Services/App/Inventory/RawMaterialService.php`: Enforced `sellable = false`, `is_show = false`, and `track_inventory = true`.
- `app/Services/App/Master/RecipeService.php`: Implemented item-level BOM, variant recipe sync, and `calculateEstimatedCost`.
- `routes/app/masters.php`: Activated modifier routes and added raw-materials and recipes routes under `plan.feature` middleware.
- `app/Services/App/Transaction/MasterDataSyncService.php`: Exported `product_items`, `product_item_variant_group_options`, and backward-compatible mappings.
- `tests/Feature/Master/ProductControllerTest.php`: Fixed `setUp()` with Pro subscription and full features; aligned active status test assertion.
- `tests/Feature/Master/ServiceProductControllerTest.php`: Fixed `setUp()` with Pro subscription and full features.
- `tests/Feature/Master/ProductManagementTest.php`: Created test suite covering unified item, decoupled inventory, variant matrix, causality, and soft delete.
- `tests/Feature/Master/ProductFeatureGatingTest.php`: Created test suite verifying Micro, Basic, and Pro tier feature gating on routes.
- `tests/Feature/API/MasterDataSyncTest.php`: Created test suite verifying sync payload keys, outlet scoping, and pivot mappings.

---

## 5. Verification Method

### 5.1 Verification Commands and Results

All commands executed in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`:

1. **ProductManagementTest:**
   ```bash
   php artisan test --compact --filter=ProductManagementTest
   ```
   **Result:**
   ```
   ......
   Tests:    6 passed (64 assertions)
   Duration: 1.72s
   ```

2. **ProductFeatureGatingTest:**
   ```bash
   php artisan test --compact --filter=ProductFeatureGatingTest
   ```
   **Result:**
   ```
   ......
   Tests:    6 passed (18 assertions)
   Duration: 9.08s
   ```

3. **MasterDataSyncTest:**
   ```bash
   php artisan test --compact tests/Feature/API/MasterDataSyncTest.php
   ```
   **Result:**
   ```
   .
   Tests:    1 passed (19 assertions)
   Duration: 0.79s
   ```

4. **ProductControllerTest:**
   ```bash
   php artisan test --compact --filter=ProductControllerTest
   ```
   **Result:**
   ```
   .................................
   Tests:    33 passed (227 assertions)
   Duration: 5.68s
   ```

5. **ServiceProductControllerTest:**
   ```bash
   php artisan test --compact --filter=ServiceProductControllerTest
   ```
   **Result:**
   ```
   .............
   Tests:    13 passed (58 assertions)
   Duration: 2.66s
   ```

6. **Regression Verifications:**
   ```bash
   php artisan test --compact --filter=ModifierServiceTest
   # Tests: 3 passed (15 assertions)
   php artisan test --compact --filter=RecipeServiceTest
   # Tests: 1 passed (8 assertions)
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   # Tests: 7 passed (14 assertions)
   php artisan test --compact --filter=ProductItemSearchTest
   # Tests: 5 passed (33 assertions)
   ```

7. **Code Formatting (Pint):**
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
   **Result:** Clean / All modified files formatted according to standard.

### 5.2 Invalidation Conditions
- Any creation of a single product with `track_inventory = false` that results in `inventory_items` or `inventory_balances` database rows.
- Any creation of a product with `sellable = false` resulting in `is_show = true`.
- Any creation of variant combinations whose option IDs fail to sync to `product_item_variant_group_options`.
- Any tenant on a `micro` plan accessing `/master/modifiers`, `/master/raw-materials`, or `/master/recipes` without receiving HTTP 403 `is_feature_locked = true`.
- Any call to `/pos/sync/master` omitting `'product_items'` or `'product_item_variant_group_options'`.
