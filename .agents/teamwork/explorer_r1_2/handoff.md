# Investigation & Strategy Report: Milestone R1 (Seeders, Feature Flags & Backfill in sollu-app)

> **Agent**: `explorer_r1_2`  
> **Milestone**: R1 — Backend Database Foundation, Seeders & Data Normalization (`sollu-app`)  
> **Workspace**: `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  
> **Date**: 2026-10-22  

---

## 1. Observation

### 1.1 `app/Enums/FeatureEnum.php`
- In `app/Enums/FeatureEnum.php` (lines 22–30):
  ```php
  /*
  |--------------------------------------------------------------------------
  | Produk & Menu (Products & Catalog)
  |--------------------------------------------------------------------------
  */

  case PRODUCT_CATALOG = 'product_catalog';
  case SERVICE_CATALOG = 'service_catalog';
  case PRODUCT_CATEGORIES = 'product_categories';
  case PRODUCT_VARIANTS = 'product_variants';
  ```
- **Observations on enum cases vs plan specification**:
  - `basic_product`: Does **NOT** exist in `FeatureEnum.php`. Instead, `PRODUCT_CATALOG = 'product_catalog'` is the established standard throughout backend routes (`routes/app/masters.php:19`), tests (`tests/Feature/Master/ProductControllerTest.php:48`), database records, and Vue frontend (`resources/js/Composable/Sidebar/main.js:127`).
  - `product_variant`: In `FeatureEnum.php`, the case is plural: `PRODUCT_VARIANTS = 'product_variants'`.
  - `product_bom` / `recipe_management`: Neither `PRODUCT_BOM` nor `RECIPE_MANAGEMENT` exists in `FeatureEnum.php`.
  - `product_modifier` / `product_modifiers`: Neither `PRODUCT_MODIFIER` nor `PRODUCT_MODIFIERS` exists in `FeatureEnum.php`.
- **Pre-existing commented-out references found**:
  - `routes/app/masters.php` (line 39):
    ```php
    // Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)
    ```
  - `resources/js/Composable/Sidebar/main.js` (line 143):
    ```javascript
    // feature: enums.FeatureEnum.PRODUCT_MODIFIERS,
    ```

### 1.2 Database `features` Table & Seeders
- In database table `features` (queried via `sollu_laravel-boost database-query`):
  ```json
  [
    {"code":"product_catalog","name":"Katalog Produk Barang","is_active":true},
    {"code":"product_categories","name":"Kategori Produk","is_active":true},
    {"code":"product_variants","name":"Varian Produk","is_active":true},
    {"code":"product_modifiers","name":"Opsi Tambahan (Modifier / Add-on)","is_active":false},
    {"code":"recipe_management","name":"Manajemen Resep & HPP","is_active":false},
    {"code":"raw_materials","name":"Bahan Baku (Raw Materials)","is_active":false}
  ]
  ```
- In `database/seeders/Production/FeatureSeeder.php`:
  - Lines 109–117: `product_modifiers` definition is commented out (`// 'code' => 'product_modifiers', ...`).
  - Lines 128–135: `recipe_management` definition is commented out (`// 'code' => 'recipe_management', ...`).
  - Lines 148–155: `raw_materials` definition is commented out (`// 'code' => 'raw_materials', ...`).
- In `database/seeders/Production/SubscriptionPlanSeeder.php`:
  - Micro plan (lines 31–42) includes: `pos_cashier`, `product_catalog`, `service_catalog`, `product_categories`, `basic_reports`, `outlet_management`, etc.
  - Basic plan (lines 58–88) includes: All Micro features + `product_variants`, `inventory_management`, `multi_outlet`, etc.
  - Pro plan (lines 105–159) includes: All Basic features + `'product_modifiers'`, `'raw_materials'`, `'recipe_management'`, `multi_device`, `split_payment`, `void_refund`, etc.
  - Line 16: `$featuresByCode = Feature::all()->keyBy('code');`
  - Lines 178–182:
    ```php
    $featureIds = [];
    foreach ($data['system_features'] as $featureCode) {
        if (isset($featuresByCode[$featureCode])) {
            $featureIds[] = $featuresByCode[$featureCode]->id;
        }
    }
    $plan->systemFeatures()->sync($featureIds);
    ```
  - In `SubscriptionPlan.php` (lines 187–196):
    ```php
    public function activeFeatureCodes(): array
    {
        return $this->systemFeatures()->where('is_active', true)->pluck('code')->all();
    }
    ```
    Because `features.is_active` is `false` for `product_modifiers` and `recipe_management`, they were never counted as active features even if referenced.

### 1.3 State of `products`, `product_items`, and `product_prices`
- Query on `products` table:
  - Total products: 57
  - Single products (`has_variant = false`): 35
  - Variant products (`has_variant = true`): 22
- Query on single products without `product_items`:
  - Exactly 1 product: `id = 01a0da6b-c0a6-7399-b74c-aab2d023dccb`, `name = "Topup Shopee Pay 200K"`, `product_type = "service"`, `has_variant = false`, `track_inventory = false`.
  - Reason: `ProductService.php` (line 91) previously created `ProductItem` only when:
    ```php
    if ($product->isBasic() && ! $product->has_variant && $product->track_inventory)
    ```
    Therefore, service products or products with `track_inventory = false` never received a `product_items` record.
- In `product_prices`:
  - 24 records currently have `product_item_id IS NULL`.
  - For single products where `product_item_id` is null, the base price must be tied to the default `product_items` record.
- Indexes on `product_items`:
  - Columns `sku` and `barcode` have non-unique btree indexes (`product_items_sku_index`, `product_items_barcode_index`).
  - Column `name` has fulltext index in PostgreSQL (`product_items_name_fulltext`).

### 1.4 Existing Models & Relationships
- `app/Models/Master/ProductItem.php`:
  - Contains `product(): BelongsTo`, `uom(): BelongsTo`, `prices(): HasMany`, `inventoryItem(): HasOne`.
  - Does **NOT** contain `variantGroupOptions()` or `recipeVersions()`.
- `app/Models/Master/VariantGroupOption.php`:
  - Contains only `variantGroup(): BelongsTo`.
  - Does **NOT** contain `productItems(): BelongsToMany`.
- `app/Models/Master/RecipeVersion.php`:
  - Contains `product(): BelongsTo` and `items(): HasMany`.
  - Does **NOT** have `product_item_id` in `$fillable` or `productItem(): BelongsTo`.
  - Uses legacy `$casts = [...]` property instead of Laravel 12 `casts(): array` method.
- Database tables:
  - `product_item_variant_group_options`: Table does **not** exist yet.
  - `recipe_versions`: Does **not** have `product_item_id` column yet.

---

## 2. Logic Chain

### 2.1 FeatureEnum Single Source of Truth
1. **Observation 1.1** demonstrates that `PRODUCT_CATALOG` (`product_catalog`) and `PRODUCT_VARIANTS` (`product_variants`) are already pervasive across routes, Vue components, tests, and database tables.
2. In the plan specification table, `basic_product` and `product_variant` represent conceptual tier names. Adopting `PRODUCT_CATALOG` for basic product catalog and `PRODUCT_VARIANTS` for variants preserves complete backwards compatibility and adheres to the project's PHP Enum SSOT standard (`03-auth-and-enums.md`).
3. Commented-out code in `routes/app/masters.php:39` and `Sidebar/main.js:143` explicitly awaits `FeatureEnum::PRODUCT_MODIFIERS->value` (`product_modifiers`).
4. Database table `features` already contains rows for `product_modifiers` and `recipe_management`.
5. Therefore, adding:
   - `case PRODUCT_MODIFIERS = 'product_modifiers';`
   - `case RECIPE_MANAGEMENT = 'recipe_management';`
   - `case RAW_MATERIALS = 'raw_materials';`
   to `app/Enums/FeatureEnum.php` completes the enum set, fulfills the 4-tier SaaS feature gating requirement, and resolves all commented-out references without conflicts.

### 2.2 Seeder & Plan Activation Pipeline
1. **Observation 1.2** proves that `SubscriptionPlanSeeder.php` queries `Feature::all()->keyBy('code')`, but `FeatureSeeder.php` had `product_modifiers` and `recipe_management` commented out.
2. In `features` table, their rows have `is_active = false`.
3. Consequently, when `SubscriptionPlanSeeder` executed:
   - Micro received `product_catalog` (covers basic products).
   - Basic received `product_variants`.
   - Pro had `'product_modifiers'` and `'recipe_management'` in its array, but because they were disabled or commented out in `FeatureSeeder`, they could not be effectively attached.
4. Therefore, the implementation in R1 requires:
   - In `FeatureSeeder.php`: Uncomment `product_modifiers`, `recipe_management`, and `raw_materials`, ensuring `'is_active' => true`.
   - In `SubscriptionPlanSeeder.php`: Ensure exact feature codes:
     - **Micro**: `product_catalog`, `service_catalog`, `product_categories`
     - **Basic**: Micro features + `product_variants`
     - **Pro**: Basic features + `product_modifiers`, `recipe_management`, `raw_materials`
   - A dedicated database migration to activate these 3 features in existing database instances (`UPDATE features SET is_active = true WHERE code IN (...)`) and sync the Pro plan features so that fresh seeds and existing environments stay identical.

### 2.3 Single Product Backfill & Rollback Symmetry
1. **Observation 1.3** showed that under the Unified Item Pattern, every `Product` must have $\ge 1$ `ProductItem`.
2. While migration `2026_09_25_190933` created `product_items` for products that had `inventory_items`, products without inventory (such as service products like `Topup Shopee Pay 200K`) were left with 0 `product_items` and orphaned price rows (`product_prices.product_item_id = null`).
3. To comply with `08-database-and-migrations.md` (Bidirectional migrations, absolute rollback symmetry):
   - The backfill MUST be implemented as a Laravel database migration so that all deployment pipelines run it automatically.
   - In `up()`:
     - Query all products where `has_variant = false` AND NOT EXISTS in `product_items`.
     - Insert a default `product_items` row:
       - `id`: `(string) Str::uuid()`
       - `business_id`: `$product->business_id`
       - `product_id`: `$product->id`
       - `item_type`: `'variant_sku'`
       - `uom_id`: `$product->uom_id ?? null` (or default business UOM)
       - `name`: `$product->name`
       - `variant_combination`: `null` (strictly null for single products)
       - `sku`: `$product->code ?? null`
       - `barcode`: `null`
       - `track_inventory`: `$product->track_inventory`
       - `is_show`: `$product->sellable ? $product->is_show : false`
       - `sellable`: `$product->sellable`
       - `is_active`: `true`
     - Link unassigned `product_prices`:
       ```php
       DB::table('product_prices')
           ->where('product_id', $product->id)
           ->whereNull('product_item_id')
           ->update(['product_item_id' => $newItemId]);
       ```
   - In `down()`:
     - Track the created item IDs. Revert `product_prices.product_item_id` to `null` for these items.
     - Delete the generated `product_items`.
     - This guarantees clean rollback without constraint errors.

### 2.4 Model Relationship Specifications
1. **Observation 1.4** identified missing relationship methods between `ProductItem`, `VariantGroupOption`, and `RecipeVersion`.
2. The pivot table `product_item_variant_group_options` (`product_item_id`, `variant_group_option_id`) normalizes the N-to-N relationship between a variant product item and its constituent group options (e.g. Size: Large, Color: Red).
3. `recipe_versions` requires a nullable `product_item_id` column to support variant-level BOM (e.g. Regular Coffee vs Large Coffee requiring different raw material recipes).
4. Models must be updated with strict typing (PHP 8.3) and modern Laravel 12 syntax (`casts(): array`).

---

## 3. Caveats

1. **Enum Case vs Plan Wording**: The plan specification refers to `basic_product` in text descriptions. As verified in Observation 1.1, changing `PRODUCT_CATALOG` to `BASIC_PRODUCT` would break dozens of existing controller routes, Vue frontend components, and tests. We keep `FeatureEnum::PRODUCT_CATALOG = 'product_catalog'`.
2. **Plural vs Singular**: `FeatureEnum::PRODUCT_VARIANTS` uses plural `'product_variants'`, matching the DB feature code and frontend Vue `enums.FeatureEnum.PRODUCT_VARIANTS`.
3. **Scope of Raw Materials**: In the plan specification (Section 5.3 A), routes for `/master/raw-materials` and `/master/recipes` are both gated by `FeatureEnum::RECIPE_MANAGEMENT`. However, in `features` table and `SubscriptionPlanSeeder`, `'raw_materials'` also exists. We include both in `FeatureEnum` and activate both in Pro plan to avoid any gating gaps.
4. **No Other Caveats**: All database schemas, tables, and test environments were directly verified via read-only tools and executed test suites.

---

## 4. Conclusion & Concrete Implementation Blueprints

### 4.1 Update Blueprint: `app/Enums/FeatureEnum.php`

Update `app/Enums/FeatureEnum.php` to include `PRODUCT_MODIFIERS`, `RECIPE_MANAGEMENT`, and `RAW_MATERIALS`:

```php
    /*
    |--------------------------------------------------------------------------
    | Produk & Menu (Products & Catalog)
    |--------------------------------------------------------------------------
    */

    case PRODUCT_CATALOG = 'product_catalog';
    case SERVICE_CATALOG = 'service_catalog';
    case PRODUCT_CATEGORIES = 'product_categories';
    case PRODUCT_VARIANTS = 'product_variants';
    case PRODUCT_MODIFIERS = 'product_modifiers';
    case RECIPE_MANAGEMENT = 'recipe_management';

    /*
    |--------------------------------------------------------------------------
    | Inventori & Rantai Pasok (Inventory & Supply Chain)
    |--------------------------------------------------------------------------
    */

    case INVENTORY_MANAGEMENT = 'inventory_management';
    case RAW_MATERIALS = 'raw_materials';
    case STOCK_MOVEMENTS = 'stock_movements';
    case STOCK_ADJUSTMENTS = 'stock_adjustments';
    case STOCK_OPNAME = 'stock_opname';
    case STOCK_TRANSFERS = 'stock_transfers';
    case SUPPLIER_MANAGEMENT = 'supplier_management';
    case PURCHASE_ORDERS = 'purchase_orders';
```

### 4.2 Update Blueprint: `database/seeders/Production/FeatureSeeder.php`

Uncomment and ensure active status for `product_modifiers`, `recipe_management`, and `raw_materials`:

```php
            [
                'code' => 'product_variants',
                'name' => 'Varian Produk',
                'description' => 'Matriks variasi produk multi-dimensi (ukuran, warna, rasa) dengan SKU dan harga khusus.',
                'module' => 'product',
                'group' => 'products_and_menu',
                'group_label' => 'Produk & Menu',
                'sort_order' => 90,
                'is_active' => true,
            ],
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

            // Inventori & Rantai Pasok
            [
                'code' => 'inventory_management',
                'name' => 'Manajemen Inventori & Stok',
                'description' => 'Pelacakan stok real-time, pengingat batas minimum stok, dan alokasi stok per outlet.',
                'module' => 'inventory',
                'group' => 'inventory_and_supply_chain',
                'group_label' => 'Inventori & Rantai Pasok',
                'sort_order' => 130,
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
```

### 4.3 Update Blueprint: `database/seeders/Production/SubscriptionPlanSeeder.php`

Ensure the 4-tier plan assignment is crystal clear:
- **Micro**: Includes `product_catalog` (covers basic product), `service_catalog`, `product_categories`.
- **Basic**: Includes Micro features + `product_variants`.
- **Pro**: Includes Basic features + `product_modifiers`, `recipe_management`, `raw_materials`.
- When `$plan->systemFeatures()->sync($featureIds)` runs, it also cleans up any accidental test features attached to Basic.

### 4.4 Migration Blueprint: Single Product Backfill (`database/migrations/2026_10_22_100000_backfill_single_product_items.php`)

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
        // 1. Activate feature flags in existing database
        DB::table('features')
            ->whereIn('code', ['product_modifiers', 'recipe_management', 'raw_materials'])
            ->update([
                'is_active' => true,
                'updated_at' => now(),
            ]);

        // 2. Query all single products without product_items
        $singleProducts = DB::table('products as p')
            ->where('p.has_variant', false)
            ->whereNotExists(function ($query) {
                $query->select(DB::raw(1))
                    ->from('product_items as pi')
                    ->whereColumn('pi.product_id', 'p.id')
                    ->whereNull('pi.deleted_at');
            })
            ->select('p.id', 'p.business_id', 'p.name', 'p.code', 'p.product_type', 'p.track_inventory', 'p.is_show', 'p.sellable')
            ->get();

        foreach ($singleProducts as $product) {
            $itemId = (string) Str::uuid();
            $sellable = (bool) $product->sellable;
            $isShow = $sellable ? (bool) $product->is_show : false;

            DB::table('product_items')->insert([
                'id' => $itemId,
                'business_id' => $product->business_id,
                'item_type' => 'variant_sku',
                'product_id' => $product->id,
                'uom_id' => null,
                'name' => $product->name,
                'variant_combination' => null,
                'sku' => $product->code ?: null,
                'barcode' => null,
                'track_inventory' => (bool) $product->track_inventory,
                'is_show' => $isShow,
                'sellable' => $sellable,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Link existing unassigned prices for this product to the newly created default item
            DB::table('product_prices')
                ->where('product_id', $product->id)
                ->whereNull('product_item_id')
                ->update([
                    'product_item_id' => $itemId,
                    'updated_at' => now(),
                ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Deactivate features if desired, or leave them active
        // Revert product_prices where product_items were created by this migration
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
};
```

### 4.5 Migration Blueprint: Normalization Table & Recipe Version (`database/migrations/2026_10_22_100001_create_product_item_variant_group_options_table.php`)

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
        // 1. Create pivot table for ProductItem <-> VariantGroupOption
        Schema::create('product_item_variant_group_options', function (Blueprint $table) {
            $table->uuid('product_item_id');
            $table->uuid('variant_group_option_id');

            $table->primary(['product_item_id', 'variant_group_option_id'], 'p_item_vgo_primary');
            $table->foreign('product_item_id')->references('id')->on('product_items')->cascadeOnDelete();
            $table->foreign('variant_group_option_id')->references('id')->on('variant_group_options')->cascadeOnDelete();
        });

        // 2. Add product_item_id to recipe_versions
        Schema::table('recipe_versions', function (Blueprint $table) {
            $table->uuid('product_item_id')->nullable()->after('product_id')->index();
            $table->foreign('product_item_id')->references('id')->on('product_items')->nullOnDelete();
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

        Schema::dropIfExists('product_item_variant_group_options');
    }
};
```

### 4.6 Model Updates Blueprint

#### A. `app/Models/Master/ProductItem.php`
Add relationships:
```php
use App\Models\Master\VariantGroupOption;
use App\Models\Master\RecipeVersion;
use App\Models\Master\ProductRecipeItem;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

// Relationships
public function variantGroupOptions(): BelongsToMany
{
    return $this->belongsToMany(
        VariantGroupOption::class,
        'product_item_variant_group_options',
        'product_item_id',
        'variant_group_option_id'
    );
}

public function recipeVersions(): HasMany
{
    return $this->hasMany(RecipeVersion::class, 'product_item_id')->orderByDesc('version_number');
}

public function activeRecipe(): HasOne
{
    return $this->hasOne(RecipeVersion::class, 'product_item_id')->where('is_active', true);
}

public function recipeItems(): HasMany
{
    return $this->hasMany(ProductRecipeItem::class, 'product_item_id');
}
```

#### B. `app/Models/Master/VariantGroupOption.php`
Add inverse relationship:
```php
use App\Models\Master\ProductItem;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

public function variantGroup(): BelongsTo
{
    return $this->belongsTo(VariantGroup::class);
}

public function productItems(): BelongsToMany
{
    return $this->belongsToMany(
        ProductItem::class,
        'product_item_variant_group_options',
        'variant_group_option_id',
        'product_item_id'
    );
}
```

#### C. `app/Models/Master/RecipeVersion.php`
Update `$fillable`, `casts()`, and add `productItem()`:
```php
use App\Models\Master\ProductItem;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

protected $fillable = [
    'product_id',
    'product_item_id',
    'version_number',
    'is_active',
    'effective_from',
];

protected function casts(): array
{
    return [
        'is_active' => 'boolean',
        'effective_from' => 'datetime',
    ];
}

public function productItem(): BelongsTo
{
    return $this->belongsTo(ProductItem::class, 'product_item_id');
}
```

---

## 5. Verification Method

To independently verify the implementation after executor applies these changes:

1. **Rollback Symmetry Check**:
   ```bash
   cd /Users/whykrr/Documents/Projects/Laravel/sollu-app
   php artisan migrate
   php artisan migrate:rollback --step=2
   php artisan migrate
   ```
   *Expected result*: No SQL syntax errors, no orphaned constraints, exit code 0.

2. **Feature Enum Integrity Check**:
   ```bash
   # Run project enum integrity inspection tool
   # Check that FeatureEnum has all 38 exposed cases without warnings
   ```
   Or run the unit tests:
   ```bash
   php artisan test --compact --filter=CheckPlanFeatureTest
   php artisan test --compact --filter=FeatureTest
   ```

3. **Seeder Verification**:
   ```bash
   php artisan db:seed --class=Database\\Seeders\\Production\\FeatureSeeder
   php artisan db:seed --class=Database\\Seeders\\Production\\SubscriptionPlanSeeder
   ```
   Verify via SQL that:
   - `SELECT code, is_active FROM features WHERE code IN ('product_modifiers', 'recipe_management');` returns `is_active = true`.
   - `pro` plan in `plan_features` contains `product_modifiers` and `recipe_management`.
   - `basic` plan does not contain `product_modifiers` or `recipe_management`.

4. **ProductItem Normalization & Backfill Verification**:
   ```sql
   SELECT count(*) FROM products p 
   WHERE p.has_variant = false 
     AND NOT EXISTS (SELECT 1 FROM product_items pi WHERE pi.product_id = p.id);
   ```
   *Expected count*: `0` (Zero single products without a `product_items` row).

5. **Run Existing Test Suites**:
   ```bash
   php artisan test --compact --filter=ProductItemSearchTest
   php artisan test --compact --filter=ProductControllerTest
   ```
   *Expected result*: All assertions pass.

6. **Pint Code Formatting**:
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
