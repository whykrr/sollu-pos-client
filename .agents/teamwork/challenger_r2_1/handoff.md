# Milestone R2 Empirical Adversarial Challenge Report

> **Agent:** `challenger_r2_1` (EMPIRICAL CHALLENGER / critic, specialist)  
> **Milestone:** R2 (Service Layer, Feature Gating & Sync API in sollu-app)  
> **Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
> **Date:** 2026-10-22  
> **Verdict:** **REQUEST_CHANGES**

---

## 1. Observation

A dedicated empirical adversarial test harness (`AdversarialMilestoneR2Test.php`) containing 17 rigorous test scenarios was executed against the implementation in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`. 15 tests passed, confirming foundational architectural goals, while 2 tests revealed reproducible defects.

### 1.1 Verified Strengths & Passing Invariants
1. **Task 1 — Causality Invariant (Model Level):**
   - Direct `Product::create(['sellable' => false, 'is_show' => true])` and `$product->update(['sellable' => false, 'is_show' => true])` strictly enforce `$product->is_show = false` in both model instance and database (`Product::booted()` `static::saving` hook).
   - Direct `ProductItem::create(['sellable' => false, 'is_show' => true])` and `$item->update(['sellable' => false, 'is_show' => true])` strictly enforce `$item->is_show = false` in model and database (`ProductItem::booted()` `static::saving` hook).
   - Re-enabling `$model->is_show = true` while `sellable = false` is consistently rejected.
   - `ProductService::createProduct` and `updateProduct` for single products and variant creation correctly set `is_show = false` when `sellable = false`.
2. **Task 2 — Decoupled Inventory (`track_inventory = false`):**
   - Single products created with `track_inventory = false` create exactly 1 `ProductItem` with `variant_combination = null`.
   - Zero rows are created in `inventory_items` and zero rows in `inventory_balances` (`assertEquals(0, DB::table('inventory_items')->where('product_item_id', $item->id)->count())`).
   - Service products (`product_type = 'service'`) strictly enforce `track_inventory = false`, creating 1 `ProductItem` with `variant_combination = null` and zero inventory rows.
   - Toggling single product `track_inventory = false` -> `true` creates `inventory_items` and outlet `inventory_balances`.
3. **Task 3 — Variant Matrix & Pivot Sync (2x2 Cartesian Product):**
   - Products with 2 variant groups (Size: S/M, Color: Red/Blue) generate exactly 4 `ProductItem`s.
   - Normalized pivot table `product_item_variant_group_options` contains 8 rows (2 options mapped per item).
   - Each `ProductItem`'s `variantGroupOptions` relationship correctly loads its constituent option models.
   - Updating the matrix (adding new options) cleanly updates combinations and maintains pivot mappings.
4. **Task 4 — Raw Materials & POS Master Data Sync:**
   - `RawMaterialService::createRawMaterial` enforces `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, and `track_inventory = true`.
   - `MasterDataSyncService::getPayload` exports `product_items` and `product_item_variant_group_options` formatted for Drift SQLite consumption.

---

### 1.2 Observed Defects

#### Defect A: Flawed Cascade in `ProductService::deleteProduct` Leaves `InventoryItem`s Active
- **File:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app/app/Services/App/Master/ProductService.php` lines 809–822:
  ```php
  809:     public function deleteProduct(Product $product): bool
  810:     {
  811:         return DB::transaction(function () use ($product) {
  812:             $before = $product->toArray();
  813: 
  814:             $product->productItems()->delete();
  815:             $product->inventoryItems()->update(['inventory_items.is_active' => false]);
  816:             $deleted = $product->delete();
  817: 
  818:             $this->auditLogService->log($product->business_id, 'product', $product->id, 'deleted', $before, null);
  819: 
  820:             return (bool) $deleted;
  821:         });
  822:     }
  ```
- **Test Command:** `php artisan test --compact --filter=AdversarialMilestoneR2Test`
- **Verbatim Error:**
  ```
  FAILED  Tests\Feature\Master\AdversarialMilestoneR2Test > soft delete cascades to all product items and deactivates inventory
  InventoryItem must be deactivated
  Failed asserting that true is false.

  at tests/Feature/Master/AdversarialMilestoneR2Test.php:820
    816▕         $this->assertTrue($product->fresh()->trashed(), 'Product must be soft deleted');
    817▕         $this->assertTrue($item->fresh()->trashed(), 'ProductItem must be soft deleted');
    818▕         $this->assertEquals(0, ProductItem::where('product_id', $product->id)->count(), 'Active query must return 0 items');
    819▕         $this->assertEquals(1, ProductItem::withTrashed()->where('product_id', $product->id)->count(), 'Trashed query returns 1');
  ➜ 820▕         $this->assertFalse((bool) $invItem->fresh()->is_active, 'InventoryItem must be deactivated');
  ```

#### Defect B: Parent-to-Child Causality Invariant Leak on Variant Product Update
- **File:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app/app/Services/App/Master/ProductService.php` lines 300–334, 418–420:
  ```php
  300:             $sellable = array_key_exists('sellable', $data)
  301:                 ? (bool) $data['sellable']
  302:                 : (bool) $product->sellable;
  303: 
  304:             $isShow = array_key_exists('is_show', $data)
  305:                 ? (bool) $data['is_show']
  306:                 : (bool) $product->is_show;
  307: 
  308:             if (! $sellable) {
  309:                 $isShow = false;
  310:             }
  ...
  338:             // Single Product Unified Item Handling
  339:             if ($product->isBasic() && ! $product->has_variant) {
  ...
  418:             } elseif ($product->isBasic() && $product->has_variant && isset($data['variants'])) {
  419:                 $this->updateVariantMatrix($product, $data, $activeOutletIds);
  420:             }
  ```
- **Test Command:** `php artisan test --compact --filter=AdversarialMilestoneR2Test`
- **Verbatim Error:**
  ```
  FAILED  Tests\Feature\Master\AdversarialMilestoneR2Test > variant product update without variants payload forces child items causality
  Variant item VCU-REG must have is_show = false when parent product sellable is false
  Failed asserting that true is false.

  at tests/Feature/Master/AdversarialMilestoneR2Test.php:785
    783▕         foreach ($items as $item) {
    784▕             $freshItem = $item->fresh();
  ➜ 785▕             $this->assertFalse(
    786▕                 (bool) $freshItem->is_show,
    787▕                 "Variant item {$freshItem->sku} must have is_show = false when parent product sellable is false"
    788▕             );
    789▕         }
  ```

---

## 2. Logic Chain

### 2.1 Logic Chain for Defect A (Zombie Active Inventory Items)
1. In `app/Models/Master/Product.php:174-184`, `inventoryItems()` is defined as a `HasManyThrough` relationship via intermediate model `ProductItem`:
   ```php
   public function inventoryItems(): HasManyThrough
   {
       return $this->hasManyThrough(
           InventoryItem::class,
           ProductItem::class,
           'product_id',
           'product_item_id',
           'id',
           'id'
       );
   }
   ```
2. Intermediate model `ProductItem` implements `Illuminate\Database\Eloquent\SoftDeletes`.
3. In `ProductService::deleteProduct`, line 814 runs `$product->productItems()->delete()`, which soft-deletes all child `product_items` by writing `deleted_at = Carbon::now()`.
4. Line 815 subsequently executes `$product->inventoryItems()->update(['inventory_items.is_active' => false])`.
5. Because `ProductItem` uses `SoftDeletes`, Laravel's `HasManyThrough` builder automatically appends `WHERE product_items.deleted_at IS NULL` to the join condition.
6. Because every `product_items` row for this product was already soft-deleted in step 3, zero intermediate rows match.
7. Consequently, the UPDATE query affects **0 rows**, leaving `inventory_items.is_active = true`. The inventory items remain active in the system despite their parent product and items being deleted.

### 2.2 Logic Chain for Defect B (Causality Invariant Leak for Variant Items)
1. Architectural requirement R2 mandates: `sellable = false => is_show = false` across both products and items.
2. When a merchant or API updates a variant product to `sellable = false` or `is_show = false` without providing the full `variants` matrix array in the payload, line 418 `isset($data['variants'])` evaluates to `false`.
3. Even when `$data['variants']` is provided, `ProductService::updateProduct` updates `$product`, but only passes option-level updates through `updateVariantMatrix`.
4. If a variant product's parent status is set to `sellable = false` / `is_show = false`, the existing `ProductItem` records in the database never have their `sellable` or `is_show` fields updated.
5. In POS sync and catalog queries, `ProductItem::where('is_active', true)` returns items that still have `is_show = true` and `sellable = true`, exposing variants of an unsellable product to cashier terminals.

---

## 3. Caveats

- **Existing Test Coverage Gap:** The existing test `ProductManagementTest::test_soft_deleting_product_soft_deletes_its_product_items` only instantiated a `Product` and `ProductItem` without an `InventoryItem`, which masked Defect A during worker self-verification.
- **Controller Form Submissions:** In standard admin web UI form submissions, `UpdateProductRequest` validates that `variants` and `variant_combinations` are present when `has_variant = true`. However, the service layer `ProductService::updateProduct` must structurally guarantee data integrity for partial updates, programmatic API updates, and background jobs.
- **Scratch Files Cleaned:** The temporary adversarial test harness `tests/Feature/Master/AdversarialMilestoneR2Test.php` was completely removed prior to submitting this handoff.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

While the vast majority of Milestone R2 has been engineered with exceptional quality and architectural fidelity (unified items, decoupled inventory, cartesian matrix resolution, pivot sync, feature gating, and raw materials), the 2 identified defects compromise data integrity under common lifecycle operations:
1. Deleting a product with inventory leaves orphaned active `inventory_items`.
2. Setting a variant product to `sellable = false` leaks visibility to child variant `product_items`.

### Required Remediations for Worker:
1. **Fix `ProductService::deleteProduct` Execution Order:**
   Execute inventory deactivation **before** soft-deleting product items:
   ```php
   $product->inventoryItems()->update(['inventory_items.is_active' => false]);
   $product->productItems()->delete();
   $deleted = $product->delete();
   ```
2. **Cascade Parent Causality to Variant Items in `ProductService::updateProduct`:**
   When `$product->sellable === false` or `$product->is_show === false`, ensure all child items are updated:
   ```php
   if (! $product->sellable) {
       $product->productItems()->update([
           'sellable' => false,
           'is_show' => false,
       ]);
   } elseif (! $product->is_show) {
       $product->productItems()->update([
           'is_show' => false,
       ]);
   }
   ```

---

## 5. Verification Method

### 5.1 Verification Commands
To reproduce Defect A and Defect B, or to verify their eventual fixes in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`:

1. **Verify Inventory Deactivation on Product Deletion:**
   ```php
   // In artisan tinker or feature test:
   $product = app(ProductService::class)->createProduct([
       'business_id' => $business->id,
       'name' => 'Test Del',
       'code' => 'DEL-T',
       'base_price' => 10000,
       'track_inventory' => true,
       'outlets' => [['outlet_id' => $outlet->id, 'is_available' => true]],
   ]);
   $item = $product->productItems()->first();
   $invItem = $item->inventoryItem;
   app(ProductService::class)->deleteProduct($product);
   // Assert:
   assert($invItem->fresh()->is_active === false);
   ```

2. **Verify Variant Parent Causality Cascade:**
   ```php
   // Update variant product to sellable = false
   app(ProductService::class)->updateProduct($variantProduct, [
       'sellable' => false,
       'is_show' => false,
   ]);
   // Assert all items are forced to is_show = false:
   assert($variantProduct->productItems()->where('is_show', true)->count() === 0);
   ```

3. **Regression Test Suite:**
   ```bash
   php artisan test --compact --filter=ProductManagementTest
   php artisan test --compact --filter=ProductFeatureGatingTest
   php artisan test --compact tests/Feature/API/MasterDataSyncTest.php
   ```

### 5.2 Invalidation Conditions
- Any product deletion where `inventory_items.is_active` remains `true`.
- Any variant product update where `product.sellable = false` but any child `product_items.is_show` remains `true`.
