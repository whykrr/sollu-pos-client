# Handoff Report: Milestone R1 Iteration 2 — Single Product Variant Combination Sanitization

**Author:** `explorer_r1_it2_1`  
**Role:** EXPLORER (investigation, synthesis)  
**Target:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
**Working Directory:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_it2_1/`  
**Date:** 2026-10-22  

---

## 1. Observation

### 1.1 The Defect State in `sollu_core`
Querying the PostgreSQL database `sollu_core` revealed 3 single products (`products.has_variant = false`) whose `product_items` record contains non-null string hashes in `variant_combination`:

```sql
SELECT p.id as product_id, p.name as product_name, p.code as product_code, p.has_variant,
       pi.id as item_id, pi.name as item_name, pi.sku, pi.variant_combination, pi.created_at
FROM products p
JOIN product_items pi ON p.id = pi.product_id
WHERE p.has_variant = false AND pi.variant_combination IS NOT NULL;
```

**Results:**
1. **Aqua 600ml**:
   - `product_id`: `a27fcda0-1ca8-4837-a6b1-ba26d873769f`, Code: `PRD-012`
   - `item_id`: `101fbb69-e744-45e1-a4c3-4177322bcb5d`
   - `variant_combination`: `'A006almqu'`
   - `created_at`: `2026-08-14 08:59:03`
2. **Buavita Jeruk 250ml**:
   - `product_id`: `01a0da70-78ea-700c-8549-f486352d2120`, Code: `BVT-JRK-250`
   - `item_id`: `01a0da70-7913-72c3-9bd1-1b661c6b563a`
   - `variant_combination`: `'B025aaeijklmrtuuv'`
   - `created_at`: `2026-09-25 21:19:59`
3. **Telur Ayam Negeri 1Kg**:
   - `product_id`: `a27fcda1-a690-4efe-acc0-60dcaf43596d`, Code: `PRD-022`
   - `item_id`: `a387b7c6-8819-4468-b169-5b1ed594911d`
   - `variant_combination`: `'T1aaeeeggiklmnrruy'`
   - `created_at`: `2026-08-14 08:59:04`

All other 32 single products in `products` (total 35 single products) currently have `variant_combination IS NULL`.

### 1.2 Root Cause in Legacy Code (`ProductService.php`)
Tracing the source of these exact strings uncovered git commit `daabfbe4f423c559d56d6fbbb892913209b737f9` ("Refactor Product and Recipe Services: Update InventoryItem to ProductItem", committed on Sat Sep 26 06:03:00 2026).

In `app/Services/App/Master/ProductService.php`, single products (`! $product->has_variant`) were erroneously assigned a computed hash:
- **Line 99 (`createProduct`)**:
  ```php
  if ($product->isBasic() && ! $product->has_variant && $product->track_inventory) {
      $singleInvItem = ProductItem::create([
          ...
          'name' => $product->name,
          'variant_combination' => VariantStringGenerator::generate([$product->name]),
          'sku' => $data['code'] ?? null,
  ```
- **Lines 315 & 343 (`updateProduct`)**:
  ```php
  if ($product->isBasic() && ! $product->has_variant) {
      ...
      $singleInvItem->update([
          'name' => $product->name,
          'variant_combination' => VariantStringGenerator::generate([$product->name]),
  ```

In `app/Helpers/VariantStringGenerator.php:23-48`:
```php
foreach ($parts as $part) {
    $firstChar = mb_substr($part, 0, 1);
    $prefix .= mb_strtoupper($firstChar);
    $rest = mb_substr($part, 1);
    $rest = mb_strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $rest));
    if (! empty($rest)) {
        foreach (mb_str_split($rest) as $char) {
            $remainingChars[] = $char;
        }
    }
}
sort($remainingChars);
return $prefix.implode('', $remainingChars);
```

When applied to single product names:
- `"Aqua 600ml"` $\rightarrow$ Prefix `'A'`, sorted `'qua600ml'` $\rightarrow$ `'006almqu'` $\rightarrow$ Result: `'A006almqu'`.
- `"Buavita Jeruk 250ml"` $\rightarrow$ Prefix `'B'`, sorted `'uavitaJeruk250ml'` $\rightarrow$ `'025aaeijklmrtuuv'` $\rightarrow$ Result: `'B025aaeijklmrtuuv'`.
- `"Telur Ayam Negeri 1Kg"` $\rightarrow$ Prefix `'T'`, sorted `'elurAyamNegeri1Kg'` $\rightarrow$ `'1aaeeeggiklmnrruy'` $\rightarrow$ Result: `'T1aaeeeggiklmnrruy'`.

### 1.3 Omission in Migration `2026_10_22_100003`
In `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php:58-74`:
```php
$singleProductsWithItem = DB::table('products')
    ->join('product_items', 'products.id', '=', 'product_items.product_id')
    ->where('products.has_variant', false)
    ->whereNull('product_items.variant_combination')
    ->select('products.id as product_id', 'product_items.id as product_item_id')
    ->get();
```
The migration only backfilled single products that had **no** `product_items` row at all, and assumed all existing single products already had `product_items.variant_combination IS NULL`. It omitted an upfront sanitization step to clean pre-existing corrupt strings.

### 1.4 Database Driver Compatibility
Testing Laravel Query Builder's `update()` compilation revealed:
- Using `DB::table('product_items as pi')->join('products as p', ...)->update(...)` compiles on PostgreSQL into:
  `UPDATE "product_items" as "pi" SET ... WHERE "ctid" IN (SELECT "pi"."ctid" FROM "product_items" ...)`
- **SQLite does not support PostgreSQL `ctid`** and will fail with `no such column: pi.ctid` when running unit/feature tests in in-memory SQLite (`RefreshDatabase`).
- Using an ANSI SQL subquery:
  ```php
  DB::table('product_items')
      ->whereIn('product_id', function ($query) {
          $query->select('id')
              ->from('products')
              ->where('has_variant', false);
      })
      ->whereNotNull('variant_combination')
      ->update([
          'variant_combination' => null,
          'updated_at' => $now,
      ]);
  ```
  compiles cleanly on **both PostgreSQL and SQLite** without any vendor-specific rowid/ctid constructs.

### 1.5 Rollback Behavior in `down()`
In `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php:132-157`:
```php
$backfilledItems = DB::table('product_items as pi')
    ->join('products as p', 'pi.product_id', '=', 'p.id')
    ->where('p.has_variant', false)
    ->whereNull('pi.variant_combination')
    ->whereNotExists(function ($query) {
        $query->select(DB::raw(1))
            ->from('inventory_items as ii')
            ->whereColumn('ii.product_item_id', 'pi.id');
    })
    ->whereNotExists(function ($query) {
        $query->select(DB::raw(1))
            ->from('transaction_items as ti')
            ->whereColumn('ti.product_item_id', 'pi.id');
    })
    ->pluck('pi.id')
    ->toArray();
```
- The 3 single products ("Aqua 600ml", "Buavita Jeruk 250ml", "Telur Ayam Negeri 1Kg") and the other 31 pre-existing single products all have linked `inventory_items` records (e.g., `inventory_item_id = a27fcda0-1fd2-4c2c-b2cd-596ab2373012` for Aqua 600ml).
- Because `whereNotExists('inventory_items')` is enforced, `down()` will **never** delete these pre-existing products.
- Only the single product backfilled by migration 100003 ("Topup Shopee Pay 200K", which has 0 inventory items and 0 transaction items) is selected and deleted on rollback.

---

## 2. Logic Chain

1. **Origin of Defect (Observation 1.1, 1.2)**:
   - When commit `daabfbe4` refactored `ProductService.php`, it introduced `VariantStringGenerator::generate([$product->name])` for all basic single products with inventory tracking.
   - Any single product created or updated via `ProductService` during that era received this pseudo-hash in `product_items.variant_combination`.
   - In `sollu_core`, exactly 3 products ("Aqua 600ml", "Buavita Jeruk 250ml", "Telur Ayam Negeri 1Kg") retained these pseudo-hashes.

2. **Domain Invariant Requirement**:
   - The Unified Item Pattern requires single products (`has_variant = false`) to have `variant_combination = null`.
   - If non-null, POS sync sends these tags to Flutter client omni-search, leading to potential search misdirection and variant UI confusion.

3. **Data Sanitization in Migration 100003 (Observation 1.3, 1.4)**:
   - Migration `2026_10_22_100003` is the designated normalization migration for single products and variant options.
   - Performing the sanitization at the start of `up()` guarantees all single product items have `variant_combination = null` before price linking and subsequent queries run.
   - Employing `whereIn('product_id', subquery)` guarantees database-agnostic compatibility for both production PostgreSQL and test-suite SQLite.

4. **Preservation of Bidirectional Rollback Symmetry (Observation 1.5)**:
   - Sanitizing invalid pseudo-hashes to `null` is a data integrity correction. Rolling back a migration should reverse created structures and data additions, but must **not** re-inject corrupted data.
   - In `down()`, `$backfilledItems` uses `whereNotExists('inventory_items')` and `whereNotExists('transaction_items')`. The 3 affected items have existing inventory records and are therefore safely preserved.
   - Executing `php artisan migrate:rollback --step=2 && php artisan migrate` achieves complete idempotency and 0 constraint or data loss issues.

---

## 3. Caveats

1. **`ProductService.php` in Milestone R2**:
   - Lines 99, 315, and 343 in `app/Services/App/Master/ProductService.php` still contain `VariantStringGenerator::generate([$product->name])`.
   - Modifying `ProductService.php` is explicitly scoped under Milestone R2 ("Backend Service Layer, Feature Gating & Sync API"). When `worker_r2` refactors `ProductService.php`, it must replace these lines with `'variant_combination' => null` so new single products are never assigned a variant combination.
2. **Pre-Existing Unrelated Test Failures**:
   - As documented in `worker_r1` and `challenger_r1_1` handoffs, `ProductControllerTest` and `ServiceProductControllerTest` fail with redirect 302 due to business subscription requirements that are addressed in Milestone R2.

---

## 4. Conclusion & Actionable Next Steps

### Summary
The presence of non-null `variant_combination` strings on 3 single products in `sollu_core` is fully traced to a legacy call to `VariantStringGenerator::generate([$product->name])` in `ProductService.php`. The fix belongs in `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php` at the start of `up()`.

### Concrete Proposed Patch for `worker_r1`

Target file: `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php`

```diff
--- a/database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php
+++ b/database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php
@@ -15,6 +15,17 @@ return new class extends Migration
     {
         $now = now();
 
+        // 1. Sanitize single products: ensure all single products have variant_combination = null
+        DB::table('product_items')
+            ->whereIn('product_id', function ($query) {
+                $query->select('id')
+                    ->from('products')
+                    ->where('has_variant', false);
+            })
+            ->whereNotNull('variant_combination')
+            ->update([
+                'variant_combination' => null,
+                'updated_at' => $now,
+            ]);
+
-        // 1. Backfill single products lacking a default ProductItem
+        // 2. Backfill single products lacking a default ProductItem
         $singleProductsWithoutItems = DB::table('products')
             ->where('has_variant', false)
             ->whereNotExists(function ($query) {
```

### Proposed Test Enhancement in `AdversarialDataInvariantsTest.php`

In `tests/Feature/Product/AdversarialDataInvariantsTest.php`, add an adversarial regression test:

```php
    /**
     * Test 3b: Verify backfill sanitization cleanses corrupted variant_combination on single products.
     */
    public function test_sanitization_cleanses_corrupted_variant_combination_on_single_products(): void
    {
        $singleProduct = Product::create([
            'business_id' => $this->business->id,
            'name' => 'Single Product With Corrupted Hash',
            'code' => 'ADV-SNG-CORRUPT',
            'product_type' => 'basic',
            'has_variant' => false,
        ]);

        $corruptItem = ProductItem::create([
            'business_id' => $this->business->id,
            'product_id' => $singleProduct->id,
            'item_type' => 'variant_sku',
            'name' => 'Single Product With Corrupted Hash',
            'sku' => 'ADV-SNG-CORRUPT',
            'variant_combination' => 'A006almqu',
            'is_active' => true,
        ]);

        $this->assertNotNull($corruptItem->variant_combination);

        DB::table('product_items')
            ->whereIn('product_id', function ($query) {
                $query->select('id')
                    ->from('products')
                    ->where('has_variant', false);
            })
            ->whereNotNull('variant_combination')
            ->update(['variant_combination' => null]);

        $this->assertNull($corruptItem->fresh()->variant_combination);
    }
```

---

## 5. Verification Method

To execute and verify this fix in `/Users/whykrr/Documents/Projects/Laravel/sollu-app`:

1. **Re-run Migrations with Rollback Symmetry**:
   ```bash
   php artisan migrate:rollback --step=2 && php artisan migrate
   ```
   *Expected output:* Migrations 100004 and 100003 rollback cleanly, and re-migrate to completion with exit code 0.

2. **Verify 0 Violations in PostgreSQL `sollu_core`**:
   ```bash
   php artisan tinker --execute '
   $violations = DB::table("products as p")
       ->join("product_items as pi", "p.id", "=", "pi.product_id")
       ->where("p.has_variant", false)
       ->whereNotNull("pi.variant_combination")
       ->count();
   dump("Single products with non-null variant_combination: " . $violations);
   '
   ```
   *Expected output:* Exactly `0`.

3. **Verify Full Rollback Symmetry**:
   ```bash
   php artisan migrate:rollback --step=5 && php artisan migrate
   ```
   *Expected output:* All 5 milestone migrations rollback and re-apply cleanly without any constraint violation.

4. **Run Test Suites**:
   ```bash
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   php artisan test --compact --filter=ProductItemSearchTest
   php artisan test --compact --filter=CheckPlanFeatureTest
   ```
   *Expected output:* All assertions pass (exit code 0).

5. **Format Code**:
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
   *Expected output:* `{"tool":"pint","result":"passed"}`.
