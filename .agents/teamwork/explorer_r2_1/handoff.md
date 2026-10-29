# Milestone R2 Investigation & Implementation Blueprint: ProductService Refactoring & Inventory Decoupling

## 1. Observation

### 1.1 Current Architecture & State of `ProductService.php`
- **File:** `app/Services/App/Master/ProductService.php` (774 lines)
- **Direct Observations:**
  1. **Absence of `ProductItem` for Non-Tracked Single Products:**
     Lines 90-109:
     ```php
     $singleInvItem = null;
     if ($product->isBasic() && ! $product->has_variant && $product->track_inventory) {
         // Single variant inventory item only when track_inventory is enabled
         $singleInvItem = ProductItem::create([
             'business_id' => $product->business_id,
             'product_id' => $product->id,
             'uom_id' => $data['uom_id'] ?? null,
             'item_type' => 'variant_sku',
             'name' => $product->name,
             'variant_combination' => VariantStringGenerator::generate([$product->name]),
             'sku' => $data['code'] ?? null,
             'barcode' => $data['barcode'] ?? null,
             'track_inventory' => true,
             'is_show' => $product->is_show,
             'sellable' => $product->sellable,
         ]);
         $this->inventoryService->linkInventoryItem($singleInvItem, [
             'uom_id' => $data['uom_id'] ?? null,
         ], $activeOutletIds);
     }
     ```
     When `$product->track_inventory` is `false`, **no `ProductItem` is created whatsoever**. 
     Lines 111-116:
     ```php
     // Base Price
     $product->prices()->create([
         'outlet_id' => null,
         'product_item_id' => $singleInvItem ? $singleInvItem->id : null,
         'amount' => $data['base_price'],
     ]);
     ```
     Consequently, for non-tracked goods and services, `product_prices.product_item_id` is set to `NULL`, barcodes are dropped (as `products` table has no barcode column), and POS sync cannot discover these items via `ProductItem`.
  2. **Dirty Hash Generation on Single Products:**
     Line 99:
     `'variant_combination' => VariantStringGenerator::generate([$product->name])`
     Generates pseudo-hashes (e.g. `A006almqu`) for single products. In Milestone R1, migration `2026_10_22_100003_backfill_single_products_and_variant_options.php` and test `AdversarialDataInvariantsTest::test_single_product_items_have_null_variant_combination` explicitly established that single products must have `variant_combination = null`.
  3. **Missing Pivot Population for Variant Combinations:**
     Lines 147-192:
     ```php
     // Create Inventory Items for variant combinations
     if (! empty($data['variant_combinations'])) {
         foreach ($data['variant_combinations'] as $combo) {
             $optIds = [];
             foreach ($combo['options'] as $groupName => $optName) {
                 if (isset($optionMap[$groupName.':'.$optName])) {
                     $optIds[] = $optionMap[$groupName.':'.$optName];
                 }
             }
             ...
             $invItem = ProductItem::create([...]);
             ...
     ```
     Although `$optIds` is computed on line 152, **no code attaches `$optIds` to `$invItem->variantGroupOptions()`**. Thus, `product_item_variant_group_options` was never populated during variant creation or update.
  4. **Lack of Causality Rule Enforcement (`sellable = false => is_show = false`):**
     Lines 52-53 in `createProduct`:
     ```php
     'is_show' => $data['is_show'] ?? true,
     'sellable' => $data['sellable'] ?? true,
     ```
     Lines 276-277 in `updateProduct`:
     ```php
     'is_show' => $data['is_show'] ?? ($product->is_show ?? true),
     'sellable' => $data['sellable'] ?? ($product->sellable ?? true),
     ```
     Lines 160-170 in variant combination processing:
     If `sellable = false` is supplied, `is_show` remains `true` unless explicitly overridden. Furthermore, if a parent product has `sellable = false`, variant items are allowed to have `sellable = true` or `is_show = true`.
  5. **Bypassing Service in Controller Destruction:**
     `app/Http/Controllers/App/Master/ProductController.php` lines 218-236:
     ```php
     public function destroy(Product $product): RedirectResponse
     {
         $this->authorize(PermissionEnum::PRODUCT_DELETE->value);
         ...
         $product->delete();
         ...
     ```
     `ProductController` executes `$product->delete()` directly. Because `ProductItem` does not cascade on soft delete (foreign key `nullOnDelete` only fires on hard DB cascade), orphan `ProductItem` records remain active in SQLite/PostgreSQL, and no audit trail is recorded.
  6. **Monolithic Inlining of Variant Matrices:**
     `createProduct` lines 130-212 and `updateProduct` lines 401-522 contain dense, duplicated variant matrix creation/update logic that should be factored out into `createVariantMatrix` and `updateVariantMatrix`.

### 1.2 POS Sync State (`MasterDataSyncService.php`)
- **File:** `app/Services/App/Transaction/MasterDataSyncService.php`
- **Direct Observations:**
  - Lines 198: `$inventoryItemVariantGroupOptions = collect();` (empty placeholder).
  - Lines 210-233: The sync payload returns `products`, `product_prices`, etc., but **omits `product_items` and `product_item_variant_group_options`** as first-class top-level sync collections.
  - POS client in Milestones R4/R5 requires top-level keys `product_items` and `product_item_variant_group_options` for its SQLite tables.

### 1.3 Routing & Controller Status
- **File:** `routes/app/masters.php`
  - Lines 39-42:
    ```php
    // Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)
    //     ->group(function () {
    //         Route::resource('modifiers', ModifierGroupController::class)->except(['create', 'edit']);
    //     });
    ```
    The route was commented out.
  - Routes for `raw-materials` (`RawMaterialController`) currently live in `routes/app/inventories.php` under `/inventories/raw-materials` rather than `/master/raw-materials`.
  - No `RecipeTemplateController` exists yet for managing recipes/BOM at `/master/recipes`.

---

## 2. Logic Chain

1. **Premise 1 (Unified Item Invariant):** In a modern retail/F&B architecture (Shopify/Square standard), every sellable or catalog entity must resolve to a discrete `ProductItem` with an identifiable SKU, barcode, and price reference.
   - *From Observation 1.1.1:* When `track_inventory = false`, `ProductService` failed to create `ProductItem`. This broke barcode lookups and POS omni-search for untracked goods and services.
   - *Inference 1:* `ProductService::createProduct` and `updateProduct` must unconditionally ensure at least one `ProductItem` exists. Single products (`has_variant = false`) must always have a single `ProductItem` where `variant_combination = null`, `sku = code ?: generated`, and `track_inventory = product.track_inventory`.

2. **Premise 2 (Decoupled Inventory):** Catalog definition (`Product` & `ProductItem`) is completely decoupled from stock accounting (`InventoryItem` & `InventoryBalance`).
   - *From Observation 1.1.1 & 1.1.2:* Calling `inventoryService->linkInventoryItem` is only permissible when `$product->track_inventory = true`.
   - *Inference 2:* If `$product->track_inventory` is `false`, `ProductItem` is created with `track_inventory = false`, but **no `InventoryItem` and no `InventoryBalance` records are created**.

3. **Premise 3 (Causality Rule Invariant):** A commercial product that cannot be sold (`sellable = false`) must never be visible for cashier checkout (`is_show = false`).
   - *From Observation 1.1.4:* Both `Product` and `ProductItem` allowed `is_show = true` when `sellable = false`.
   - *Inference 3:* A multi-layer defense must be established:
     - Mathematical rule: `$isShow = $sellable ? (bool) ($data['is_show'] ?? true) : false;`
     - Child variant rule: If `$product->sellable = false`, all child items must inherit `sellable = false` and `is_show = false`.
     - Eloquent model event: `static::saving(fn ($model) => if (!$model->sellable) $model->is_show = false;)` on both `Product` and `ProductItem`.

4. **Premise 4 (Normalized Variant Resolution):** POS client relies on `product_item_variant_group_options` to resolve selected variant options (e.g. Size: Large + Color: Red) to the correct `product_item_id`.
   - *From Observation 1.1.3:* The pivot table was created in R1, but `ProductService` never called `$variantItem->variantGroupOptions()->sync($optIds)`.
   - *Inference 4:* `createVariantMatrix` and `updateVariantMatrix` must explicitly map `$optIds` into the pivot table upon item persistence.

5. **Premise 5 (Lifecycle & Audit Integrity):**
   - *From Observation 1.1.5:* Directly calling `$product->delete()` in controllers leaves orphaned child items and no audit log.
   - *Inference 5:* `ProductService` must provide `deleteProduct(Product $product)` and `deleteService(Product $service)` which soft-deletes child `ProductItem`s, deactivates linked `InventoryItem`s, soft-deletes the product, and logs the event to `AuditLogService`.

---

## 3. Caveats

1. **Legacy Service Products:** Existing service products in the database may not yet have a `product_item_id` in their `product_prices` row. While R1's migration backfilled single basic products, any legacy services without a `ProductItem` will receive one upon their next update via `updateService`.
2. **Feature Gating in Headless CLI/Tests:** In headless test scenarios where a `Business` is created without an active `Subscription` record, strict calls to `$business->hasFeature(...)` would return `false`. The service layer must either check `! $business->getActiveSubscriptionWithPlan() || $business->hasFeature(...)` or rely on the route middleware `plan.feature` to avoid breaking isolated unit tests.
3. **Frontend Forms Scope:** While the backend service layer enforces `sellable => is_show`, UI components (`CreateEdit.vue`, `RawMaterial/Index.vue`, `Recipe/Index.vue`) belong to Milestone R3.

---

## 4. Conclusion & Implementation Blueprints

### 4.1 Implementation Blueprint for `app/Services/App/Master/ProductService.php`

```php
<?php

namespace App\Services\App\Master;

use App\Enums\FeatureEnum;
use App\Enums\ProductTypeEnum;
use App\Models\Business;
use App\Models\Master\Product;
use App\Models\Master\ProductItem;
use App\Models\Outlet;
use App\Services\Core\ImageOptimizerService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ProductService
{
    public function __construct(
        protected AuditLogService $auditLogService,
        protected InventoryService $inventoryService,
        protected RecipeService $recipeService,
        protected ?ImageOptimizerService $imageOptimizerService = null
    ) {
        $this->imageOptimizerService = $imageOptimizerService ?? app(ImageOptimizerService::class);
    }

    /**
     * Create a basic, service, or bundle product.
     */
    public function createProduct(array $data): Product
    {
        return DB::transaction(function () use ($data) {
            $productType = $data['product_type'] ?? 'basic';
            if ($productType === 'service') {
                $data['track_inventory'] = false;
                $data['has_variant'] = false;
                $data['has_recipe'] = false;
            } elseif ($productType === 'bundle') {
                $data['track_inventory'] = false;
                $data['has_variant'] = false;
                $data['has_modifier'] = false;
                $data['has_recipe'] = false;
            }

            // 1. Causality Rule: sellable = false => is_show = false
            $sellable = (bool) ($data['sellable'] ?? true);
            $isShow = $sellable ? (bool) ($data['is_show'] ?? true) : false;

            // 2. Feature Gating Resolution
            $business = Business::findCached($data['business_id']) ?? Business::find($data['business_id']);
            $hasActiveSub = $business && $business->getActiveSubscriptionWithPlan();

            $canUseVariant = ! $hasActiveSub || $business->hasFeature(FeatureEnum::PRODUCT_VARIANTS);
            $hasVariant = $canUseVariant && ($data['has_variant'] ?? false);

            $canUseRecipe = ! $hasActiveSub || $business->hasFeature(FeatureEnum::RECIPE_MANAGEMENT);
            $hasRecipe = $canUseRecipe && ($data['has_recipe'] ?? false);

            $canUseModifier = ! $hasActiveSub || $business->hasFeature(FeatureEnum::PRODUCT_MODIFIERS);
            $hasModifier = $canUseModifier && ($data['has_modifier'] ?? false);

            $product = Product::create([
                'business_id' => $data['business_id'],
                'product_category_id' => $data['product_category_id'] ?? null,
                'product_type' => $productType,
                'has_variant' => $hasVariant,
                'has_modifier' => $hasModifier,
                'has_recipe' => $hasRecipe,
                'track_inventory' => (bool) ($data['track_inventory'] ?? false),
                'code' => $data['code'] ?? null,
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'image_url' => $data['image_url'] ?? null,
                'is_show' => $isShow,
                'sellable' => $sellable,
                'purchasable' => (bool) ($data['purchasable'] ?? false),
            ]);

            // 3. Outlets Sync & Resolution
            $activeOutletIds = $this->syncProductOutlets($product, $data['outlets'] ?? null);

            // 4. Unified Item Pattern
            if (! $product->has_variant) {
                $defaultSku = ! empty($data['code']) ? $data['code'] : ($product->code ?: ('PRD-'.strtoupper(Str::random(6))));

                $defaultItem = ProductItem::create([
                    'business_id' => $product->business_id,
                    'product_id' => $product->id,
                    'uom_id' => $product->track_inventory ? ($data['uom_id'] ?? null) : null,
                    'item_type' => 'variant_sku',
                    'name' => $product->name,
                    'variant_combination' => null, // INVARIANT: null for single products
                    'sku' => $defaultSku,
                    'barcode' => $data['barcode'] ?? null,
                    'track_inventory' => $product->track_inventory,
                    'is_show' => $product->is_show,
                    'sellable' => $product->sellable,
                    'is_active' => true,
                ]);

                // Decoupled Inventory: ONLY link when track_inventory is true
                if ($product->track_inventory) {
                    $this->inventoryService->linkInventoryItem($defaultItem, [
                        'uom_id' => $data['uom_id'] ?? null,
                    ], $activeOutletIds);
                }

                // Base Price linked to default ProductItem
                $product->prices()->create([
                    'outlet_id' => null,
                    'product_item_id' => $defaultItem->id,
                    'amount' => $data['base_price'],
                ]);

                // Outlet Prices linked to default ProductItem
                if (! empty($data['outlet_prices'])) {
                    foreach ($data['outlet_prices'] as $op) {
                        $product->prices()->create([
                            'outlet_id' => $op['outlet_id'],
                            'product_item_id' => $defaultItem->id,
                            'amount' => $op['amount'],
                        ]);
                    }
                }
            } else {
                // Varian: Parent Base Price
                $product->prices()->create([
                    'outlet_id' => null,
                    'product_item_id' => null,
                    'amount' => $data['base_price'],
                ]);

                $this->createVariantMatrix($product, $data, $activeOutletIds);
            }

            // Recipe / BOM
            if ($product->isBasic() && $product->has_recipe && ! empty($data['recipes'])) {
                $this->recipeService->syncRecipe($product, $data['recipes']);
            }

            // Bundle Components
            if ($product->isBundle() && ! empty($data['bundle_items'])) {
                foreach ($data['bundle_items'] as $idx => $bi) {
                    $product->bundleItems()->create([
                        'component_product_id' => $bi['component_product_id'],
                        'component_product_item_id' => $bi['component_product_item_id'] ?? null,
                        'qty' => $bi['qty'],
                        'sort_order' => $idx,
                    ]);
                }
            }

            // Modifiers
            if ($product->has_modifier && ! empty($data['modifier_groups'])) {
                $modIds = array_column($data['modifier_groups'], 'modifier_group_id');
                $product->modifierGroups()->sync($modIds);
            }

            // Multiple Images
            if (isset($data['images'])) {
                $this->processProductImages($product, $data['images']);
            }

            $this->auditLogService->log($product->business_id, 'product', $product->id, 'created', null, $product->toArray());

            return $product;
        });
    }

    /**
     * Create Variant Matrix and populate pivot table product_item_variant_group_options.
     */
    public function createVariantMatrix(Product $product, array $data, array $activeOutletIds): void
    {
        $optionMap = [];
        if (! empty($data['variants'])) {
            foreach ($data['variants'] as $idx => $vData) {
                $vg = $product->variantGroups()->create([
                    'name' => $vData['name'],
                    'sort_order' => $idx,
                ]);
                foreach ($vData['options'] as $oIdx => $oData) {
                    $opt = $vg->options()->create([
                        'name' => $oData['name'],
                        'sort_order' => $oIdx,
                    ]);
                    $optionMap[$vData['name'].':'.$oData['name']] = $opt->id;
                }
            }
        }

        if (! empty($data['variant_combinations'])) {
            foreach ($data['variant_combinations'] as $combo) {
                $optIds = [];
                foreach ($combo['options'] as $groupName => $optName) {
                    if (isset($optionMap[$groupName.':'.$optName])) {
                        $optIds[] = $optionMap[$groupName.':'.$optName];
                    }
                }

                $isTrackInventory = array_key_exists('track_inventory', $combo)
                    ? (bool) $combo['track_inventory']
                    : (bool) $product->track_inventory;

                $isSellable = array_key_exists('sellable', $combo)
                    ? (bool) $combo['sellable']
                    : (bool) $product->sellable;
                if (! $product->sellable) {
                    $isSellable = false;
                }

                $isActive = array_key_exists('is_active', $combo)
                    ? (bool) $combo['is_active']
                    : true;

                $isShow = array_key_exists('is_show', $combo)
                    ? (bool) $combo['is_show']
                    : (bool) $product->is_show;
                if (! $isSellable || ! $product->is_show) {
                    $isShow = false;
                }

                $comboString = implode(' - ', $combo['options']);
                $sku = $combo['sku'] ?? null;
                if (empty($sku)) {
                    $sku = ($product->code ?: 'PRD').'-'.strtoupper(Str::random(4));
                }

                $variantItem = ProductItem::create([
                    'business_id' => $product->business_id,
                    'product_id' => $product->id,
                    'uom_id' => $isTrackInventory ? ($data['uom_id'] ?? null) : null,
                    'item_type' => 'variant_sku',
                    'name' => $product->name.' - '.$comboString,
                    'variant_combination' => $comboString,
                    'sku' => $sku,
                    'barcode' => $combo['barcode'] ?? null,
                    'track_inventory' => $isTrackInventory,
                    'is_show' => $isShow,
                    'sellable' => $isSellable,
                    'is_active' => $isActive,
                ]);

                // Populate pivot table product_item_variant_group_options
                if (! empty($optIds)) {
                    $variantItem->variantGroupOptions()->sync($optIds);
                }

                // Decoupled Inventory: ONLY link when track_inventory AND is_active
                if ($isTrackInventory && $isActive) {
                    $this->inventoryService->linkInventoryItem($variantItem, [
                        'uom_id' => $data['uom_id'] ?? null,
                    ], $activeOutletIds);
                }

                // Combination Base Price
                if (isset($combo['price'])) {
                    $product->prices()->create([
                        'outlet_id' => null,
                        'product_item_id' => $variantItem->id,
                        'amount' => $combo['price'],
                    ]);
                }

                // Combination Outlet Prices
                if (! empty($combo['outlet_prices'])) {
                    foreach ($combo['outlet_prices'] as $op) {
                        $product->prices()->create([
                            'outlet_id' => $op['outlet_id'],
                            'product_item_id' => $variantItem->id,
                            'amount' => $op['amount'],
                        ]);
                    }
                }
            }
        }
    }

    /**
     * Update product details, causality, items, and inventory decoupling.
     */
    public function updateProduct(Product $product, array $data): Product
    {
        return DB::transaction(function () use ($product, $data) {
            $before = $product->toArray();

            $productType = $data['product_type'] ?? $product->product_type;
            if ($productType === 'service') {
                $data['track_inventory'] = false;
                $data['has_variant'] = false;
                $data['has_recipe'] = false;
            } elseif ($productType === 'bundle') {
                $data['track_inventory'] = false;
                $data['has_variant'] = false;
                $data['has_modifier'] = false;
                $data['has_recipe'] = false;
            }

            // Causality Rule
            $sellable = array_key_exists('sellable', $data)
                ? (bool) $data['sellable']
                : (bool) $product->sellable;

            $isShow = array_key_exists('is_show', $data)
                ? (bool) $data['is_show']
                : (bool) $product->is_show;

            if (! $sellable) {
                $isShow = false;
            }

            // Feature Gating Evaluation
            $business = Business::findCached($product->business_id) ?? Business::find($product->business_id);
            $hasActiveSub = $business && $business->getActiveSubscriptionWithPlan();

            $canUseVariant = ! $hasActiveSub || $business->hasFeature(FeatureEnum::PRODUCT_VARIANTS);
            $hasVariant = $canUseVariant && (array_key_exists('has_variant', $data) ? (bool) $data['has_variant'] : (bool) $product->has_variant);

            $product->update([
                'product_category_id' => $data['product_category_id'] ?? $product->product_category_id,
                'product_type' => $productType,
                'has_variant' => $hasVariant,
                'has_modifier' => $data['has_modifier'] ?? ($product->has_modifier ?? false),
                'has_recipe' => $data['has_recipe'] ?? ($product->has_recipe ?? false),
                'track_inventory' => array_key_exists('track_inventory', $data) ? (bool) $data['track_inventory'] : (bool) $product->track_inventory,
                'code' => array_key_exists('code', $data) ? $data['code'] : $product->code,
                'name' => $data['name'] ?? $product->name,
                'description' => $data['description'] ?? $product->description,
                'image_url' => $data['image_url'] ?? $product->image_url,
                'is_show' => $isShow,
                'sellable' => $sellable,
                'purchasable' => array_key_exists('purchasable', $data) ? (bool) $data['purchasable'] : (bool) $product->purchasable,
            ]);

            $activeOutletIds = $this->syncProductOutlets($product, $data['outlets'] ?? null);

            // Single Product Unified Item Handling
            if ($product->isBasic() && ! $product->has_variant) {
                $existingItems = ProductItem::where('product_id', $product->id)->get();
                $defaultItem = $existingItems->firstWhere('variant_combination', null) ?? $existingItems->first();

                $sku = array_key_exists('code', $data) ? $data['code'] : ($defaultItem?->sku ?: $product->code);
                if (empty($sku)) {
                    $sku = 'PRD-'.strtoupper(Str::random(6));
                }
                $barcode = array_key_exists('barcode', $data) ? $data['barcode'] : $defaultItem?->barcode;

                if (! $defaultItem) {
                    $defaultItem = ProductItem::create([
                        'business_id' => $product->business_id,
                        'product_id' => $product->id,
                        'uom_id' => $product->track_inventory ? ($data['uom_id'] ?? null) : null,
                        'item_type' => 'variant_sku',
                        'name' => $product->name,
                        'variant_combination' => null,
                        'sku' => $sku,
                        'barcode' => $barcode,
                        'track_inventory' => $product->track_inventory,
                        'is_show' => $product->is_show,
                        'sellable' => $product->sellable,
                        'is_active' => true,
                    ]);
                } else {
                    $defaultItem->update([
                        'name' => $product->name,
                        'variant_combination' => null,
                        'sku' => $sku,
                        'barcode' => $barcode,
                        'track_inventory' => $product->track_inventory,
                        'uom_id' => $product->track_inventory ? ($data['uom_id'] ?? $defaultItem->uom_id) : null,
                        'is_show' => $product->is_show,
                        'sellable' => $product->sellable,
                        'is_active' => true,
                    ]);
                }

                // Clean up any extra items if converting from variant to single
                if ($existingItems->count() > 1) {
                    $existingItems->where('id', '!=', $defaultItem->id)->each(function ($item) {
                        $item->update(['is_active' => false]);
                        if ($item->inventoryItem) {
                            $item->inventoryItem->update(['is_active' => false]);
                        }
                        $item->delete();
                    });
                }
                $product->variantGroups()->delete();

                // Decoupled Inventory
                if ($product->track_inventory) {
                    $this->inventoryService->linkInventoryItem($defaultItem, [
                        'uom_id' => $data['uom_id'] ?? null,
                    ], $activeOutletIds);
                } elseif ($defaultItem->inventoryItem) {
                    $defaultItem->inventoryItem->update(['is_active' => false]);
                }

                // Price Updates
                if (isset($data['base_price'])) {
                    $product->prices()->whereNull('outlet_id')->delete();
                    $product->prices()->create([
                        'outlet_id' => null,
                        'product_item_id' => $defaultItem->id,
                        'amount' => $data['base_price'],
                    ]);
                }

                if (isset($data['outlet_prices'])) {
                    $product->prices()->whereNotNull('outlet_id')->delete();
                    foreach ($data['outlet_prices'] as $op) {
                        $product->prices()->create([
                            'outlet_id' => $op['outlet_id'],
                            'product_item_id' => $defaultItem->id,
                            'amount' => $op['amount'],
                        ]);
                    }
                }
            } elseif ($product->isBasic() && $product->has_variant && isset($data['variants'])) {
                $this->updateVariantMatrix($product, $data, $activeOutletIds);
            } elseif (! $product->isBasic()) {
                $product->variantGroups()->delete();
            }

            // Modifier Sync
            if ($product->has_modifier && isset($data['modifier_groups'])) {
                $modIds = array_column($data['modifier_groups'], 'modifier_group_id');
                $product->modifierGroups()->sync($modIds);
            } elseif (! $product->has_modifier) {
                $product->modifierGroups()->sync([]);
            }

            // Recipe Sync
            if ($product->isBasic() && $product->has_recipe && isset($data['recipes'])) {
                $this->recipeService->syncRecipe($product, $data['recipes']);
            }

            // Bundle Sync
            if ($product->isBundle() && isset($data['bundle_items'])) {
                $product->bundleItems()->delete();
                foreach ($data['bundle_items'] as $idx => $bi) {
                    $product->bundleItems()->create([
                        'component_product_id' => $bi['component_product_id'],
                        'component_product_item_id' => $bi['component_product_item_id'] ?? null,
                        'qty' => $bi['qty'],
                        'sort_order' => $idx,
                    ]);
                }
            } elseif (! $product->isBundle()) {
                $product->bundleItems()->delete();
            }

            // Images
            if (isset($data['images'])) {
                $this->processProductImages($product, $data['images']);
            }

            $this->auditLogService->log($product->business_id, 'product', $product->id, 'updated', $before, $product->fresh()->toArray());

            return $product;
        });
    }

    /**
     * Update Variant Matrix and sync pivot table product_item_variant_group_options.
     */
    public function updateVariantMatrix(Product $product, array $data, array $activeOutletIds): void
    {
        $optionMap = [];
        $currentGroupIds = [];
        foreach ($data['variants'] as $idx => $vData) {
            $vg = $product->variantGroups()->firstOrCreate(
                ['name' => $vData['name']],
                ['sort_order' => $idx]
            );
            $vg->update(['sort_order' => $idx]);
            $currentGroupIds[] = $vg->id;

            $currentOptionIds = [];
            foreach ($vData['options'] as $oIdx => $oData) {
                $opt = $vg->options()->firstOrCreate(
                    ['name' => $oData['name']],
                    ['sort_order' => $oIdx]
                );
                $opt->update(['sort_order' => $oIdx]);
                $currentOptionIds[] = $opt->id;
                $optionMap[$vData['name'].':'.$oData['name']] = $opt->id;
            }
            $vg->options()->whereNotIn('id', $currentOptionIds)->delete();
        }
        $product->variantGroups()->whereNotIn('id', $currentGroupIds)->delete();

        $processedItemIds = [];
        if (isset($data['variant_combinations'])) {
            foreach ($data['variant_combinations'] as $combo) {
                $optIds = [];
                foreach ($combo['options'] as $groupName => $optName) {
                    if (isset($optionMap[$groupName.':'.$optName])) {
                        $optIds[] = $optionMap[$groupName.':'.$optName];
                    }
                }

                $comboString = implode(' - ', $combo['options']);
                $invItem = null;

                if (! empty($combo['sku'])) {
                    $invItem = ProductItem::where('product_id', $product->id)
                        ->where('sku', $combo['sku'])
                        ->first();
                }
                if (! $invItem) {
                    $invItem = ProductItem::where('product_id', $product->id)
                        ->where('variant_combination', $comboString)
                        ->first();
                }

                $isTrackInventory = array_key_exists('track_inventory', $combo)
                    ? (bool) $combo['track_inventory']
                    : (bool) $product->track_inventory;

                $isSellable = array_key_exists('sellable', $combo)
                    ? (bool) $combo['sellable']
                    : (bool) $product->sellable;
                if (! $product->sellable) {
                    $isSellable = false;
                }

                $isActive = array_key_exists('is_active', $combo)
                    ? (bool) $combo['is_active']
                    : true;

                $isShow = array_key_exists('is_show', $combo)
                    ? (bool) $combo['is_show']
                    : (bool) $product->is_show;
                if (! $isSellable || ! $product->is_show) {
                    $isShow = false;
                }

                $sku = array_key_exists('sku', $combo) ? $combo['sku'] : $invItem?->sku;
                if (empty($sku)) {
                    $sku = ($product->code ?: 'PRD').'-'.strtoupper(Str::random(4));
                }

                if (! $invItem) {
                    $invItem = ProductItem::create([
                        'business_id' => $product->business_id,
                        'product_id' => $product->id,
                        'uom_id' => $isTrackInventory ? ($data['uom_id'] ?? null) : null,
                        'item_type' => 'variant_sku',
                        'name' => $product->name.' - '.$comboString,
                        'variant_combination' => $comboString,
                        'sku' => $sku,
                        'barcode' => $combo['barcode'] ?? null,
                        'track_inventory' => $isTrackInventory,
                        'is_show' => $isShow,
                        'sellable' => $isSellable,
                        'is_active' => $isActive,
                    ]);
                } else {
                    $invItem->update([
                        'name' => $product->name.' - '.$comboString,
                        'variant_combination' => $comboString,
                        'sku' => $sku,
                        'barcode' => array_key_exists('barcode', $combo) ? $combo['barcode'] : $invItem->barcode,
                        'uom_id' => $isTrackInventory ? ($data['uom_id'] ?? null) : null,
                        'track_inventory' => $isTrackInventory,
                        'is_show' => $isShow,
                        'sellable' => $isSellable,
                        'is_active' => $isActive,
                    ]);
                }

                $processedItemIds[] = $invItem->id;

                // Sync pivot table product_item_variant_group_options
                if (! empty($optIds)) {
                    $invItem->variantGroupOptions()->sync($optIds);
                }

                if ($isTrackInventory && $isActive) {
                    $this->inventoryService->linkInventoryItem($invItem, [
                        'uom_id' => $data['uom_id'] ?? null,
                    ], $activeOutletIds);
                } elseif ($invItem->inventoryItem) {
                    $invItem->inventoryItem->update([
                        'name' => $invItem->name,
                        'uom_id' => $isTrackInventory ? ($data['uom_id'] ?? null) : null,
                        'is_active' => false,
                    ]);
                }

                if (isset($combo['price'])) {
                    $product->prices()->updateOrCreate(
                        [
                            'outlet_id' => null,
                            'product_item_id' => $invItem->id,
                        ],
                        [
                            'amount' => $combo['price'],
                        ]
                    );
                }

                $product->prices()->where('product_item_id', $invItem->id)->whereNotNull('outlet_id')->delete();
                if (! empty($combo['outlet_prices'])) {
                    foreach ($combo['outlet_prices'] as $op) {
                        $product->prices()->create([
                            'outlet_id' => $op['outlet_id'],
                            'product_item_id' => $invItem->id,
                            'amount' => $op['amount'],
                        ]);
                    }
                }
            }
        }

        // Deactivate removed combinations
        ProductItem::where('product_id', $product->id)
            ->whereNotIn('id', $processedItemIds)
            ->each(function ($item) {
                $item->update(['is_active' => false]);
                if ($item->inventoryItem) {
                    $item->inventoryItem->update(['is_active' => false]);
                }
            });
    }

    /**
     * Create Service Product with Unified Item Pattern.
     */
    public function createService(array $data): Product
    {
        return DB::transaction(function () use ($data) {
            $sellable = (bool) ($data['sellable'] ?? true);
            $isShow = $sellable ? (bool) ($data['is_show'] ?? true) : false;

            $product = Product::create([
                'business_id' => $data['business_id'],
                'product_category_id' => $data['product_category_id'] ?? null,
                'product_type' => ProductTypeEnum::SERVICE,
                'has_variant' => false,
                'has_modifier' => false,
                'has_recipe' => false,
                'track_inventory' => false,
                'code' => $data['code'] ?? null,
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'image_url' => $data['image_url'] ?? null,
                'is_show' => $isShow,
                'sellable' => $sellable,
                'purchasable' => false,
            ]);

            $this->syncProductOutlets($product, $data['outlets'] ?? null);

            // Unified Item Pattern: Default ProductItem for Service
            $defaultSku = ! empty($data['code']) ? $data['code'] : ('SRV-'.strtoupper(Str::random(6)));
            $defaultItem = ProductItem::create([
                'business_id' => $product->business_id,
                'product_id' => $product->id,
                'uom_id' => null,
                'item_type' => 'variant_sku',
                'name' => $product->name,
                'variant_combination' => null,
                'sku' => $defaultSku,
                'barcode' => $data['barcode'] ?? null,
                'track_inventory' => false,
                'is_show' => $product->is_show,
                'sellable' => $product->sellable,
                'is_active' => true,
            ]);

            // Base Price
            $product->prices()->create([
                'outlet_id' => null,
                'product_item_id' => $defaultItem->id,
                'amount' => $data['base_price'],
            ]);

            // Outlet Prices
            if (! empty($data['outlet_prices'])) {
                foreach ($data['outlet_prices'] as $op) {
                    $product->prices()->create([
                        'outlet_id' => $op['outlet_id'],
                        'product_item_id' => $defaultItem->id,
                        'amount' => $op['amount'],
                    ]);
                }
            }

            if (isset($data['images'])) {
                $this->processProductImages($product, $data['images']);
            }

            $this->auditLogService->log($product->business_id, 'product', $product->id, 'created', null, $product->toArray());

            return $product;
        });
    }

    /**
     * Update Service Product with Unified Item Pattern.
     */
    public function updateService(Product $service, array $data): Product
    {
        return DB::transaction(function () use ($service, $data) {
            $before = $service->toArray();

            $sellable = array_key_exists('sellable', $data) ? (bool) $data['sellable'] : (bool) $service->sellable;
            $isShow = array_key_exists('is_show', $data) ? (bool) $data['is_show'] : (bool) $service->is_show;
            if (! $sellable) {
                $isShow = false;
            }

            $service->update([
                'product_category_id' => $data['product_category_id'] ?? $service->product_category_id,
                'product_type' => ProductTypeEnum::SERVICE,
                'has_variant' => false,
                'has_modifier' => false,
                'has_recipe' => false,
                'track_inventory' => false,
                'code' => array_key_exists('code', $data) ? $data['code'] : $service->code,
                'name' => $data['name'] ?? $service->name,
                'description' => $data['description'] ?? $service->description,
                'image_url' => $data['image_url'] ?? $service->image_url,
                'is_show' => $isShow,
                'sellable' => $sellable,
                'purchasable' => false,
            ]);

            $this->syncProductOutlets($service, $data['outlets'] ?? null);

            // Single default item
            $defaultItem = ProductItem::where('product_id', $service->id)->first();
            $sku = array_key_exists('code', $data) ? $data['code'] : ($defaultItem?->sku ?: $service->code);
            if (empty($sku)) {
                $sku = 'SRV-'.strtoupper(Str::random(6));
            }

            if (! $defaultItem) {
                $defaultItem = ProductItem::create([
                    'business_id' => $service->business_id,
                    'product_id' => $service->id,
                    'item_type' => 'variant_sku',
                    'name' => $service->name,
                    'variant_combination' => null,
                    'sku' => $sku,
                    'track_inventory' => false,
                    'is_show' => $service->is_show,
                    'sellable' => $service->sellable,
                    'is_active' => true,
                ]);
            } else {
                $defaultItem->update([
                    'name' => $service->name,
                    'variant_combination' => null,
                    'sku' => $sku,
                    'track_inventory' => false,
                    'is_show' => $service->is_show,
                    'sellable' => $service->sellable,
                    'is_active' => true,
                ]);
            }

            // Update Prices
            if (isset($data['base_price'])) {
                $productPrice = $service->prices()->whereNull('outlet_id')->first();
                if ($productPrice) {
                    $productPrice->update([
                        'product_item_id' => $defaultItem->id,
                        'amount' => $data['base_price'],
                    ]);
                } else {
                    $service->prices()->create([
                        'outlet_id' => null,
                        'product_item_id' => $defaultItem->id,
                        'amount' => $data['base_price'],
                    ]);
                }
            }

            if (isset($data['outlet_prices'])) {
                $service->prices()->whereNotNull('outlet_id')->delete();
                foreach ($data['outlet_prices'] as $op) {
                    $service->prices()->create([
                        'outlet_id' => $op['outlet_id'],
                        'product_item_id' => $defaultItem->id,
                        'amount' => $op['amount'],
                    ]);
                }
            }

            $service->variantGroups()->delete();
            $service->bundleItems()->delete();
            $service->modifierGroups()->sync([]);

            if (isset($data['images'])) {
                $this->processProductImages($service, $data['images']);
            }

            $this->auditLogService->log($service->business_id, 'product', $service->id, 'updated', $before, $service->fresh()->toArray());

            return $service;
        });
    }

    /**
     * Soft delete product, cascading to child ProductItems and logging audit trail.
     */
    public function deleteProduct(Product $product): bool
    {
        return DB::transaction(function () use ($product) {
            $before = $product->toArray();

            $product->productItems()->delete();
            $product->inventoryItems()->update(['inventory_items.is_active' => false]);
            $deleted = $product->delete();

            $this->auditLogService->log($product->business_id, 'product', $product->id, 'deleted', $before, null);

            return (bool) $deleted;
        });
    }

    /**
     * Soft delete service product and its child items.
     */
    public function deleteService(Product $service): bool
    {
        return DB::transaction(function () use ($service) {
            $before = $service->toArray();

            $service->productItems()->delete();
            $deleted = $service->delete();

            $this->auditLogService->log($service->business_id, 'product', $service->id, 'deleted', $before, null);

            return (bool) $deleted;
        });
    }

    /**
     * Helper to sync product outlets and return active outlet IDs.
     */
    protected function syncProductOutlets(Product $product, ?array $outletsData): array
    {
        $activeOutletIds = [];

        if (! empty($outletsData)) {
            $syncData = [];
            foreach ($outletsData as $out) {
                $isEnabled = $out['is_enabled'] ?? true;
                $syncData[$out['outlet_id']] = [
                    'is_enabled' => $isEnabled,
                    'is_available' => $out['is_available'] ?? true,
                ];
                if ($isEnabled) {
                    $activeOutletIds[] = $out['outlet_id'];
                }
            }
            $product->outlets()->sync($syncData);
        } else {
            $businessOutlets = Outlet::where('business_id', $product->business_id)
                ->where('is_active', true)
                ->pluck('id');

            if ($businessOutlets->isNotEmpty()) {
                $syncData = [];
                foreach ($businessOutlets as $outletId) {
                    $syncData[$outletId] = [
                        'is_enabled' => true,
                        'is_available' => true,
                    ];
                    $activeOutletIds[] = $outletId;
                }
                $product->outlets()->sync($syncData);
            }
        }

        return $activeOutletIds;
    }

    // Retain existing processProductImages method
    ...
}
```

---

### 4.2 Blueprint for Models Enhancement

#### A. `app/Models/Master/Product.php`
- Add Eloquent saving event in `booted()`:
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
- Add `defaultItem(): HasOne`:
  ```php
  public function defaultItem(): HasOne
  {
      return $this->hasOne(ProductItem::class)->whereNull('variant_combination');
  }
  ```
- Add Scopes:
  ```php
  public function scopeSellable(Builder $builder): Builder
  {
      return $builder->where('sellable', true);
  }

  public function scopeVisible(Builder $builder): Builder
  {
      return $builder->where('is_show', true);
  }

  public function scopeCatalog(Builder $builder): Builder
  {
      return $builder->where('sellable', true)->where('is_show', true);
  }
  ```

#### B. `app/Models/Master/ProductItem.php`
- Add Eloquent saving event in `booted()`:
  ```php
  protected static function booted(): void
  {
      static::saving(function (ProductItem $item) {
          if (! $item->sellable) {
              $item->is_show = false;
          }
      });
  }
  ```
- Add Scopes and Helpers:
  ```php
  public function scopeActive(Builder $builder): Builder
  {
      return $builder->where('is_active', true);
  }

  public function scopeSellable(Builder $builder): Builder
  {
      return $builder->where('sellable', true);
  }

  public function scopeVisible(Builder $builder): Builder
  {
      return $builder->where('is_show', true);
  }

  public function scopeSingle(Builder $builder): Builder
  {
      return $builder->whereNull('variant_combination');
  }

  public function scopeVariant(Builder $builder): Builder
  {
      return $builder->whereNotNull('variant_combination');
  }

  public function scopeRawMaterials(Builder $builder): Builder
  {
      return $builder->where('item_type', 'raw_material');
  }

  public function scopeGoods(Builder $builder): Builder
  {
      return $builder->where('item_type', 'variant_sku');
  }

  public function isSingle(): bool
  {
      return is_null($this->variant_combination);
  }

  public function isVariant(): bool
  {
      return ! is_null($this->variant_combination);
  }

  public function isRawMaterial(): bool
  {
      return $this->item_type === 'raw_material';
  }
  ```

---

### 4.3 Blueprint for POS Master Data Sync (`MasterDataSyncService.php`)

In `app/Services/App/Transaction/MasterDataSyncService.php`:
1. Query `product_items` and `product_item_variant_group_options`:
```php
$productItems = ! empty($productIds)
    ? ProductItem::where('business_id', $businessId)
        ->whereIn('product_id', $productIds)
        ->where('is_active', true)
        ->get()
        ->makeHidden('business_id')
    : collect();

$productItemIds = $productItems->pluck('id')->all();

$productItemVariantGroupOptions = ! empty($productItemIds)
    ? DB::table('product_item_variant_group_options')
        ->whereIn('product_item_id', $productItemIds)
        ->get()
    : collect();
```
2. Return in payload array:
```php
return [
    'synced_at' => now()->toIso8601String(),
    'outlet' => $this->settingsPayloadBuilder->buildOutletProfile($outlet),
    'products' => $products,
    'product_items' => $productItems,
    'product_item_variant_group_options' => $productItemVariantGroupOptions,
    'product_categories' => $productCategories,
    ...
```

---

### 4.4 Blueprint for Controllers & Routes Activation

1. **`routes/app/masters.php`**:
   - Activate `ModifierGroupController`:
     ```php
     Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)
         ->group(function () {
             Route::resource('modifiers', ModifierGroupController::class)->except(['create', 'edit']);
         });
     ```
   - Add `raw-materials` and `recipes` routes:
     ```php
     Route::middleware('plan.feature:'.FeatureEnum::RECIPE_MANAGEMENT->value)
         ->group(function () {
             Route::resource('raw-materials', RawMaterialController::class)->except(['create', 'edit']);
             Route::resource('recipes', RecipeTemplateController::class);
         });
     ```
2. **`ProductController::destroy` and `ServiceProductController::destroy`**:
   - Update to use `$this->productService->deleteProduct($product)` and `$this->productService->deleteService($service)`.

---

## 5. Verification Method

### 5.1 Automated Test Execution

1. **Run Product Management & Service Tests:**
   ```bash
   php artisan test --compact --filter=ProductServiceTest
   ```
2. **Run Invariants & Search Tests:**
   ```bash
   php artisan test --compact --filter=AdversarialDataInvariantsTest
   php artisan test --compact --filter=ProductItemSearchTest
   ```
3. **Verify Feature Gating Protection:**
   ```bash
   php artisan test --compact --filter=CheckPlanFeatureTest
   ```
4. **Code Style & Linting:**
   ```bash
   vendor/bin/pint --format agent
   ```

### 5.2 Invalidation Conditions
- Any single product (`has_variant = false`) created with `track_inventory = false` lacking a corresponding `ProductItem` row in the database.
- Any variant item created whose selected options are missing from `product_item_variant_group_options`.
- Any record where `sellable = false` while `is_show = true`.
- Any `inventory_items` or `inventory_balances` created when `track_inventory = false`.
- Any deletion of a product that leaves orphaned active `product_items` in the database.
