# Handoff Report: Milestone R1 — Adversarial Data Invariants & Cascade Verifier

**Agent:** `challenger_r1_1`  
**Role:** EMPIRICAL CHALLENGER (critic, specialist)  
**Target:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
**Verdict:** `REQUEST_CHANGES`

---

## 1. Observation

### 1.1 Task 1: Foreign Key Cascade & Composite Primary Key on `product_item_variant_group_options`
- **Schema & Constraints**:
  - `information_schema.referential_constraints` confirms:
    - `product_item_variant_group_options.product_item_id` $\rightarrow$ `product_items.id` with `delete_rule = CASCADE`.
    - `product_item_variant_group_options.variant_group_option_id` $\rightarrow$ `variant_group_options.id` with `delete_rule = CASCADE`.
  - `information_schema.table_constraints` confirms primary key `product_item_variant_group_options_pkey` on `(product_item_id, variant_group_option_id)`.
- **Cascade on `product_item` Deletion**:
  - In PostgreSQL `sollu_core` and SQLite, hard deleting (`forceDelete()` or `DB::table('product_items')->delete()`) a `product_item` cascades and deletes all associated rows in `product_item_variant_group_options`. Count drops from $N$ to $0$.
  - *SoftDeletes observation*: `app/Models/Master/ProductItem.php:21` implements `use SoftDeletes;`. Calling Eloquent `$item->delete()` performs an `UPDATE` setting `deleted_at`. Because this is an update and not a SQL `DELETE`, PostgreSQL foreign key cascades are not triggered on soft-delete. Hard delete (`$item->forceDelete()`) triggers the cascade as intended.
- **Cascade on `variant_group_option` Deletion**:
  - `app/Models/Master/VariantGroupOption.php` does not use `SoftDeletes`. Calling `$option->delete()` issues a SQL `DELETE`, which cascades to delete all linked entries in `product_item_variant_group_options`. Count drops from $N$ to $0$.
- **Composite Primary Key Rejection**:
  - Attempting to insert a duplicate pair `(product_item_id, variant_group_option_id)` throws:
    `Illuminate\Database\UniqueConstraintViolationException: SQLSTATE[23505]: Unique violation: 7 ERROR: duplicate key value violates unique constraint "product_item_variant_group_options_pkey"`.

### 1.2 Task 2: Foreign Key on `recipe_versions.product_item_id`
- **Schema & Constraints**:
  - Migration `database/migrations/2026_10_22_100001_add_product_item_id_to_recipe_versions_table.php:15-20` created `product_item_id` foreign key referencing `product_items.id` with `cascadeOnDelete()`.
  - `information_schema.referential_constraints` confirms `recipe_versions.product_item_id` $\rightarrow$ `product_items.id` with `delete_rule = CASCADE`.
- **Cascade on `product_item` Deletion**:
  - Deleting a `product_item` cascades and removes all linked `recipe_versions` rows. Count drops from $1$ to $0$.
- **Invalid Foreign Key Assignment**:
  - Attempting to insert a `recipe_versions` row with a non-existent UUID in `product_item_id` throws:
    `Illuminate\Database\QueryException: SQLSTATE[23503]: Foreign key violation: 7 ERROR: insert or update on table "recipe_versions" violates foreign key constraint "recipe_versions_product_item_id_foreign"`.

### 1.3 Task 3: Unified Item Invariant
- **Single Products without `product_items`**:
  - Query:
    ```sql
    SELECT p.id, p.name, p.code
    FROM products p
    WHERE p.has_variant = false
      AND NOT EXISTS (
        SELECT 1 FROM product_items pi WHERE pi.product_id = p.id
      );
    ```
    Result: **0 rows**. All 35 single products have at least 1 `product_items` row.
- **Single Products with `variant_combination IS NULL`**:
  - Query:
    ```sql
    SELECT p.id as product_id, p.name as product_name, p.code as product_code, pi.id as item_id, pi.name as item_name, pi.sku as item_sku, pi.variant_combination
    FROM products p
    JOIN product_items pi ON p.id = pi.product_id
    WHERE p.has_variant = false AND pi.variant_combination IS NOT NULL;
    ```
    Result: **3 VIOLATIONS FOUND**:
    1. Product ID `a27fcda0-1ca8-4837-a6b1-ba26d873769f` ("Aqua 600ml", Code: `PRD-012`) $\rightarrow$ Item ID `101fbb69-e744-45e1-a4c3-4177322bcb5d` has `variant_combination = 'A006almqu'`.
    2. Product ID `01a0da70-78ea-700c-8549-f486352d2120` ("Buavita Jeruk 250ml", Code: `BVT-JRK-250`) $\rightarrow$ Item ID `01a0da70-7913-72c3-9bd1-1b661c6b563a` has `variant_combination = 'B025aaeijklmrtuuv'`.
    3. Product ID `a27fcda1-a690-4efe-acc0-60dcaf43596d` ("Telur Ayam Negeri 1Kg", Code: `PRD-022`) $\rightarrow$ Item ID `a387b7c6-8819-4468-b169-5b1ed594911d` has `variant_combination = 'T1aaeeeggiklmnrruy'`.
- **Root Cause in Migration**:
  - In `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php:59-64`:
    ```php
    $singleProductsWithItem = DB::table('products')
        ->join('product_items', 'products.id', '=', 'product_items.product_id')
        ->where('products.has_variant', false)
        ->whereNull('product_items.variant_combination')
        ->select('products.id as product_id', 'product_items.id as product_item_id')
        ->get();
    ```
    The migration assumed that all existing single products already had `variant_combination IS NULL`. In reality, legacy migrations generated pseudo-hashes for those 3 items. Migration 100003 omitted an explicit normalization step:
    ```php
    DB::table('product_items as pi')
        ->join('products as p', 'pi.product_id', '=', 'p.id')
        ->where('p.has_variant', false)
        ->whereNotNull('pi.variant_combination')
        ->update(['pi.variant_combination' => null]);
    ```

### 1.4 Automated Test Suite Execution
- Authored test suite `tests/Feature/Product/AdversarialDataInvariantsTest.php` in `sollu-app`.
- Executed:
  ```bash
  php artisan test --compact --filter=AdversarialDataInvariantsTest
  ```
  Result: **6 passed (10 assertions)**.
- Formatted via Pint: `vendor/bin/pint --dirty --format agent` $\rightarrow$ `{"tool":"pint","result":"passed"}`.

---

## 2. Logic Chain

1. **Foreign Key Cascade Integrity (Observation 1.1, 1.2)**:
   - When items or variant options are permanently deleted from catalog storage, database-level cascade ensures orphaned junction records and orphaned recipe versions are removed immediately without application memory overhead.
   - Tested both directions on `product_item_variant_group_options`: deleting item cascades, deleting option cascades.
   - Tested `recipe_versions`: invalid UUID fails with foreign key violation; deleting parent item cascades.
   - Empirical proof shows database constraints are correctly configured and active.

2. **Unified Item Invariant Violation (Observation 1.3)**:
   - The Unified Item Pattern requires single products (`has_variant = false`) to represent their sole purchasable SKU without variant dimensions (`variant_combination = null`).
   - If `variant_combination` contains non-null values for single products, POS clients and omni-search will ingest corrupted combination tags (e.g., `'A006almqu'`), and UI grouping logic could misinterpret single items as variant options.
   - Furthermore, `2026_10_22_100003_backfill_single_products_and_variant_options.php:135` relies on `whereNull('pi.variant_combination')` during rollback cleanup, creating asymmetric ETL behavior for these 3 products.

---

## 3. Caveats

1. **Eloquent `SoftDeletes` on `ProductItem`**:
   - Because `ProductItem` uses `SoftDeletes`, developers invoking `$productItem->delete()` will soft-delete the row. The database foreign keys (`ON DELETE CASCADE`) only fire upon `$productItem->forceDelete()` or direct SQL `DELETE`.
   - The pivot table `product_item_variant_group_options` does not have a `deleted_at` column; soft-deleted items will retain active pivot records unless explicit deleting hooks or cascade traits are implemented in future milestones.
2. **Pre-Existing Unrelated Test Failures**:
   - Unrelated tests (`ProductControllerTest`, `ServiceProductControllerTest`) fail due to legacy business trial subscription expectations noted in worker_r1 handoff.

---

## 4. Conclusion & Actionable Next Steps

### Verdict: **`REQUEST_CHANGES`**

While Foreign Key cascades, composite primary key constraints, and 0-orphan single products pass all empirical tests, the Unified Item Invariant is violated by 3 single products containing non-null `variant_combination` strings in `sollu_core`.

### Action Required by `worker_r1`:
1. In `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php`:
   Add a query in `up()` to normalize all single products' `product_items` to have `variant_combination = null`:
   ```php
   DB::table('product_items as pi')
       ->join('products as p', 'pi.product_id', '=', 'p.id')
       ->where('p.has_variant', false)
       ->whereNotNull('pi.variant_combination')
       ->update(['pi.variant_combination' => null]);
   ```
2. Re-run migration or migration rollback/re-migration (`php artisan migrate:rollback --step=2 && php artisan migrate`) so that `sollu_core` reflects `variant_combination IS NULL` for all 35 single products.

---

## 5. Verification Method

1. **Run Automated Adversarial Invariant Test Suite**:
   ```bash
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   ```
   *Expected output:* 6 passed (10 assertions).

2. **Verify Single Product Invariants in PostgreSQL**:
   ```sql
   SELECT p.id, p.name, pi.variant_combination
   FROM products p
   JOIN product_items pi ON p.id = pi.product_id
   WHERE p.has_variant = false AND pi.variant_combination IS NOT NULL;
   ```
   *Expected output:* Exactly 0 rows after fix is applied.
