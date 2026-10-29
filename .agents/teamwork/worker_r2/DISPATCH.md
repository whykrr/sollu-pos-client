## 2026-10-22T11:11:39Z

You are worker_r2 implementing Milestone R2 (Service Layer, Feature Gating & Sync API in sollu-app).
Your working directory is:
/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r2/

Target workspace: /Users/whykrr/Documents/Projects/Laravel/sollu-app

Read and follow all instructions in:
- ORIGINAL_REQUEST.md: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md
- Plan Specification: /Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md
- Project Scope: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/orchestrator_1/PROJECT.md
- Rules: /Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md
- Explorer Findings:
  - ProductService & Inventory Decoupling: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r2_1/handoff.md
  - Controllers & Gating: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r2_2/handoff.md
  - MasterDataSync & Test Suites: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r2_3/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Exclusively Owned Files:
- app/Services/App/Master/ProductService.php
- app/Models/Master/Product.php
- app/Models/Master/ProductItem.php
- app/Http/Controllers/App/Master/ProductController.php
- app/Http/Controllers/App/Master/ModifierGroupController.php
- app/Http/Controllers/App/Master/RawMaterialController.php
- app/Http/Controllers/App/Master/RecipeTemplateController.php
- app/Services/App/Inventory/RawMaterialService.php
- app/Services/App/Master/RecipeService.php
- app/Services/App/Transaction/MasterDataSyncService.php
- routes/app/masters.php
- tests/Feature/Master/ProductManagementTest.php
- tests/Feature/Master/ProductFeatureGatingTest.php
- tests/Feature/API/MasterDataSyncTest.php
- tests/Feature/Master/ProductControllerTest.php
- tests/Feature/Master/ServiceProductControllerTest.php

Detailed Tasks to Execute:
1. `app/Services/App/Master/ProductService.php`:
   - Follow the complete drop-in blueprint in `explorer_r2_1/handoff.md §4.1`.
   - Invariant: Enforce causality rule `$isShow = $sellable ? (bool) ($data['is_show'] ?? true) : false;`.
   - Unified Item Pattern:
     - For single products (`has_variant = false`): ALWAYS create/update exactly 1 default `ProductItem` with `variant_combination = null`, `sku = code ?: generated`, and link `product_prices.product_item_id`.
     - For variant products (`has_variant = true`): call `createVariantMatrix` / `updateVariantMatrix`. Crucially, populate the normalized pivot table `product_item_variant_group_options` for each variant item matching `$optIds`!
   - Decoupled inventory: ONLY create `inventory_items` and `inventory_balances` via `inventoryService->linkInventoryItem` when `$product->track_inventory = true`. When `false`, do NOT create inventory records.
   - Implement `deleteProduct` and `deleteService` cascading soft delete to child `ProductItem`s, deactivating linked `InventoryItem`s, and writing `AuditLogService` entries.
2. `app/Models/Master/Product.php` & `ProductItem.php`:
   - Add model event listener `static::saving(...)` to guarantee `if (! $model->sellable) { $model->is_show = false; }`.
   - Ensure relationships `variantGroupOptions()` (belongsToMany) and `recipeVersions()` (hasMany) exist on `ProductItem`.
3. `app/Http/Controllers/App/Master/ProductController.php`:
   - Update `destroy(Product $product)` to invoke `$this->productService->deleteProduct($product)`.
4. `app/Http/Controllers/App/Master/ModifierGroupController.php`:
   - Clean up multi-tenant leak in `store()`: remove fallback to `Business::first()->id`.
5. Create `app/Http/Controllers/App/Master/RawMaterialController.php` & `RecipeTemplateController.php`:
   - Follow blueprints in `explorer_r2_2/handoff.md §4.2 & §4.3`.
   - In RawMaterialController: strictly enforce `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, `track_inventory = true`.
   - Update `RawMaterialService.php` to also ensure `sellable = false` and `is_show = false` on raw materials.
   - In RecipeTemplateController: manage recipe versions, items, and HPP calculation. Update `RecipeService.php` with `syncVariantRecipes`.
6. `routes/app/masters.php`:
   - Follow blueprint in `explorer_r2_2/handoff.md §4.1`:
     - Activate `modifiers` resource route under `Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)`.
     - Add `raw-materials` and `recipes` routes under `Route::middleware('plan.feature:'.FeatureEnum::RECIPE_MANAGEMENT->value)`.
7. `app/Services/App/Transaction/MasterDataSyncService.php`:
   - Follow blueprint in `explorer_r2_3/handoff.md §4.1`:
     - Export `product_items` and `product_item_variant_group_options` in the sync payload.
     - Restore backward-compatible `inventory_item_variant_group_options` via join with `inventory_items`.
8. Fix Legacy Tests `ProductControllerTest.php` & `ServiceProductControllerTest.php`:
   - Follow blueprint in `explorer_r2_3/handoff.md §4.2`:
     - In `setUp()`, attach an active Pro subscription to `$this->business` and ensure `BusinessType` features do not restrict product/service catalogs.
9. Create Automated Feature Tests:
   - Create `tests/Feature/Master/ProductManagementTest.php` (blueprint in `explorer_r2_3/handoff.md §4.3`).
   - Create `tests/Feature/Master/ProductFeatureGatingTest.php` (blueprint in `explorer_r2_3/handoff.md §4.4`).
   - Create `tests/Feature/API/MasterDataSyncTest.php` (blueprint in `explorer_r2_3/handoff.md §4.5`).
10. Verification:
   - Run tests:
     `php artisan test --compact --filter=ProductManagementTest`
     `php artisan test --compact --filter=ProductFeatureGatingTest`
     `php artisan test --compact --filter=MasterDataSyncTest`
     `php artisan test --compact --filter=ProductControllerTest`
     `php artisan test --compact --filter=ServiceProductControllerTest`
   - Run Pint code formatter: `vendor/bin/pint --dirty --format agent`
