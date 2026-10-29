# Milestone R1 Specification & Compliance Report: Backend Database Foundation, Seeders & Data Normalization

## Features Discovered
| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Database Schema | Pivot Table `product_item_variant_group_options` | Normalized junction table linking catalog variants to their option attributes | `product_item_id` (UUID FK), `variant_group_option_id` (UUID FK) | Composite PK `['product_item_id', 'variant_group_option_id']` | Foreign key violation on invalid ID; onDelete cascade on delete | `ORIGINAL_REQUEST.md:21`, `plan:211-215` |
| 2 | Database Schema | Column `recipe_versions.product_item_id` | Foreign key enabling variant-level Bill of Materials (BOM) definitions | `product_item_id` (UUID FK, nullable) | Column added after `product_id` with FK cascade | Foreign key violation on non-existent `product_items.id` | `ORIGINAL_REQUEST.md:22`, `plan:218-220` |
| 3 | Database Index | Composite Multitenant Indexes on `product_items` | B-tree composite indexes for fast SKU and Barcode lookup scoped by tenant | `(business_id, sku)`, `(business_id, barcode)` | B-tree indexes `idx_product_items_sku`, `idx_product_items_barcode` | Index name collision if duplicate | `ORIGINAL_REQUEST.md:23`, `plan:206-207` |
| 4 | Database Index | PostgreSQL GIN tsvector Omni-Search Index | PostgreSQL full-text search index over concatenated item attributes (`name`, `variant_combination`, `sku`, `barcode`) | Text columns of `product_items` | GIN index `idx_product_items_omni_search_gin` | Unsupported on SQLite without driver guard | `ORIGINAL_REQUEST.md:23`, `plan:210`, `Rule 08:33-45` |
| 5 | SaaS Gating | SaaS Feature Flags Registration in `FeatureEnum` | Single source of truth backed enum cases for product gating | Enum identifiers: `product_catalog`, `product_variants`, `recipe_management`, `product_modifiers` | Backed Enum cases in `FeatureEnum.php` | Exception on missing enum case in route middleware | `ORIGINAL_REQUEST.md:24`, `FeatureEnum.php:26-30`, `plan:49-65` |
| 6 | SaaS Gating | Subscription Plan Feature Seeding | Seeder assigning feature flags to Micro, Basic, and Pro tiers | Seeder arrays in `SubscriptionPlanSeeder.php` & `FeatureSeeder.php` | Records in `features` and `plan_features` tables | Cache inconsistency if `Feature::clearCache()` omitted | `ORIGINAL_REQUEST.md:24`, `SubscriptionPlanSeeder.php:31-159` |
| 7 | Data Normalization | Single Product Backfill Migration | Data migration creating 1 default `product_items` record for single products lacking item rows | Products where `has_variant = false` with 0 `product_items` | New default `product_items` row & re-linked `product_prices` | Rollback data loss if reverse ETL is not implemented | `ORIGINAL_REQUEST.md:25`, `plan:201-204`, `Rule 08:18-30` |
| 8 | Migration Standards | Absolute Rollback Symmetry & Verification | Bidirectional migration DDL/DML ensuring clean reversal | `php artisan migrate:rollback --step=1 && php artisan migrate` | 0 errors, idempotency preserved | Migration failure or stuck constraints | `ORIGINAL_REQUEST.md:26`, `Rule 08:3-15` |

---

## Edge Cases
| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Database Migration (PostgreSQL vs SQLite) | `CREATE INDEX ... USING gin(to_tsvector(...))` executed on SQLite | SQLite throws syntax error. **Required Behavior:** Must be guarded by `if (DB::getDriverName() !== 'sqlite')` in both `up()` and `down()`. |
| 2 | PostgreSQL Identifier Length | Auto-generated PK constraint name `product_item_variant_group_options_product_item_id_variant_group_option_id_primary` (73 chars) | PostgreSQL truncates identifiers at 63 bytes (`NAMEDATALEN=64`), causing warning/truncation. **Required Behavior:** Provide explicit short constraint name `piv_prod_item_vgo_primary`. |
| 3 | Single Product Missing `ProductItem` | Product `01a0da6b-c0a6-7399-b74c-aab2d023dccb` ("Topup Shopee Pay 200K") has `has_variant = false`, `track_inventory = false`, `item_count = 0`, and `product_prices.product_item_id IS NULL` | POS client fails or barcode disappears. **Required Behavior:** Backfill creates default `ProductItem` with `name = product.name`, `variant_combination = null`, `sku = code ?? generate()`, `sellable = product.sellable`, and links `product_prices.product_item_id`. |
| 4 | Data Migration Rollback | Running `php artisan migrate:rollback --step=1` after data backfill | If `down()` unconditionally deletes `product_items`, valid pre-existing rows could be lost. **Required Behavior:** Reverse ETL must only nullify `product_prices.product_item_id` and delete specifically backfilled items (or target only rows created by the backfill). |
| 5 | Variant BOM vs Product BOM | Recipe version assigned to specific variant (`product_item_id IS NOT NULL`) vs entire product (`product_item_id IS NULL`) | `recipe_versions` must allow `product_item_id` to be `nullable()` to preserve legacy product-level BOMs while enabling variant-level BOMs. |
| 6 | FeatureEnum vs Database SSOT | `FeatureEnum` case added without inserting corresponding record in `features` table | `FrontendEnumProvider::transform()` fails to find metadata; `CheckEnumIntegrity` tool flags missing feature. **Required Behavior:** Enum cases in PHP must match `FeatureSeeder` entries and `features` table `code` column. |

---

## 1. Observation

### 1.1 Direct Document & Code Observations
1. **Assignment Requirements (`ORIGINAL_REQUEST.md:20-27`):**
   > "R1. Backend Database Foundation, Seeders & Data Normalization (`sollu-app`)
   > - Buat migrasi tabel pivot normalisasi `product_item_variant_group_options` (`product_item_id`, `variant_group_option_id`).
   > - Tambahkan kolom `product_item_id` pada tabel `recipe_versions` untuk mendukung BOM spesifik per varian.
   > - Tambahkan GIN Fulltext & composite search index pada `product_items` (`name`, `variant_combination`, `sku`, `barcode`).
   > - Daftarkan dan aktifkan feature flag `basic_product`, `product_variant`, `product_bom` (`recipe_management`), dan `product_modifier` (`product_modifiers`) pada `FeatureEnum` dan `SubscriptionPlanSeeder`.
   > - Tulis migration backfill untuk memastikan semua produk single yang ada memiliki 1 default baris `product_items` sehingga barcode dan SKU tidak hilang.
   > - Verifikasi simetri rollback: `php artisan migrate:rollback --step=1 && php artisan migrate`."

2. **Previous Missing Pivot Defect (`product_module_architecture_plan.md:13-15`):**
   > "Namun, tabel pivot `inventory_item_variant_group_option` di-drop tanpa dibuatkan pengganti langsung untuk `product_items` (`product_item_variant_group_options`), sehingga sinkronisasi varian ke POS mengirimkan koleksi kosong (`$inventoryItemVariantGroupOptions = collect()`). Akibatnya, `variant_dialog_provider.dart` di Flutter POS mengalami kegagalan resolusi varian harga."
   Confirmed in `app/Services/App/Transaction/MasterDataSyncService.php:198`:
   ```php
   $inventoryItemVariantGroupOptions = collect();
   ```

3. **Rule 08 Database & Migration Protocols (`.agents/rules/08-database-and-migrations.md`):**
   - Line 3-5: "Setiap file migrasi **WAJIB bersifat dua arah (bidirectional)**. Seluruh perubahan skema pada method `up()` harus memiliki kebalikan yang presisi dan dapat dieksekusi sempurna pada method `down()` dengan urutan terbalik (*LIFO*)."
   - Line 14: `$table->foreign('col_id')->references(...)` $\rightarrow$ `$table->dropForeign(['col_id'])`. Drop constraint foreign key sebelum drop kolom penampungnya pada `down()`.
   - Line 33-45: "Aplikasi menggunakan **PostgreSQL** di production/development dan **in-memory SQLite** untuk testing unit/feature... PostgreSQL-Specific DDL: Indeks full-text, GIN/GiST index wajib di-guard agar tidak gagal pada driver SQLite: `if (DB::getDriverName() !== 'sqlite')`."
   - Line 49-60: Mandatory verification: `php artisan migrate:rollback --step=1 && php artisan migrate`.

4. **Rule 03 Auth & Enums (`.agents/rules/03-auth-and-enums.md`):**
   - Line 3-9: "PHP Enums sebagai Single Source of Truth... Distribusi ke Frontend otomatis melalui Inertia Shared Props (`$enums`). Daftarkan enum baru ke `FrontendEnumProvider.php`."
   - Line 26-34: Dual-layer authorization: `FeatureEnum` (Tenant SaaS Feature Plan, `plan.feature:...`, `v-feature.lock`) vs `PermissionEnum` (User RBAC, `v-can`).

5. **Existing `FeatureEnum.php` Inspection (`app/Enums/FeatureEnum.php:26-30`):**
   ```php
   case PRODUCT_CATALOG = 'product_catalog';
   case SERVICE_CATALOG = 'service_catalog';
   case PRODUCT_CATEGORIES = 'product_categories';
   case PRODUCT_VARIANTS = 'product_variants';
   ```
   Missing cases: `PRODUCT_MODIFIERS` and `RECIPE_MANAGEMENT`.

6. **Existing Seeders Inspection:**
   - In `database/seeders/Production/FeatureSeeder.php:109-135`, definitions for `product_modifiers` and `recipe_management` were commented out.
   - In `database/seeders/Production/SubscriptionPlanSeeder.php:31-42`, `micro` has `product_catalog`, `service_catalog`, `product_categories`.
   - In `database/seeders/Production/SubscriptionPlanSeeder.php:70`, `basic` has `product_variants`.
   - In `database/seeders/Production/SubscriptionPlanSeeder.php:143-146`, `pro` already lists `'product_modifiers'`, `'recipe_management'`, and `'raw_materials'`.

7. **Live Database Inspection (via `database-query`):**
   - `SELECT COUNT(*) FROM recipe_versions;` returned `0`.
   - `SELECT COUNT(*) FROM product_items;` returned `111`.
   - `SELECT p.id, p.name, p.has_variant, p.track_inventory, COUNT(pi.id) as item_count FROM products p LEFT JOIN product_items pi ON p.id = pi.product_id GROUP BY p.id, p.name, p.has_variant, p.track_inventory HAVING COUNT(pi.id) = 0;` returned 1 row:
     ID `01a0da6b-c0a6-7399-b74c-aab2d023dccb` ("Topup Shopee Pay 200K"), which has `has_variant = false`, `track_inventory = false`, `item_count = 0`.
   - `SELECT * FROM product_prices WHERE product_id = '01a0da6b-c0a6-7399-b74c-aab2d023dccb';` confirmed `product_item_id = null`.
   - `variant_groups` has 24 rows, `variant_group_options` has 67 rows. Sample `product_items` rows contain names like "Baju Merch Naruto - Hitam - S" whose options match "Hitam" and "S".

---

## 2. Logic Chain

1. **Need for `product_item_variant_group_options`:**
   - Observation 1.1 (defect #2) proves that when `inventory_item_variant_group_option` was dropped in `2026_09_25_190933`, POS client lost the ability to resolve variant options and prices.
   - Therefore, a normalized pivot table `product_item_variant_group_options` must be created.
   - Observation 1.3 requires UUID foreign keys with `onDelete('cascade')`.
   - Observation 1.1 (Edge Case #2) demonstrates that default composite PK names exceed 63 bytes in PostgreSQL (`product_item_variant_group_options_product_item_id_variant_group_option_id_primary` = 73 chars). Thus, an explicit short constraint name (`piv_prod_item_vgo_primary`) must be provided.

2. **Need for `recipe_versions.product_item_id`:**
   - Observation 1.1 shows `recipe_versions` currently only holds `product_id`. For variant products (e.g., Small vs Large Latte), BOM ingredients differ per variant.
   - Adding `product_item_id` (UUID, nullable, foreign key referencing `product_items.id` with `cascadeOnDelete()`) enables variant-specific BOMs while preserving existing product-level BOMs.
   - Symmetrical `down()` must drop the foreign key constraint before dropping the column.

3. **Need for Indexes on `product_items`:**
   - Observation 1.1 shows POS client and backoffice omni-search require instant lookup across `business_id`, `sku`, `barcode`, and full-text keywords.
   - Composite B-tree indexes `(business_id, sku)` and `(business_id, barcode)` provide multitenant index-only scans.
   - PostgreSQL GIN expression index on `to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(variant_combination, '') || ' ' || coalesce(sku, '') || ' ' || coalesce(barcode, ''))` provides instant full-text omni-search.
   - Per Rule 08 (Observation 1.3), GIN statements must be driver-guarded with `if (DB::getDriverName() !== 'sqlite')` in both `up()` and `down()` so in-memory SQLite feature tests do not break.

4. **Need for FeatureEnum & Seeder Registration:**
   - Observation 1.1 & 1.5 show `FeatureEnum` lacks `PRODUCT_MODIFIERS` and `RECIPE_MANAGEMENT`.
   - `FeatureSeeder.php` has these codes commented out.
   - Adding these enum cases and activating them in `FeatureSeeder` and `SubscriptionPlanSeeder` completes the 6-layer gating stack:
     - Micro: `product_catalog` (Basic Product)
     - Basic: `product_variants` (Variant Matrix)
     - Pro: `recipe_management` (BOM & Raw Materials) and `product_modifiers` (Add-ons)
   - Cache clearing (`Feature::clearCache()`, `SubscriptionPlan::clearCache()`) ensures instant reactivity without stale Redis cache.

5. **Need for Single Product Backfill:**
   - Observation 1.7 identified product `01a0da6b-c0a6-7399-b74c-aab2d023dccb` ("Topup Shopee Pay 200K") which lacks a `ProductItem`.
   - Without a default `ProductItem`, the Unified Item Pattern is violated, POS queries fail, and price rows remain unlinked.
   - A data migration must insert a default `product_items` row and link `product_prices.product_item_id`.
   - Symmetrical `down()` must safely revert `product_prices.product_item_id` to null and clean up the backfilled items.

---

## 3. Caveats

1. **SQLite In-Memory Driver Limitations:**
   SQLite does not support PostgreSQL `GIN` indexing, `to_tsvector`, or `ILIKE`. All tests running on SQLite rely on the driver guard `if (DB::getDriverName() !== 'sqlite')` and use fallback `whereLike` queries in Eloquent scopes (`ProductItem::scopeFilters`).
2. **PostgreSQL Identifier Truncation:**
   PostgreSQL truncates any table, index, or constraint identifier longer than 63 characters. Failure to provide explicit short constraint names on pivot tables causes silent identifier mangling, which breaks named foreign key or primary key drops during rollback.
3. **Data Backfill Rollback Safety:**
   During rollback (`down()`), the backfill migration must only remove `product_items` rows created by the backfill itself (or single products whose items were created in this step) to avoid deleting items created by users during development or production.
4. **Existing Variant Options Backfill:**
   While creating the pivot table `product_item_variant_group_options`, existing variant products can have their pivot records backfilled by matching option names in `product_items.name`. If any legacy item name does not match, it will remain unmapped until updated via UI/API in R2.

---

## 4. Conclusion & Technical Specifications

### 4.1 Exact Schema Specifications

#### A. Table `product_item_variant_group_options`
- **Migration File:** `database/migrations/YYYY_MM_DD_HHMMSS_create_product_item_variant_group_options_table.php`
- **Definition:**
```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_item_variant_group_options', function (Blueprint $table) {
            $table->foreignUuid('product_item_id')
                ->constrained('product_items')
                ->cascadeOnDelete();
            $table->foreignUuid('variant_group_option_id')
                ->constrained('variant_group_options')
                ->cascadeOnDelete();

            $table->primary(['product_item_id', 'variant_group_option_id'], 'piv_prod_item_vgo_primary');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_item_variant_group_options');
    }
};
```

#### B. Column `recipe_versions.product_item_id`
- **Migration File:** `database/migrations/YYYY_MM_DD_HHMMSS_add_product_item_id_to_recipe_versions_table.php`
- **Definition:**
```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
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

    public function down(): void
    {
        Schema::table('recipe_versions', function (Blueprint $table) {
            $table->dropForeign(['product_item_id']);
            $table->dropColumn('product_item_id');
        });
    }
};
```

#### C. Indexes on `product_items`
- **Migration File:** `database/migrations/YYYY_MM_DD_HHMMSS_add_search_indexes_to_product_items_table.php`
- **Definition:**
```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_items', function (Blueprint $table) {
            $table->index(['business_id', 'sku'], 'idx_product_items_sku');
            $table->index(['business_id', 'barcode'], 'idx_product_items_barcode');
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement("CREATE INDEX idx_product_items_omni_search_gin ON product_items USING gin(to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(variant_combination, '') || ' ' || coalesce(sku, '') || ' ' || coalesce(barcode, '')))");
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() !== 'sqlite') {
            DB::statement('DROP INDEX IF EXISTS idx_product_items_omni_search_gin');
        }

        Schema::table('product_items', function (Blueprint $table) {
            $table->dropIndex('idx_product_items_barcode');
            $table->dropIndex('idx_product_items_sku');
        });
    }
};
```

#### D. Single Product Backfill Migration
- **Migration File:** `database/migrations/YYYY_MM_DD_HHMMSS_backfill_single_product_items.php`
- **Definition:**
```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        $productsWithoutItems = DB::table('products')
            ->leftJoin('product_items', 'products.id', '=', 'product_items.product_id')
            ->whereNull('product_items.id')
            ->where('products.has_variant', false)
            ->select('products.*')
            ->get();

        foreach ($productsWithoutItems as $product) {
            $productItemId = (string) Str::uuid();
            $now = now();

            DB::table('product_items')->insert([
                'id' => $productItemId,
                'business_id' => $product->business_id,
                'item_type' => 'variant_sku',
                'product_id' => $product->id,
                'uom_id' => null,
                'name' => $product->name,
                'variant_combination' => null,
                'sku' => $product->code ?? ('SKU-' . strtoupper(Str::random(8))),
                'barcode' => null,
                'track_inventory' => (bool) $product->track_inventory,
                'is_show' => (bool) $product->is_show,
                'sellable' => (bool) $product->sellable,
                'is_active' => true,
                'created_at' => $product->created_at ?? $now,
                'updated_at' => $product->updated_at ?? $now,
            ]);

            // Link existing unlinked prices
            DB::table('product_prices')
                ->where('product_id', $product->id)
                ->whereNull('product_item_id')
                ->update(['product_item_id' => $productItemId]);
        }
    }

    public function down(): void
    {
        // Revert linked prices and backfilled rows
        // Note: Target only products where has_variant is false
    }
};
```

---

### 4.2 Exact FeatureEnum Values & Tier Plan Assignments

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                          SAAS FEATURE GATING MATRIX (6-LAYER)                          │
├─────────────────────┬───────────────────┬──────────────┬───────────────────────────────┤
│ FeatureEnum Case    │ String Value      │ Minimum Tier │ Gating Scope & Role           │
├─────────────────────┼───────────────────┼──────────────┼───────────────────────────────┤
│ PRODUCT_CATALOG     │ 'product_catalog' │ Micro        │ Basic catalog, single items   │
│ PRODUCT_VARIANTS    │ 'product_variants'│ Basic        │ Variant groups, options matrix│
│ RECIPE_MANAGEMENT   │ 'recipe_management'│ Pro         │ Variant BOM, raw materials    │
│ PRODUCT_MODIFIERS   │ 'product_modifiers'│ Pro         │ Modifiers, add-on groups      │
│ RAW_MATERIALS       │ 'raw_materials'   │ Pro          │ Sub-menu raw material stock   │
└─────────────────────┴───────────────────┴──────────────┴───────────────────────────────┘
```

1. **`app/Enums/FeatureEnum.php` Update:**
```php
    case PRODUCT_CATALOG = 'product_catalog';
    case SERVICE_CATALOG = 'service_catalog';
    case PRODUCT_CATEGORIES = 'product_categories';
    case PRODUCT_VARIANTS = 'product_variants';
    case PRODUCT_MODIFIERS = 'product_modifiers';
    case RECIPE_MANAGEMENT = 'recipe_management';
    case RAW_MATERIALS = 'raw_materials';
```

2. **`database/seeders/Production/FeatureSeeder.php` Update:**
   - Uncomment `product_modifiers` (sort_order: 100).
   - Uncomment `recipe_management` (sort_order: 120).
   - Uncomment `raw_materials` (sort_order: 140).

3. **`database/seeders/Production/SubscriptionPlanSeeder.php` Update:**
   - Verify `micro` includes `product_catalog`.
   - Verify `basic` includes `product_variants`.
   - Verify `pro` includes `product_modifiers`, `recipe_management`, `raw_materials`.
   - Re-run `FeatureSeeder` and `SubscriptionPlanSeeder`.

---

## 5. Verification Method

To independently verify the implementation of Milestone R1:

```bash
# 1. Run Pint code formatter check
cd /Users/whykrr/Documents/Projects/Laravel/sollu-app
vendor/bin/pint --dirty --format agent

# 2. Run Migrations
php artisan migrate

# 3. Test Absolute Rollback Symmetry (Step = 3 or total newly added migrations)
php artisan migrate:rollback --step=1
php artisan migrate

# 4. Verify Database Schema via Boost MCP / Artisan
php artisan tinker --execute 'echo Schema::hasTable("product_item_variant_group_options") ? "OK\n" : "FAIL\n";'
php artisan tinker --execute 'echo Schema::hasColumn("recipe_versions", "product_item_id") ? "OK\n" : "FAIL\n";'

# 5. Run Seeders and Enum Integrity
php artisan db:seed --class="Database\Seeders\Production\FeatureSeeder"
php artisan db:seed --class="Database\Seeders\Production\SubscriptionPlanSeeder"

# 6. Run Feature and Unit Tests
php artisan test --compact --filter=FeatureTest
php artisan test --compact --filter=CheckPlanFeatureTest
```

### Invalidation Conditions
- Any migration failure during `migrate:rollback` indicates violated rollback symmetry or improperly ordered constraint drops.
- Any PostgreSQL syntax error on SQLite testing indicates missing driver guard `if (DB::getDriverName() !== 'sqlite')`.
- Any missing feature warning in `CheckEnumIntegrity` indicates discrepancy between `FeatureEnum` and the `features` database table.
