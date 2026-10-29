## 2026-10-22T09:49:03Z
[Message] timestamp=2026-10-22T09:49:03Z sender=62e974db-fa87-4f68-ab0a-9c5953d6dc72 priority=MESSAGE_PRIORITY_HIGH content=You are worker_r1 implementing Milestone R1 (Database Foundation, Migrations & Normalization in sollu-app).
Your working directory is:
/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r1/

Target workspace: /Users/whykrr/Documents/Projects/Laravel/sollu-app

Read and follow all instructions in:
- ORIGINAL_REQUEST.md: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md
- Plan Specification: /Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md
- Project Scope: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/orchestrator_1/PROJECT.md
- Rules: /Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md
- Explorer Findings:
  - /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_1/handoff.md
  - /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r1_2/handoff.md
  - /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/spec_miner_r1_3/handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Exclusively Owned Files:
- database/migrations/2026_10_22_100000_create_product_item_variant_group_options_table.php
- database/migrations/2026_10_22_100001_add_product_item_id_to_recipe_versions_table.php
- database/migrations/2026_10_22_100002_add_composite_and_fulltext_indexes_to_product_items_table.php
- database/migrations/2026_10_22_100003_backfill_single_products_and_variant_options.php
- database/migrations/2026_10_22_100004_add_product_features_and_plan_assignments.php
- app/Enums/FeatureEnum.php
- app/Models/Master/ProductItem.php
- app/Models/Master/VariantGroupOption.php
- app/Models/Master/RecipeVersion.php
- database/seeders/Production/FeatureSeeder.php
- database/seeders/Production/SubscriptionPlanSeeder.php

Tasks to Implement:
1. Create migration `create_product_item_variant_group_options_table`:
   - columns `product_item_id` and `variant_group_option_id` with cascading foreign keys to `product_items` and `variant_group_options`.
   - composite primary key `['product_item_id', 'variant_group_option_id']` named `prod_item_vgo_primary`.
   - index on `variant_group_option_id`.
   - symmetric `down()` method dropping table if exists.
2. Create migration `add_product_item_id_to_recipe_versions_table`:
   - nullable uuid `product_item_id` after `product_id`, foreign key referencing `product_items(id)` cascading on delete.
   - symmetric `down()` method dropping foreign key before dropping column.
3. Create migration `add_composite_and_fulltext_indexes_to_product_items_table`:
   - composite index `['business_id', 'sku']` named `idx_product_items_business_sku`.
   - composite index `['business_id', 'barcode']` named `idx_product_items_business_barcode`.
   - index `'product_id'` named `idx_product_items_product_id`.
   - NOTE: do NOT duplicate `product_items_catalog_idx` which already exists on `(product_id, is_active, sellable)`.
   - PostgreSQL GIN expression index on `to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(variant_combination, '') || ' ' || coalesce(sku, '') || ' ' || coalesce(barcode, ''))` named `idx_product_items_omni_search`.
   - Driver guard: MUST wrap GIN index statement in `if (DB::getDriverName() === 'pgsql')` in both `up()` and `down()` so in-memory SQLite feature tests do not crash.
   - symmetric `down()` method dropping indexes cleanly.
4. Create migration `backfill_single_products_and_variant_options`:
   - query single products (`has_variant = false`) lacking a `product_items` row (e.g. "Topup Shopee Pay 200K"). Insert default `ProductItem` with `name`, `sku = code ?: PRD-...`, `variant_combination = null`, preserving `sellable`, `is_show`, `track_inventory`.
   - link unassigned `product_prices.product_item_id` for single products.
   - backfill `product_item_variant_group_options` linking existing variant items to their respective `variant_group_options` (140 option links).
   - symmetric `down()` method reverting backfilled prices and items.
5. Create migration `add_product_features_and_plan_assignments`:
   - ensure feature flags `product_modifiers`, `recipe_management`, and `raw_materials` are in `features` table and `is_active = true`.
   - link them to `pro` plan in `plan_features`.
   - clear cache: `Feature::clearCache()`, `SubscriptionPlan::clearCache()`.
   - symmetric `down()` method.
6. Update PHP Enum & Models:
   - `app/Enums/FeatureEnum.php`: add `PRODUCT_MODIFIERS = 'product_modifiers'`, `RECIPE_MANAGEMENT = 'recipe_management'`, and `RAW_MATERIALS = 'raw_materials'`.
   - `database/seeders/Production/FeatureSeeder.php`: uncomment and activate the 3 features.
   - `database/seeders/Production/SubscriptionPlanSeeder.php`: verify clean tier mapping (Micro: basic/catalog, Basic: +variants, Pro: +modifiers/BOM/raw_materials).
   - `app/Models/Master/ProductItem.php`: add `variantGroupOptions()` (BelongsToMany) and `recipeVersions()` (HasMany).
   - `app/Models/Master/VariantGroupOption.php`: add `productItems()` (BelongsToMany).
   - `app/Models/Master/RecipeVersion.php`: add `product_item_id` to `$fillable`, `productItem()` (BelongsTo), modern `casts(): array`.
7. Verification Execution:
   - Run: `php artisan migrate`
   - Run: `php artisan migrate:rollback --step=5 && php artisan migrate` (verify absolute rollback symmetry!)
   - Run tests: `php artisan test --compact --filter=CheckPlanFeatureTest`, `php artisan test --compact --filter=ProductItemSearchTest`, `php artisan test --compact --filter=FeatureTest`
   - Format: `vendor/bin/pint --dirty --format agent`
