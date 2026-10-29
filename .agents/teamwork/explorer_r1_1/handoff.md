# Handoff Report: Milestone R1 — Database Foundation, Migrations & Indexing in sollu-app

**Author:** `explorer_r1_1`  
**Date:** 2026-10-22  
**Target Project:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
**Working Directory:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_1/`

---

## 1. Observation

### 1.1 Existing Migrations & Schema State

1. **Original Schema Creation (`2026_07_02_214446_create_product_management_tables.php`)**:
   - `variant_groups` (lines 48–54): `id` (uuid pk), `product_id` (uuid), `name` (string), `sort_order` (int).
   - `variant_group_options` (lines 56–63): `id` (uuid pk), `variant_group_id` (uuid), `name` (string), `sort_order` (int).
   - `recipe_versions` (lines 89–96): `id` (uuid pk), `product_id` (uuid), `version_number` (int), `is_active` (boolean, default false), `effective_from` (timestamp nullable). No foreign key constraint on `product_id`.
   - `inventory_item_variant_group_option` (lines 160–164): Old pivot table linking `inventory_item_id` and `variant_group_option_id`.

2. **Creation of `product_items` Table (`2026_09_25_190914_create_product_items_table.php`)**:
   - Columns (lines 16–38):
     - `id`: uuid primary
     - `business_id`: uuid
     - `item_type`: enum `['variant_sku', 'raw_material']`
     - `product_id`: uuid nullable, foreign key `products(id)` `nullOnDelete()`
     - `uom_id`: uuid nullable, foreign key `uoms(id)` `nullOnDelete()`
     - `name`: string nullable
     - `variant_combination`: string nullable, indexed
     - `sku`: string nullable, indexed
     - `barcode`: string nullable, indexed
     - `track_inventory`: boolean, default `false`
     - `is_show`: boolean, default `true`
     - `sellable`: boolean, default `true`
     - `is_active`: boolean, default `true`
     - `timestamps()`, `softDeletes()`
   - Driver check (lines 40–44):
     ```php
     if (DB::getDriverName() !== 'sqlite') {
         Schema::table('product_items', function (Blueprint $table) {
             $table->fullText('name');
         });
     }
     ```
     Creates `product_items_name_fulltext` GIN index in PostgreSQL.

3. **Legacy Normalization (`2026_09_25_190933_migrate_and_normalize_inventory_items.php`)**:
   - Dropped old pivot table at line 172:
     ```php
     Schema::dropIfExists('inventory_item_variant_group_option');
     ```
   - Normalization migrated `inventory_items` rows to `product_items` and synthesized `variant_combination` string, but **did not create a replacement pivot table** for `product_items` and `variant_group_options`.
   - Result: In `MasterDataSyncService.php` line 198:
     ```php
     $inventoryItemVariantGroupOptions = collect();
     ```
     Sends an empty collection to Flutter POS client, causing POS variant option and price resolution to fail.

4. **Existing Indexes on `product_items`**:
   - Inspected via PostgreSQL catalog `pg_indexes` & Boost MCP `database-schema`:
     - `product_items_pkey` on `(id)`
     - `product_items_variant_combination_index` on `(variant_combination)`
     - `product_items_sku_index` on `(sku)`
     - `product_items_barcode_index` on `(barcode)`
     - `product_items_name_fulltext` on `(name)` (PostgreSQL GIN)
     - `product_items_business_product_idx` on `(business_id, product_id)` (from `2026_10_01_000001_add_performance_indexes_to_products_and_prices_table.php`)
     - `product_items_catalog_idx` on `(product_id, is_active, sellable)` (from `2026_10_01_000001_add_performance_indexes_to_products_and_prices_table.php`, lines 24–25)
     - `idx_product_items_business_sync` on `(business_id, updated_at)` (from `2026_10_09_000500_add_pos_sync_compound_indexes.php`)
     - `idx_product_items_product_sync` on `(product_id, updated_at)` (from `2026_10_09_000500_add_pos_sync_compound_indexes.php`)

5. **Current Database Content Analysis**:
   - `products`: 57 rows (35 single products, 22 variant products).
   - `product_items`: 111 rows (34 single items, 77 variant items).
   - **Orphan Product Detected**: Exactly 1 product has 0 `product_items`:
     - ID: `01a0da6b-c0a6-7399-b74c-aab2d023dccb`
     - Name: `'Topup Shopee Pay 200K'`
     - Type: `service`, `track_inventory: false`, `has_variant: false`, `sellable: true`, `is_show: true`.
     - Reason: Created before Unified Item Pattern was enforced; because `track_inventory = false`, no `ProductItem` was generated.
   - Variant Items and Options:
     - 77 variant items across 22 products match 140 option links in `variant_group_options` with 100% precision using the combination of item name and SKU slugs.

6. **Feature Flags & Seeders**:
   - In `database/seeders/Production/FeatureSeeder.php` (lines 109–135, 147–155):
     `product_modifiers`, `recipe_management`, and `raw_materials` are currently commented out!
   - In `app/Enums/FeatureEnum.php`:
     Only `PRODUCT_CATALOG`, `SERVICE_CATALOG`, `PRODUCT_CATEGORIES`, and `PRODUCT_VARIANTS` exist in the Product group. Cases for `PRODUCT_MODIFIERS`, `RECIPE_MANAGEMENT`, and `RAW_MATERIALS` are missing.
   - In `database/seeders/Production/SubscriptionPlanSeeder.php` (lines 143–146):
     The Pro plan already lists `'product_modifiers'`, `'product_bundles'`, `'raw_materials'`, `'recipe_management'` in its `system_features` definition, but they are not linked because `FeatureSeeder` commented them out.

7. **Test Environment Driver**:
   - `phpunit.xml` line 32–33:
     `<env name="DB_CONNECTION" value="sqlite"/>`
     `<env name="DB_DATABASE" value=":memory:"/>`
   - Any PostgreSQL-specific DDL (such as `to_tsvector` or `USING gin`) executed unconditionally without `if (DB::getDriverName() === 'pgsql')` causes SQLite test suites to crash immediately with syntax errors.

---

## 2. Logic Chain

1. **Resolving Disconnected Variants (Observation 1.3, 1.5)**:
   - When Flutter POS queries variants, it requires `product_item_variant_group_options` linking each variant `ProductItem` to its constituent `variant_group_option_id`s.
   - A new table `product_item_variant_group_options` must be created with foreign keys cascading on delete from both `product_items` and `variant_group_options`.
   - A backfill must immediately populate the 140 links for existing 77 variant items so existing data is immediately normalized and POS client sync is unblocked.

2. **Supporting Variant-Level Recipe BOMs (Observation 1.1)**:
   - Currently, `recipe_versions` only has `product_id`. Different variants of the same product (e.g. Small vs Large beverage) have distinct recipes.
   - Adding `product_item_id` (nullable uuid) to `recipe_versions` with a foreign key to `product_items(id)` allows recipes to be tied to a specific variant while remaining nullable for backward compatibility with single/parent-level recipes.
   - Cascade on delete (`cascadeOnDelete()`) ensures that if a variant item is deleted, its specific recipe version is cleaned up symmetrically without orphaned records.

3. **Performance & Omni-Search Indexing (Observation 1.4, 1.7)**:
   - POS and sync lookups require composite indexes scoped by tenant (`business_id`):
     - `(business_id, sku)` for rapid barcode/SKU scanning.
     - `(business_id, barcode)` for physical hardware scanners.
     - `(product_id)` for catalog joins.
   - Notice: `(product_id, is_active, sellable)` **already exists** in `sollu-app` as `product_items_catalog_idx` (created on 2026-10-01). The migration must NOT attempt to re-create `product_items_catalog_idx` to avoid `SQLSTATE[42P07]: relation already exists` error in PostgreSQL.
   - PostgreSQL GIN Fulltext Omni-Search:
     - POS cashier omni-search matches across `name`, `variant_combination`, `sku`, and `barcode`.
     - In PostgreSQL, string concatenation `||` returns `NULL` if any operand is `NULL`. Single products have `variant_combination = NULL`, and many items have `barcode = NULL`.
     - Therefore, every column MUST be wrapped in `coalesce(col, '')`:
       `to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(variant_combination, '') || ' ' || coalesce(sku, '') || ' ' || coalesce(barcode, ''))`
     - Configuration `'simple'` makes `to_tsvector` immutable and indexable in PostgreSQL.
     - The GIN index creation MUST be wrapped in `if (DB::getDriverName() === 'pgsql')` to allow PHPUnit tests to execute on SQLite in-memory without errors.

4. **Single Product Normalization / Backfill (Observation 1.5)**:
   - Unified Item Pattern states that every product has at least 1 `ProductItem`.
   - The orphan product `Topup Shopee Pay 200K` has `has_variant = false` and 0 items.
   - The backfill migration must find all single products lacking a `product_item` and create the default item, linking unassigned `product_prices` records (`product_item_id IS NULL`) to the newly created `ProductItem`.

5. **Feature Gating Activation (Observation 1.6)**:
   - Feature flags `product_modifiers`, `recipe_management`, and `raw_materials` are required for SaaS plan gating in Milestone R2 and R3.
   - They must be:
     1. Declared in `FeatureEnum.php`.
     2. Uncommented in `FeatureSeeder.php`.
     3. Migrated and attached to the `pro` subscription plan in `plan_features` with cache clearing.

6. **Rollback Symmetry Verification**:
   - Every `up()` operation must have an exact inverse in `down()`:
     - Tables: `dropIfExists`
     - Columns: `dropForeign` before `dropColumn`
     - Indexes: `dropIndex` before column modifications, driver-guarded for raw SQL
     - Feature flags: delete pivot assignments then feature records, clear cache

---

## 3. Caveats

1. **Index Deduplication**:
   - `product_items_catalog_idx` already exists on `(product_id, is_active, sellable)`. Do not re-add it under the same name or create an identical redundant index on those same columns.
2. **PostgreSQL vs SQLite Driver Awareness**:
   - Any raw SQL migration (`to_tsvector`, `USING gin`) will crash SQLite tests in `php artisan test` if driver checks are omitted.
3. **Soft Deletes on `product_items`**:
   - `product_items` uses `SoftDeletes`. Database foreign keys with `cascadeOnDelete()` only trigger on hard deletes. Application-level soft-delete cascades in `ProductService` (Milestone R2) must handle soft-deletion.
4. **Existing Data Integrity**:
   - All 57 existing products and 111 items are preserved; no columns or tables are destructively removed in this milestone.

---

## 4. Conclusion & Recommended Implementation

Milestone R1 requires five coordinated database changes in `sollu-app`:

### Migration 1: Pivot Table `product_item_variant_group_options`
**File:** `database/migrations/2026_10_22_100000_create_product_item_variant_group_options_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('product_item_variant_group_options', function (Blueprint $table) {
            $table->foreignUuid('product_item_id')
                ->constrained('product_items')
                ->cascadeOnDelete();

            $table->foreignUuid('variant_group_option_id')
                ->constrained('variant_group_options')
                ->cascadeOnDelete();

            $table->primary(['product_item_id', 'variant_group_option_id'], 'prod_item_vgo_primary');
            $table->index('variant_group_option_id', 'idx_piv_vgo_option_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_item_variant_group_options');
    }
};
```

---

### Migration 2: Add `product_item_id` to `recipe_versions` Table
**File:** `database/migrations/2026_10_22_100001_add_product_item_id_to_recipe_versions_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('recipe_versions', function (Blueprint $table) {
            $table->foreignUuid('product_item_id')
                ->nullable()
                ->after('product_id')
                ->constrained('product_items')
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('recipe_versions', function (Blueprint $table) {
            $table->dropForeign(['product_item_id']);
            $table->dropColumn('product_item_id');
        });
    }
};
```

---

### Migration 3: Composite & GIN Fulltext Indexes on `product_items`
**File:** `database/migrations/2026_10_22_100002_add_composite_and_fulltext_indexes_to_product_items_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('product_items', function (Blueprint $table) {
            $table->index(['business_id', 'sku'], 'idx_product_items_business_sku');
            $table->index(['business_id', 'barcode'], 'idx_product_items_business_barcode');
            $table->index('product_id', 'idx_product_items_product_id');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement("
                CREATE INDEX idx_product_items_omni_search ON product_items USING gin (
                    to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(variant_combination, '') || ' ' || coalesce(sku, '') || ' ' || coalesce(barcode, ''))
                )
            ");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            DB::statement('DROP INDEX IF EXISTS idx_product_items_omni_search');
        }

        Schema::table('product_items', function (Blueprint $table) {
            $table->dropIndex('idx_product_items_product_id');
            $table->dropIndex('idx_product_items_business_barcode');
            $table->dropIndex('idx_product_items_business_sku');
        });
    }
};
```

---

### Migration 4: Data Backfill (Single Products & Variant Options)
**File:** `database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Backfill single products lacking a default ProductItem
        $singleProductsWithoutItems = DB::table('products')
            ->where('has_variant', false)
            ->whereNotExists(function ($query) {
                $query->select(DB::raw(1))
                    ->from('product_items')
                    ->whereColumn('product_items.product_id', 'products.id');
            })
            ->get();

        foreach ($singleProductsWithoutItems as $product) {
            $productItemId = (string) Str::uuid();
            $sku = $product->code ?: ('PRD-' . strtoupper(Str::random(6)));

            DB::table('product_items')->insert([
                'id' => $productItemId,
                'business_id' => $product->business_id,
                'item_type' => 'variant_sku',
                'product_id' => $product->id,
                'uom_id' => null,
                'name' => $product->name,
                'variant_combination' => null,
                'sku' => $sku,
                'barcode' => null,
                'track_inventory' => $product->track_inventory,
                'is_show' => $product->is_show,
                'sellable' => $product->sellable,
                'is_active' => true,
                'created_at' => $product->created_at ?: now(),
                'updated_at' => $product->updated_at ?: now(),
            ]);

            // Link existing unassigned prices for this product
            DB::table('product_prices')
                ->where('product_id', $product->id)
                ->whereNull('product_item_id')
                ->update(['product_item_id' => $productItemId]);
        }

        // Also link existing prices of single products that already have a product item but prices.product_item_id is null
        $singleProductsWithItem = DB::table('products')
            ->join('product_items', 'products.id', '=', 'product_items.product_id')
            ->where('products.has_variant', false)
            ->select('products.id as product_id', 'product_items.id as product_item_id')
            ->get();

        foreach ($singleProductsWithItem as $row) {
            DB::table('product_prices')
                ->where('product_id', $row->product_id)
                ->whereNull('product_item_id')
                ->update(['product_item_id' => $row->product_item_id]);
        }

        // 2. Backfill product_item_variant_group_options from existing variant items
        $variantItems = DB::table('product_items')
            ->join('products', 'product_items.product_id', '=', 'products.id')
            ->where('products.has_variant', true)
            ->select(
                'product_items.id as product_item_id',
                'product_items.name as item_name',
                'product_items.sku',
                'products.id as product_id'
            )
            ->get();

        $inserts = [];
        foreach ($variantItems as $item) {
            $options = DB::table('variant_group_options')
                ->join('variant_groups', 'variant_group_options.variant_group_id', '=', 'variant_groups.id')
                ->where('variant_groups.product_id', $item->product_id)
                ->select(
                    'variant_group_options.id as option_id',
                    'variant_group_options.name as option_name'
                )
                ->get();

            foreach ($options as $opt) {
                $slug = strtolower(str_replace(' ', '-', $opt->option_name));
                if (
                    str_contains(strtolower($item->item_name), strtolower($opt->option_name))
                    || ($item->sku && str_contains(strtolower($item->sku), $slug))
                ) {
                    $inserts[] = [
                        'product_item_id' => $item->product_item_id,
                        'variant_group_option_id' => $opt->option_id,
                    ];
                }
            }
        }

        if (! empty($inserts)) {
            DB::table('product_item_variant_group_options')->insertOrIgnore($inserts);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert product_prices product_item_id for single products back to null
        $singleProductIds = DB::table('products')->where('has_variant', false)->pluck('id');
        DB::table('product_prices')->whereIn('product_id', $singleProductIds)->update(['product_item_id' => null]);

        // Truncate backfilled pivot options
        DB::table('product_item_variant_group_options')->truncate();
    }
};
```

---

### Migration 5: Register Product Feature Flags & Pro Plan Assignment
**File:** `database/migrations/2026_10_22_100004_add_product_features_and_plan_assignments.php`

```php
<?php

use App\Models\Feature;
use App\Models\SubscriptionPlan;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $now = now();
        $features = [
            [
                'code' => 'product_modifiers',
                'name' => 'Opsi Tambahan (Modifier / Add-on)',
                'description' => 'Pengaturan opsi tambahan produk seperti topping, level gula, ekstra shot dengan tambahan harga.',
                'module' => 'product',
                'group' => 'products_and_menu',
                'group_label' => 'Produk & Menu',
                'sort_order' => 100,
                'is_active' => true,
            ],
            [
                'code' => 'recipe_management',
                'name' => 'Manajemen Resep & HPP',
                'description' => 'Perhitungan otomatis Harga Pokok Penjualan (HPP) berbasis komposisi bahan baku dan versi resep.',
                'module' => 'product',
                'group' => 'products_and_menu',
                'group_label' => 'Produk & Menu',
                'sort_order' => 120,
                'is_active' => true,
            ],
            [
                'code' => 'raw_materials',
                'name' => 'Bahan Baku (Raw Materials)',
                'description' => 'Pengelolaan inventori khusus bahan baku dapur dan bahan setengah jadi yang tidak dijual langsung.',
                'module' => 'inventory',
                'group' => 'inventory_and_supply_chain',
                'group_label' => 'Inventori & Rantai Pasok',
                'sort_order' => 140,
                'is_active' => true,
            ],
        ];

        $proPlan = DB::table('subscription_plans')->where('code', 'pro')->first();

        foreach ($features as $f) {
            $featureId = DB::table('features')->where('code', $f['code'])->value('id');

            if (! $featureId) {
                $featureId = (string) Str::uuid();
                DB::table('features')->insert(array_merge($f, [
                    'id' => $featureId,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]));
            } else {
                DB::table('features')->where('id', $featureId)->update([
                    'is_active' => true,
                    'updated_at' => $now,
                ]);
            }

            if ($proPlan) {
                $exists = DB::table('plan_features')
                    ->where('plan_id', $proPlan->id)
                    ->where('feature_id', $featureId)
                    ->exists();

                if (! $exists) {
                    DB::table('plan_features')->insert([
                        'plan_id' => $proPlan->id,
                        'feature_id' => $featureId,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ]);
                }
            }
        }

        Feature::clearCache();
        SubscriptionPlan::clearCache();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $featureCodes = ['product_modifiers', 'recipe_management', 'raw_materials'];
        $featureIds = DB::table('features')->whereIn('code', $featureCodes)->pluck('id');

        DB::table('plan_features')->whereIn('feature_id', $featureIds)->delete();
        DB::table('features')->whereIn('code', $featureCodes)->delete();

        Feature::clearCache();
        SubscriptionPlan::clearCache();
    }
};
```

---

### Supporting Enum & Model Updates

1. **`app/Enums/FeatureEnum.php`**:
   Add the following cases under `Produk & Menu` and `Inventori & Rantai Pasok`:
   ```php
   case PRODUCT_MODIFIERS = 'product_modifiers';
   case RECIPE_MANAGEMENT = 'recipe_management';
   case RAW_MATERIALS = 'raw_materials';
   ```

2. **`app/Models/Master/ProductItem.php`**:
   Add relationships:
   ```php
   public function variantGroupOptions(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
   {
       return $this->belongsToMany(
           VariantGroupOption::class,
           'product_item_variant_group_options',
           'product_item_id',
           'variant_group_option_id'
       );
   }

   public function recipeVersions(): \Illuminate\Database\Eloquent\Relations\HasMany
   {
       return $this->hasMany(RecipeVersion::class);
   }
   ```

3. **`app/Models/Master/VariantGroupOption.php`**:
   Add relationship:
   ```php
   public function productItems(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
   {
       return $this->belongsToMany(
           ProductItem::class,
           'product_item_variant_group_options',
           'variant_group_option_id',
           'product_item_id'
       );
   }
   ```

4. **`app/Models/Master/RecipeVersion.php`**:
   Add fillable `'product_item_id'` and relationship:
   ```php
   public function productItem(): \Illuminate\Database\Eloquent\Relations\BelongsTo
   {
       return $this->belongsTo(ProductItem::class);
   }
   ```

5. **`database/seeders/Production/FeatureSeeder.php`**:
   Uncomment `product_modifiers`, `recipe_management`, and `raw_materials` entries.

---

## 5. Verification Method

To independently verify these migrations:

1. **Run Migration Rollback Symmetry**:
   ```bash
   cd /Users/whykrr/Documents/Projects/Laravel/sollu-app
   php artisan migrate
   php artisan migrate:rollback --step=5
   php artisan migrate
   ```
   *Expected Result:* Zero constraint violations, clean rollback of all 5 steps, followed by successful re-migration.

2. **Verify Database Table & Indexes via PostgreSQL Catalog**:
   ```sql
   -- 1. Check pivot table structure
   SELECT column_name, data_type, is_nullable
   FROM information_schema.columns 
   WHERE table_name = 'product_item_variant_group_options';

   -- 2. Verify recipe_versions foreign key
   SELECT tc.constraint_name, kcu.column_name, ccu.table_name AS foreign_table_name
   FROM information_schema.table_constraints tc
   JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
   JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
   WHERE tc.table_name = 'recipe_versions' AND kcu.column_name = 'product_item_id';

   -- 3. Verify GIN fulltext index and compound indexes
   SELECT indexname, indexdef 
   FROM pg_indexes 
   WHERE tablename = 'product_items';

   -- 4. Verify backfill of orphan single product
   SELECT p.name, pi.sku, pi.item_type, pi.track_inventory
   FROM products p
   JOIN product_items pi ON p.id = pi.product_id
   WHERE p.id = '01a0da6b-c0a6-7399-b74c-aab2d023dccb';

   -- 5. Verify backfill of variant options
   SELECT count(*) FROM product_item_variant_group_options;
   -- Must be >= 140 rows
   ```

3. **Verify Automated Feature & Unit Tests**:
   ```bash
   php artisan test --compact
   ```
   *Expected Result:* Tests pass on in-memory SQLite because GIN index is safely driver-guarded.

4. **Code Quality & Formatting**:
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
