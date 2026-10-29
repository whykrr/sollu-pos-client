# Handoff Report: Milestone R1 Iteration 2 — Rollback & Data Integrity Investigation

**Agent:** `explorer_r1_it2_2`  
**Role:** EXPLORER / DATA INTEGRITY INVESTIGATOR  
**Working Directory:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_it2_2`  
**Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
**Caller / Recipient:** `62e974db-fa87-4f68-ab0a-9c5953d6dc72`  
**Date:** 2026-10-22  

---

## 1. Observation

### 1.1 Review of Migration `2026_10_22_100003_backfill_single_products_and_variant_options.php` `down()` Method
- **File & Lines**: `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php:121-158`
  ```php
  public function down(): void
  {
      // 1. Truncate backfilled pivot options
      DB::table('product_item_variant_group_options')->delete();

      // 2. Revert unassigned prices for pre-existing single product if applicable
      DB::table('product_prices')
          ->where('id', '01a12018-f19d-7301-86fd-6468cf2f313d')
          ->update(['product_item_id' => null]);

      // 3. Revert backfilled product_items and their associated prices
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

      if (! empty($backfilledItems)) {
          DB::table('product_prices')
              ->whereIn('product_item_id', $backfilledItems)
              ->update(['product_item_id' => null]);

          DB::table('product_items')
              ->whereIn('id', $backfilledItems)
              ->delete();
      }
  }
  ```
- **Observed Behavior & Query Analysis**:
  1. **Truncation of Pivot (Step 1)**: `product_item_variant_group_options` was newly created in migration `100000` and populated with 140 backfilled rows in migration `100003`. Calling `delete()` in `down()` reverses the 140 inserts cleanly.
  2. **Reverting Specific Price (Step 2)**: Targets price row `01a12018-f19d-7301-86fd-6468cf2f313d` ("Pulsa Telkomsel 50k"), which was unassigned prior to migration `100003`.
  3. **Identification of Backfilled Items (Step 3)**:
     - The query filters by `p.has_variant = false` AND `whereNull('pi.variant_combination')` AND `whereNotExists(inventory_items)` AND `whereNotExists(transaction_items)`.
     - In PostgreSQL `sollu_core`, executing this query yields exactly 1 row:
       - Item ID: `5c73021f-a86e-4d9b-99df-1851dee5918d` ("Topup Shopee Pay 200K", Product ID: `01a0da6b-c0a6-7399-b74c-aab2d023dccb`, `product_type: service`, `track_inventory: false`).
     - For the 3 single products identified with legacy pseudo-hashes:
       - `a27fcda0-1ca8-4837-a6b1-ba26d873769f` ("Aqua 600ml", Code: `PRD-012`, Item ID: `101fbb69-e744-45e1-a4c3-4177322bcb5d`)
       - `01a0da70-78ea-700c-8549-f486352d2120` ("Buavita Jeruk 250ml", Code: `BVT-JRK-250`, Item ID: `01a0da70-7913-72c3-9bd1-1b661c6b563a`)
       - `a27fcda1-a690-4efe-acc0-60dcaf43596d` ("Telur Ayam Negeri 1Kg", Code: `PRD-022`, Item ID: `a387b7c6-8819-4468-b169-5b1ed594911d`)
       Empirical check via tinker confirmed:
       `inventory_items` count for these 3 items is **3** (1 per item), and `transaction_items` count is **2**.
       Therefore, the subquery `whereNotExists(inventory_items)` evaluates to `false` for all 3 items.
       **Result: Setting `variant_combination = null` on these 3 items will NOT cause them to be matched or deleted by `down()`.**

### 1.2 Origin and Semantics of the Pseudo-Hashes
- **Generation Source**:
  - In `app/Helpers/VariantStringGenerator.php:14-48`, `VariantStringGenerator::generate(array $parts)` constructs a combination string:
    - `"Aqua 600ml"` $\rightarrow$ `Prefix: "A"`, `Sorted rest: "006almqu"` $\rightarrow$ `"A006almqu"`.
    - `"Buavita Jeruk 250ml"` $\rightarrow$ `Prefix: "B"`, `Sorted rest: "025aaeijklmrtuuv"` $\rightarrow$ `"B025aaeijklmrtuuv"`.
    - `"Telur Ayam Negeri 1Kg"` $\rightarrow$ `Prefix: "T"`, `Sorted rest: "1aaeeeggiklmnrruy"` $\rightarrow$ `"T1aaeeeggiklmnrruy"`.
  - In `app/Services/App/Master/ProductService.php:99, 315, 343`:
    ```php
    'variant_combination' => VariantStringGenerator::generate([$product->name])
    ```
    Legacy service code incorrectly generated `variant_combination` strings for basic products without variants.
- **Database Distribution in `sollu_core`**:
  - Out of 35 single products (`has_variant = false`):
    - **32 products** already had `variant_combination = null`.
    - **Only 3 products** had pseudo-hashes generated by the legacy bug.
    - Zero variant groups exist for those 3 products (`DB::table('variant_groups')->whereIn('product_id', ...)->count() === 0`).

### 1.3 Execution and Test Suite Status
- **Test Suite**: `tests/Feature/Product/AdversarialDataInvariantsTest.php`
  - Ran command: `php artisan test --compact --filter=AdversarialDataInvariantsTest`
  - Output: `Tests: 6 passed (10 assertions), Duration: 2.07s`.
- **Related Test Suite**: `tests/Feature/Product/AdversarialProductSearchAndDriverTest.php`
  - Ran command: `php artisan test --compact --filter=AdversarialProductSearchAndDriverTest`
  - Output: `Tests: 4 passed (24 assertions), Duration: 1.60s`.
- **Whole Product Feature Suite**: `tests/Feature/Product/`
  - Ran command: `php artisan test --compact tests/Feature/Product/`
  - Output: `Tests: 15 passed (67 assertions), Duration: 2.53s`.

### 1.4 Database Engine Compatibility for Normalization Query
- Tested in tinker across both database engines:
  1. **PostgreSQL** (`sollu_core`):
     - Executed within transaction:
       ```php
       DB::table('product_items as pi')
           ->join('products as p', 'pi.product_id', '=', 'p.id')
           ->where('p.has_variant', false)
           ->whereNotNull('pi.variant_combination')
           ->update(['pi.variant_combination' => null]);
       ```
       Result: Successfully updated exactly 3 rows (`Postgres affected rows: 3`), translated via `PostgresGrammar` to `UPDATE ... FROM`.
  2. **SQLite** (In-Memory Testing Connection):
     - Executed same query on SQLite in-memory:
       Result: `UPDATE with JOIN succeeded in SQLite!`.
  3. **Alternative Dialect-Independent Syntax**:
     ```php
     DB::table('product_items')
         ->whereIn('product_id', function ($query) {
             $query->select('id')
                 ->from('products')
                 ->where('has_variant', false);
         })
         ->whereNotNull('variant_combination')
         ->update(['variant_combination' => null]);
     ```
     Result: Affects exactly 3 rows in PostgreSQL and 100% portable across all SQL engines.

---

## 2. Logic Chain

1. **Safety of `down()` Against Normalization (Observation 1.1)**:
   - Migration `100003` `down()` protects existing products by requiring `whereNotExists(inventory_items)` and `whereNotExists(transaction_items)`.
   - The 3 normalized products (`Aqua 600ml`, `Buavita Jeruk 250ml`, `Telur Ayam Negeri 1Kg`) all possess `inventory_items` records.
   - Therefore, normalizing `variant_combination` from pseudo-hashes to `null` in `up()` cannot cause `down()` to delete those products or their prices.

2. **Desirability of Restoring Pseudo-Hashes in `down()` (Observation 1.2)**:
   - Under the Unified Item Pattern (Shopify/Square standard), single products (`has_variant = false`) must strictly possess `variant_combination = null`.
   - The pseudo-hashes (`'A006almqu'`, `'B025aaeijklmrtuuv'`, `'T1aaeeeggiklmnrruy'`) were unintended artifacts of legacy code calling `VariantStringGenerator::generate([$product->name])`. They convey no relational information, have no foreign keys, and corrupt search indexes and POS variant display tags.
   - If `down()` attempted to restore pseudo-hashes generically (e.g. by recomputing them for single products), it would corrupt the 32 clean single products that legitimately have `variant_combination = null`.
   - If `down()` hardcoded specific UUIDs and string constants, it would introduce brittle, environment-coupled code violating migration best practices.
   - In accordance with `.agents/rules/08-database-and-migrations.md` Section 2, data sanitization of invalid column states is an idempotent normalization. Restoring corrupted data on rollback is neither required nor desirable.
   - **Conclusion: `down()` must NOT restore pseudo-hashes.**

3. **Placement of Normalization in `up()` (Observation 1.1, 1.4)**:
   - In `up()`, lines 59-64 search for single products using `->whereNull('product_items.variant_combination')` to link unassigned prices.
   - Placing the normalization query before line 59 ensures all single products are sanitized first, guaranteeing consistency throughout `up()`.

4. **Test Suite Verification (Observation 1.3)**:
   - `AdversarialDataInvariantsTest.php` currently passes 100% (6/6 tests, 10 assertions).
   - Adding a dedicated regression test asserting that single products with legacy pseudo-hashes are normalized to `null` will cement this invariant in CI/CD without breaking any existing test.

---

## 3. Caveats

1. **Milestone R2 Service Layer Alignment**:
   - `ProductService.php:99, 315, 343` still contains calls to `VariantStringGenerator::generate([$product->name])` for basic single products. While this investigation is strictly scoped to Milestone R1 (database foundations and migrations), Milestone R2 must update `ProductService` so newly created single products set `'variant_combination' => null`.
2. **Pre-Existing Unrelated Failures**:
   - As documented in `worker_r1` handoff, legacy tests `ProductControllerTest` and `ServiceProductControllerTest` redirect (`302`) due to subscription trial columns dropped in prior milestones. These are scheduled for resolution in Milestone R2.

---

## 4. Conclusion & Actionable Recommendations

### Summary of Answers to Investigation Tasks:
1. **Review `down()`**: `down()` is structurally sound and safely distinguishes backfilled service items from pre-existing single products via `inventory_items` existence guards.
2. **Reverse Handling in `down()`**: Restoring pseudo-hashes is **unnecessary, undesirable, and harmful**. `down()` should leave `variant_combination = null` untouched.
3. **Test Suite `AdversarialDataInvariantsTest.php`**: Passes 100% (6 passed, 10 assertions).

### Recommended Action for `worker_r1`:
1. In `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php`:
   Insert the normalization query into `up()` right after Step 1 (around line 57):
   ```php
   // 1b. Normalize variant_combination to null for all single products (Unified Item Invariant)
   DB::table('product_items as pi')
       ->join('products as p', 'pi.product_id', '=', 'p.id')
       ->where('p.has_variant', false)
       ->whereNotNull('pi.variant_combination')
       ->update(['pi.variant_combination' => null]);
   ```
2. Keep `down()` unchanged.
3. In `tests/Feature/Product/AdversarialDataInvariantsTest.php`:
   Add a dedicated regression test:
   ```php
   /**
    * Test 3b: Verify single product with legacy pseudo-hash variant_combination is normalized to null.
    */
   public function test_legacy_pseudo_hash_on_single_product_is_normalized_to_null(): void
   {
       $singleProduct = Product::create([
           'business_id' => $this->business->id,
           'name' => 'Legacy Aqua 600ml',
           'code' => 'ADV-LEG-AQUA',
           'product_type' => 'basic',
           'has_variant' => false,
       ]);

       $item = ProductItem::create([
           'business_id' => $this->business->id,
           'product_id' => $singleProduct->id,
           'item_type' => 'variant_sku',
           'name' => 'Legacy Aqua 600ml',
           'sku' => 'ADV-LEG-AQUA',
           'variant_combination' => 'A006almqu',
           'is_active' => true,
       ]);

       // Execute normalization
       DB::table('product_items as pi')
           ->join('products as p', 'pi.product_id', '=', 'p.id')
           ->where('p.has_variant', false)
           ->whereNotNull('pi.variant_combination')
           ->update(['pi.variant_combination' => null]);

       $this->assertNull($item->fresh()->variant_combination);
   }
   ```
4. Execute migration cycle and verification:
   ```bash
   php artisan migrate:rollback --step=2 && php artisan migrate
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   vendor/bin/pint --dirty --format agent
   ```

---

## 5. Verification Method

1. **Verify Invariant in PostgreSQL `sollu_core`**:
   ```bash
   php artisan tinker --execute '
   $count = DB::table("products as p")
       ->join("product_items as pi", "p.id", "=", "pi.product_id")
       ->where("p.has_variant", false)
       ->whereNotNull("pi.variant_combination")
       ->count();
   dump("Single products with non-null variant_combination: " . $count);
   '
   ```
   *Expected output after fix:* Exactly `0`.

2. **Verify Rollback Symmetry**:
   ```bash
   php artisan migrate:rollback --step=2 && php artisan migrate
   ```
   *Expected output:* Both migrations roll back cleanly and re-apply with exit code 0.

3. **Verify Automated Invariant Tests**:
   ```bash
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   ```
   *Expected output:* All tests pass (exit code 0).
