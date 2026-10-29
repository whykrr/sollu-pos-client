# Handoff Report: Milestone R1 Iteration 2 — Test & Verification Strategy

**Agent:** `explorer_r1_it2_3`  
**Role:** Test & Verification Strategy Explorer  
**Target:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
**Working Directory:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_it2_3/`  
**Date:** 2026-10-22  

---

## 1. Observation

### 1.1 Review of `tests/Feature/Product/AdversarialDataInvariantsTest.php`
- **Location:** `tests/Feature/Product/AdversarialDataInvariantsTest.php:1-298`
- **Structure & Environment:**
  - Uses `use RefreshDatabase;` (`line 22`).
  - Sets `PRAGMA foreign_keys = ON;` for SQLite connections (`lines 30-32`).
  - Creates a dedicated test `Business` with `retail` business type (`lines 34-47`).
- **Test Methods Audited:**
  1. `test_deleting_product_item_cascades_to_pivot_entries()` (`lines 52-100`):
     - Validates database-level cascade delete on `product_item_variant_group_options` when `product_items` row is hard-deleted (`$item->forceDelete()`).
  2. `test_deleting_variant_group_option_cascades_to_pivot_entries()` (`lines 105-152`):
     - Validates database-level cascade delete on `product_item_variant_group_options` when `variant_group_options` row is deleted (`$option->delete()`).
  3. `test_composite_primary_key_rejects_duplicate_pairs()` (`lines 157-199`):
     - Validates composite primary key rejection on duplicate `(product_item_id, variant_group_option_id)` via `expectException(QueryException::class)`.
  4. `test_deleting_product_item_cascades_to_recipe_versions()` (`lines 204-244`):
     - Validates database-level cascade delete on `recipe_versions` (`product_item_id`) when `product_items` row is hard-deleted.
  5. `test_assigning_invalid_uuid_to_recipe_version_product_item_id_throws_fk_violation()` (`lines 249-269`):
     - Validates foreign key integrity on `recipe_versions.product_item_id` by expecting `QueryException` on non-existent UUID assignment.
  6. `test_single_product_items_have_null_variant_combination()` (`lines 274-296`):
     - Current implementation:
       ```php
       $defaultItem = ProductItem::create([
           'business_id' => $this->business->id,
           'product_id' => $singleProduct->id,
           'item_type' => 'variant_sku',
           'name' => 'Single Product Test',
           'sku' => 'ADV-SNG-1',
           'variant_combination' => null,
           'is_active' => true,
       ]);

       $this->assertNull($defaultItem->variant_combination);
       $this->assertFalse($singleProduct->has_variant);
       ```
     - **Deficiency Observed:** This test manually creates a single product item with `'variant_combination' => null` and asserts `$this->assertNull()`. It is a tautology: it does not verify that dirty legacy items are normalized by migration 100003, nor does it assert that variant items retain their combination strings.

### 1.2 Origin of the Invariant Violation in `sollu_core`
- A database inspection on PostgreSQL `sollu_core` revealed 3 single products with non-null `variant_combination`:
  1. Product `a27fcda1-a690-4efe-acc0-60dcaf43596d` ("Telur Ayam Negeri 1Kg") $\rightarrow$ `variant_combination = 'T1aaeeeggiklmnrruy'`
  2. Product `01a0da70-78ea-700c-8549-f486352d2120` ("Buavita Jeruk 250ml") $\rightarrow$ `variant_combination = 'B025aaeijklmrtuuv'`
  3. Product `a27fcda0-1ca8-4837-a6b1-ba26d873769f` ("Aqua 600ml") $\rightarrow$ `variant_combination = 'A006almqu'`
- **Root Cause Traced:** In `app/Services/App/Master/ProductService.php:99, 315, 343`, legacy code generated:
  `'variant_combination' => VariantStringGenerator::generate([$product->name])` for single products whenever `track_inventory = true`.
- Migration `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php:59-64` only searched for single products with `whereNull('product_items.variant_combination')`, missing these 3 pre-existing records.

### 1.3 Migration Batch State
- `SELECT migration, batch FROM migrations ORDER BY id DESC LIMIT 10;` confirmed:
  - All 5 Milestone R1 migrations (`2026_10_22_100000` through `2026_10_22_100004`) currently reside in **Batch 26**.
  - `php artisan migrate:rollback --step=2` specifically rolls back migrations `100004` and `100003`.
  - `php artisan migrate:rollback --step=5` rolls back the entire batch (all 5 migrations).

---

## 2. Logic Chain

1. **Why `AdversarialDataInvariantsTest` Passed Despite Database Violations**:
   - `phpunit.xml` configures `DB_CONNECTION=sqlite` with `DB_DATABASE=:memory:`.
   - Feature tests run with `RefreshDatabase`, which runs migrations on an empty in-memory SQLite schema.
   - Because the test database has 0 seeded records, migration `100003` has no legacy single products to normalize during test execution.
   - Test 6 manually set `'variant_combination' => null` and passed immediately.
   - Therefore, unit/feature tests alone in SQLite cannot detect data inconsistencies present in the persistent PostgreSQL staging/production database (`sollu_core`). Direct SQL inspection against PostgreSQL is mandatory.

2. **Rollback Step Selection (`--step=2` vs `--step=5`)**:
   - Migration `100003` is the backfill migration that needs the normalization fix.
   - Migration `100004` depends on features and plan assignments.
   - Rolling back `--step=2` un-migrates `100004` and `100003`, allowing fast re-execution of the normalization fix without dropping tables or indexes.
   - Rolling back `--step=5` un-migrates all 5 migrations back to Batch 25 (`2026_10_21_193500`), thoroughly validating complete rollback symmetry (including GIN fulltext indexes and pivot table constraints) as mandated by `.agents/rules/08-database-and-migrations.md`.
   - Recommendation: Worker should first execute `--step=2` to verify the backfill edit, then run a full `--step=5` rollback and re-migration to guarantee whole-milestone symmetry.

3. **Adversarial Test Enhancement**:
   - To make `AdversarialDataInvariantsTest` truly adversarial regarding data normalization:
     - Add a test method `test_normalization_cleans_dirty_variant_combinations_on_single_products()` that creates a dirty single product (`has_variant = false` with non-null `variant_combination`), executes the normalization query, and asserts it becomes `null`.
     - In the same test, verify that a variant product (`has_variant = true`) with a legitimate combination (e.g. `'Red / XL'`) is NOT modified by the normalization query.

---

## 3. Caveats

1. **SQLite In-Memory Limitation**:
   - SQLite in PHPUnit does not execute PostgreSQL GIN full-text index statements (driver-guarded in migration `100002`).
   - Cascade delete in SQLite requires `PRAGMA foreign_keys = ON;`, which Challenger 1 correctly included in `setUp()`.
2. **SoftDeletes on `ProductItem`**:
   - Eloquent `$item->delete()` sets `deleted_at` and does not fire PostgreSQL foreign key cascades. Only `$item->forceDelete()` or direct database deletes trigger foreign key cascades.
3. **Pre-Existing Unrelated Failures**:
   - `ProductControllerTest` and `ServiceProductControllerTest` experience 302 redirects due to dropped `businesses.trial_end_at` in an earlier migration (`2026_10_21_170001`), which will be handled in Milestone R2.

---

## 4. Conclusion & Actionable Verification Protocol

Worker R1 must apply the normalization update to `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php`:
```php
// Normalize single products to have variant_combination = null
DB::table('product_items as pi')
    ->join('products as p', 'pi.product_id', '=', 'p.id')
    ->where('p.has_variant', false)
    ->whereNotNull('pi.variant_combination')
    ->update(['pi.variant_combination' => null]);
```

Once applied, the following 4-step verification sequence must be executed:

### Step A: Targeted Migration Rollback & Re-migration
```bash
php artisan migrate:rollback --step=2 && php artisan migrate
```
*Purpose:* Re-executes migration 100003 with the normalization fix against `sollu_core`.

### Step B: Full Milestone Rollback Symmetry Check
```bash
php artisan migrate:rollback --step=5 && php artisan migrate
```
*Purpose:* Confirms absolute rollback symmetry across all 5 Milestone R1 migrations.

### Step C: Direct PostgreSQL Invariant Query
```bash
php artisan tinker --execute 'dump("Dirty single items count: " . DB::table("products as p")->join("product_items as pi", "p.id", "=", "pi.product_id")->where("p.has_variant", false)->whereNotNull("pi.variant_combination")->count());'
```
*Or via MCP tool `sollu-db query`:*
```sql
SELECT count(*) 
FROM products p 
JOIN product_items pi ON p.id = pi.product_id 
WHERE p.has_variant = false AND pi.variant_combination IS NOT NULL;
```
*Expected Output:* Exactly `0` (reduced from `3`).

### Step D: Automated Test Suite Execution
```bash
php artisan test --compact --filter=AdversarialDataInvariantsTest
php artisan test --compact --filter=ProductItemSearchTest
php artisan test --compact --filter=CheckPlanFeatureTest
```
*Expected Output:* All tests pass with exit code 0.

---

## 5. Verification Method

To independently verify this strategy:
1. Run the PostgreSQL query in Step C on `sollu_core` prior to the fix (confirms 3 violations).
2. Run `php artisan test --compact --filter=AdversarialDataInvariantsTest` in `sollu-app` (confirms current test passes in SQLite).
3. Inspect `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php` lines 58-75 to observe the missing normalization statement.
