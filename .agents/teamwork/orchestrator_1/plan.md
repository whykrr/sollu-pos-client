# Product Module Architectural Overhaul Plan

## Goal
Implement the unified Product Module overhaul across Laravel 12 backend (`sollu-app`) and Flutter POS client (`sollu-pos-client`) strictly following `product_module_architecture_plan.md` and `AGENTS.md`.

## Execution Milestones
### R1: Database Foundation, Seeders & Data Normalization (`sollu-app`)
- Pivot normalization table `product_item_variant_group_options` (`product_item_id`, `variant_group_option_id`).
- Add `product_item_id` to `recipe_versions` table.
- GIN Fulltext & composite search index on `product_items` (`name`, `variant_combination`, `sku`, `barcode`).
- Register & enable feature flags `basic_product`, `product_variant`, `product_bom` (`recipe_management`), and `product_modifier` (`product_modifiers`) in `FeatureEnum` and `SubscriptionPlanSeeder`.
- Migration backfill: Ensure every existing single product has 1 default `product_items` row.
- Verification: Rollback symmetry check `php artisan migrate:rollback --step=1 && php artisan migrate`.

### R2: Service Layer, Feature Gating & Sync API (`sollu-app`)
- Refactor `ProductService`:
  - Enforce causality: `sellable = false` => `is_show = false`.
  - Unified Item Pattern: 1 default `ProductItem` for single product; N `ProductItems` linked via pivot for variant product.
  - Decoupled Inventory: create `inventory_items` and `inventory_balances` only if `track_inventory = true`.
- Controllers, Requests & Services:
  - `RawMaterialController` (`/master/raw-materials`): `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, `track_inventory = true`.
  - `RecipeTemplateController` (`/master/recipes`): BOM template management.
  - Activate `ModifierGroupController` (`/master/modifiers`).
- Route protection via `plan.feature:...` middleware (`product_variant`, `product_bom`, `product_modifier`).
- Update `MasterDataSyncService` to export `product_items` and `product_item_variant_group_options`.

### R3: Admin Web UI/UX Inertia Vue 3 (`sollu-app`)
- Update `CreateEdit.vue` for physical products:
  - Bidirectional watcher on `sellable`: disabling `sellable` disables and turns off `is_show`.
  - Tab 2 (Variants) wrapped with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">`.
  - Tab 4 (BOM Recipe) wrapped with `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`.
  - Tab 5 (Modifiers) wrapped with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`.
- Interface pages:
  - `Master/Product/RawMaterial/Index.vue` & drawer form.
  - `Master/Product/Recipe/Index.vue` & drawer form.
- Sidebar navigation sub-menus: "Bahan Baku", "Template Resep", "Opsi Tambahan" under Master Data with `v-feature.lock`.
- Form Category (`CategoryForm.vue`) strict 2-tier depth guard (Root -> Child).

### R4: Flutter POS Local Database (Drift SQLite) & Repository (`sollu-pos-client`)
- Drift SQLite tables: `ProductItems` and `ProductItemVariantGroupOptions` in `master_data_tables.dart`.
- Run code generator: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Refactor `InitialSyncService` and `DeltaSyncService` to absorb `product_items` and `product_item_variant_group_options`.
- Refactor `PosRepository`:
  - Replace legacy UNION query with clean `ProductItems` left join `Inventories`.
  - Instant omni-search matching `barcode`, `sku`, `name`, `variant_combination`.
  - Aggregative category filter (parent category shows items of parent and children).

### R5: Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`)
- Refactor `VariantDialogNotifier`:
  - Resolve prices and variant availability using `ProductItemVariantGroupOptions` pivot in Drift.
  - Add modifier selection support.
- Bind `CartItem` and `CartProvider` to `product_item_id`.
- Decoupled stock: `track_inventory = false` displays infinity (`∞`) and checkout is never blocked by stock check.

## Verification & Acceptance
- Rollback symmetry: `php artisan migrate:rollback --step=1 && php artisan migrate`
- Tests: `ProductManagementTest`, `ProductFeatureGatingTest`, `MasterDataSyncTest`
- Linters: `vendor/bin/pint --dirty --format agent`, `npm run lint`
- Flutter verification: `flutter pub run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`
