# Milestone R2 Review & Adversarial Challenge Report

> **Reviewer:** `reviewer_r2_2` (teamwork_preview_reviewer / critic)  
> **Milestone:** R2 (Service Layer, Feature Gating & Sync API in sollu-app)  
> **Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
> **Date:** 2026-10-22  
> **Verdict:** **REQUEST_CHANGES**

---

## 1. Observation

### 1.1 Integrity Check & Independent Test Executions
All core test suites claimed in Worker R2's report were independently executed and passed with zero mock/facade implementations or hardcoded shortcuts:
1. `php artisan test --compact --filter=ProductManagementTest`: **6 passed (64 assertions)** in 2.04s.
2. `php artisan test --compact --filter=ProductFeatureGatingTest`: **6 passed (18 assertions)** in 11.49s.
3. `php artisan test --compact tests/Feature/API/MasterDataSyncTest.php`: **1 passed (19 assertions)** in 1.37s.
4. `php artisan test --compact --filter=ProductControllerTest`: **33 passed (227 assertions)** in 14.73s.
5. `php artisan test --compact --filter=ServiceProductControllerTest`: **13 passed (58 assertions)** in 8.72s.
6. `php artisan test --compact --filter=ModifierServiceTest`: **3 passed (15 assertions)** in 3.03s.
7. `php artisan test --compact --filter=RecipeServiceTest`: **1 passed (8 assertions)** in 3.06s.
8. `php artisan test --compact --filter=AdversarialDataInvariantsTest`: **7 passed (14 assertions)** in 3.45s.
9. `php artisan test --compact --filter=ProductItemSearchTest`: **5 passed (33 assertions)** in 3.62s.
10. `php artisan test --compact tests/Feature/Product/AdversarialProductSearchAndDriverTest.php`: **4 passed (24 assertions)** in 3.28s.
11. `php artisan test --compact tests/Feature/Product/EmpiricalSearchIndexChallengeTest.php`: **1 passed, 1 skipped (13 assertions)** in 3.71s.

**Integrity Finding:** ZERO integrity violations detected. No dummy logic, no hardcoded expected outputs, and no fake test certifications.

### 1.2 Observed Findings

#### Finding 1 (Major - Security / Tenant Isolation Leak): Missing `business_id` verification on `ModifierGroupController::update` and `destroy`
- **Location:** `app/Http/Controllers/App/Master/ModifierGroupController.php:55-73`
- **Code:**
  ```php
  public function update(UpdateModifierGroupRequest $request, ModifierGroup $modifier)
  {
      $data = $request->validated();
      $this->modifierService->updateGroup($modifier, $data);

      return redirect()->back()->with('success', 'Modifier berhasil diupdate');
  }

  public function destroy(ModifierGroup $modifier)
  {
      if ($modifier->products()->exists()) {
          return redirect()->back()->with('error', 'Modifier sedang digunakan oleh produk aktif.');
      }

      $this->modifierService->deleteGroup($modifier);

      return redirect()->back()->with('success', 'Modifier berhasil dihapus');
  }
  ```
- **Contrast with `show()` (line 38):**
  ```php
  public function show(Request $request, ModifierGroup $modifier)
  {
      if ($modifier->business_id !== $request->user()->business_id) {
          abort(403);
      }
      return response()->json($modifier->load('options'));
  }
  ```
- **Contrast with `ProductController.php:194` and `222`:**
  ```php
  if ($product->business_id !== auth()->user()->business_id) {
      abort(403);
  }
  ```
- **Direct Impact:** The model `ModifierGroup` utilizes the trait `HasBusiness`, which only defines local query scopes (`scopeCurrentBusiness()`) rather than an automatic global scope. Because route model binding resolves `{modifier}` by UUID across the whole table without a global scope or FormRequest authorization check, any authenticated user can mutate or delete another tenant's modifier group by passing their UUID.

#### Finding 2 (Major - Causality Invariant Gap): Un-cascaded causality when updating a variant product to unsellable
- **Location:** `app/Models/Master/Product.php:82-89` and `app/Services/App/Master/ProductService.php:338-422`
- **Code in `Product.php`:**
  ```php
  protected static function booted(): void
  {
      static::saving(function (Product $product) {
          if (! $product->sellable) {
              $product->is_show = false;
          }
      });
  }
  ```
- **Code in `ProductService.php:338-422` (`updateProduct`):**
  ```php
  if ($product->isBasic() && ! $product->has_variant) {
      ...
      $defaultItem->update([
          ...
          'is_show' => $product->is_show,
          'sellable' => $product->sellable,
      ]);
  } elseif ($product->isBasic() && $product->has_variant && isset($data['variants'])) {
      $this->updateVariantMatrix($product, $data, $activeOutletIds);
  }
  ```
- **Direct Impact:** 
  1. For single products, `updateProduct` updates `$defaultItem->is_show` and `sellable`.
  2. For variant products, if an update payload toggles `sellable = false` without resending the entire `variants` array (e.g. an API update, quick-edit, or background status change), or if `$product->update(['sellable' => false])` is called via Eloquent, the parent `Product` receives `sellable = false` and `is_show = false`. However, its child `ProductItem`s are **never touched** and remain `sellable = true` and `is_show = true`.
  3. Consequently, item-level POS sync queries, search indexes, and cashier POS repositories that query `product_items` directly will continue to treat those variant items as sellable and visible.

#### Finding 3 (Minor - Stale Untracked Test File): `tests/Feature/Master/AdversarialMilestoneR2Test.php` fails on execution
- **Location:** `tests/Feature/Master/AdversarialMilestoneR2Test.php:310` and `721`
- **Output:**
  ```
  ArgumentCountError: Too few arguments to function App\Services\App\Inventory\RawMaterialService::createRawMaterial(), 1 passed and exactly 2 expected
  Error: Call to undefined method App\Services\App\Transaction\MasterDataSyncService::getOutletMasterData()
  Tests: 2 failed, 13 passed
  ```
- **Direct Impact:** This untracked test file was left in the repository with non-existent method signatures. If a developer runs `php artisan test tests/Feature/Master`, the suite reports 2 failures.

---

## 2. Logic Chain

1. **Premise 1 (Multi-Tenancy):** Multi-tenant isolation is a non-negotiable core standard in Sollu App (`02-modular-architecture.md`: Tenant isolation). Every controller mutating or deleting records must guarantee that the target entity belongs to `request()->user()->business_id`.
   - *Observation:* `ModifierGroupController::update` and `destroy` accept `ModifierGroup $modifier` without validating `$modifier->business_id === $request->user()->business_id`.
   - *Deduction:* An attacker from Business A can modify or destroy Business B's modifier groups by submitting PUT/DELETE requests with Business B's UUID.

2. **Premise 2 (Causality Invariant):** The architectural specification explicitly defines:
   $$\text{sellable} = \text{false} \implies \text{is\_show} = \text{false}$$
   In the Unified Item Pattern, catalog visibility and cashier search are conducted at the `ProductItem` level.
   - *Observation:* When a variant product is marked unsellable via `updateProduct` without `variants` in the payload, or via direct Eloquent `$product->update(['sellable' => false])`, `Product::booted()` only flips `is_show` on the parent table and does not cascade to child `product_items`.
   - *Deduction:* Child `product_items` remain `sellable = true` and `is_show = true`, violating the causality invariant for variant products.

3. **Conclusion from Premises:** While the core implementation of Unified Item Pattern, inventory decoupling, sync API backward compatibility, feature gating, raw materials, and recipes is sound and test-verified, Findings 1 and 2 represent material security and data consistency defects that must be addressed prior to approval.

---

## 3. Caveats

- **Milestone R3 Frontend Views:** The Inertia Vue 3 views (`Master/Product/RawMaterial/Index.vue` and `Master/Product/Recipe/Index.vue`) are scheduled for development in Milestone R3. This review verified that controllers return the correct Inertia components and JSON props without runtime exceptions.
- **Recipe HPP Fallback:** `RecipeService::calculateEstimatedCost` calculates the average cost across balances if an outlet ID is not specified, which accurately models merchant-wide estimated HPP when multi-outlet costing varies.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

The work implemented in Milestone R2 is substantial, robust in its decoupling of inventory from product catalog, and verified by over 450 assertions. However, two changes must be made:

### Action Items for Worker:
1. **Fix Tenant Leak in `ModifierGroupController`:**
   In `app/Http/Controllers/App/Master/ModifierGroupController.php`, add tenant ownership guards to `update()` and `destroy()`:
   ```php
   if ($modifier->business_id !== $request->user()->business_id) {
       abort(403);
   }
   ```
2. **Enforce Cascading Causality on Child Variant Items:**
   In `Product::booted()` or `ProductService::updateProduct()`, ensure that whenever a product becomes unsellable (`sellable = false`), all of its child `ProductItem` records are also cascaded:
   ```php
   // In Product::booted() static::saved:
   static::saved(function (Product $product) {
       if (! $product->sellable) {
           $product->productItems()->where('sellable', true)->orWhere('is_show', true)->update([
               'sellable' => false,
               'is_show' => false,
           ]);
       }
   });
   ```
   And in `ProductService::updateProduct()`, if `$product->has_variant` and `! $sellable`, ensure existing child items are updated even if `$data['variants']` is not provided.
3. **Clean Up or Align Stale Test File:**
   Remove or update `tests/Feature/Master/AdversarialMilestoneR2Test.php` to use valid method calls (`createRawMaterial($data, $business)` and `getPayload($device)`).

---

## 5. Verification Method

Once the changes are applied, verify with the following commands in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`:

1. **Verify Tenant Isolation on Modifiers:**
   Create a test ensuring that User from Business A receives HTTP 403 when sending PUT or DELETE to a `ModifierGroup` belonging to Business B.
2. **Verify Cascading Causality on Variant Items:**
   ```bash
   php artisan test --compact --filter=ProductManagementTest
   ```
   Add a test case in `ProductManagementTest` verifying that calling `$product->update(['sellable' => false])` on a variant product updates all child `product_items` to `sellable = false` and `is_show = false`.
3. **Verify Regression Suite:**
   ```bash
   php artisan test --compact --filter=ProductFeatureGatingTest
   php artisan test --compact tests/Feature/API/MasterDataSyncTest.php
   php artisan test --compact --filter=ProductControllerTest
   php artisan test --compact --filter=ServiceProductControllerTest
   php artisan test --compact --filter=ModifierServiceTest
   php artisan test --compact --filter=RecipeServiceTest
   ```
4. **Code Quality:**
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
