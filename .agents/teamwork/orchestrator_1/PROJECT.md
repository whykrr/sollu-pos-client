# Project: Unified Product Module Overhaul

## Architecture
- Dual-stack ecosystem:
  - Laravel 12 Backend (`sollu-app`): Modular Monolith, PostgreSQL, Inertia Vue 3, Tailwind CSS v4, Feature Gating via Spatie & SaaS Plans.
  - Flutter POS Client (`sollu-pos-client`): Clean Architecture, Drift SQLite, Riverpod, GoRouter, Offline-first Omni-Search.
- Data Flow:
  - Unified Item Pattern: Product has 1..N ProductItems.
  - POS Sync: MasterDataSync exports `product_items` and `product_item_variant_group_options`. Drift stores and streams via `PosRepository`.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Normalization Table | Pivot `product_item_variant_group_options` | R1 | ORIGINAL_REQUEST §R1 |
| 2 | Variant-Level BOM | Column `product_item_id` in `recipe_versions` | R1 | ORIGINAL_REQUEST §R1 |
| 3 | Fulltext & Composite Index | GIN & composite indexes on `product_items` | R1 | ORIGINAL_REQUEST §R1 |
| 4 | Feature Flags Seeding | `basic_product`, `product_variant`, `product_bom`, `product_modifier` | R1 | ORIGINAL_REQUEST §R1 |
| 5 | Single Product Backfill | Ensure 1 default `product_items` row per single product | R1 | ORIGINAL_REQUEST §R1 |
| 6 | Rollback Symmetry Verification | Bidirectional migration rollback and re-migrate | R1 | ORIGINAL_REQUEST §R1 |
| 7 | ProductService Unified Item Logic | Enforce `sellable => is_show`, 1..N ProductItems, decoupled inventory | R2 | ORIGINAL_REQUEST §R2 |
| 8 | Raw Material Domain | `RawMaterialController` (`/master/raw-materials`) | R2 | ORIGINAL_REQUEST §R2 |
| 9 | Recipe Template Domain | `RecipeTemplateController` (`/master/recipes`) | R2 | ORIGINAL_REQUEST §R2 |
| 10 | Modifier Route Activation | `ModifierGroupController` (`/master/modifiers`) | R2 | ORIGINAL_REQUEST §R2 |
| 11 | Backend Feature Gating | Route middleware `plan.feature:...` on variants, BOM, modifiers | R2 | ORIGINAL_REQUEST §R2 |
| 12 | MasterDataSync Export | Export `product_items` & pivot to POS | R2 | ORIGINAL_REQUEST §R2 |
| 13 | Admin Product Create/Edit Form | Watcher `sellable => is_show`, `<FeatureLock>` on Tabs 2, 4, 5 | R3 | ORIGINAL_REQUEST §R3 |
| 14 | Admin Raw Material Pages | `Master/Product/RawMaterial/Index.vue` & drawer | R3 | ORIGINAL_REQUEST §R3 |
| 15 | Admin Recipe Pages | `Master/Product/Recipe/Index.vue` & drawer | R3 | ORIGINAL_REQUEST §R3 |
| 16 | Admin Sidebar Sub-menus | Navigation items with `v-feature.lock` | R3 | ORIGINAL_REQUEST §R3 |
| 17 | 2-Tier Category Restriction | Strict root -> child depth constraint in form | R3 | ORIGINAL_REQUEST §R3 |
| 18 | Drift SQLite Tables | `ProductItems`, `ProductItemVariantGroupOptions` tables | R4 | ORIGINAL_REQUEST §R4 |
| 19 | Drift Code Generation | Build runner execution | R4 | ORIGINAL_REQUEST §R4 |
| 20 | POS Sync Ingestion | `InitialSyncService` & `DeltaSyncService` absorbs new tables | R4 | ORIGINAL_REQUEST §R4 |
| 21 | POS Omni-Search & Repository | Clean `ProductItems` left join `Inventories`, multi-key search, category tree filter | R4 | ORIGINAL_REQUEST §R4 |
| 22 | Variant Dialog Resolution | Pivot resolution in `VariantDialogNotifier` + modifier support | R5 | ORIGINAL_REQUEST §R5 |
| 23 | Cart Binding to ProductItem | `CartItem` bound to `product_item_id` | R5 | ORIGINAL_REQUEST §R5 |
| 24 | Decoupled Inventory in POS | `track_inventory = false` displays infinity (`∞`) and bypasses stock check | R5 | ORIGINAL_REQUEST §R5 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | R1: DB Foundation & Migrations | Schema, pivot, indexes, backfill, seeders (sollu-app) | none | DONE |
| 2 | R2: Service Layer & Sync API | ProductService, RawMaterial, Recipe, Modifier, Gating, Sync (sollu-app) | R1 | IN_PROGRESS |
| 3 | R3: Admin Web UI/UX | Inertia Vue 3 views, tabs, feature locks, category depth (sollu-app) | R2 | PLANNED |
| 4 | R4: Flutter POS DB & Repository | Drift schema, sync ingestion, PosRepository omni-search (sollu-pos-client) | R2 | PLANNED |
| 5 | R5: Flutter POS Variant Dialog & Cart | Dialog resolution, cart binding, decoupled inventory (sollu-pos-client) | R4 | PLANNED |

## Interface Contracts
### sollu-app ↔ sollu-pos-client
- Sync endpoint: `/api/v1/pos/sync/master-data` (or existing sync route)
- Exported entities:
  - `product_items`: id, product_id, uom_id, item_type, name, variant_combination, sku, barcode, track_inventory, is_show, sellable, is_active, unit
  - `product_item_variant_group_options`: product_item_id, variant_group_option_id

## Code Layout
### sollu-app (Laravel)
- Migrations: `database/migrations/`
- Models: `app/Models/`
- Seeders: `database/seeders/`
- Services: `app/Services/App/Master/`
- Controllers: `app/Http/Controllers/App/Master/`
- Requests: `app/Http/Requests/App/Master/`
- Enums: `app/Enums/`
- Routes: `routes/app/masters.php`
- Views: `resources/js/Pages/Master/`
- Navigation: `resources/js/Composable/Sidebar/main.js`

### sollu-pos-client (Flutter)
- Database tables: `lib/core/database/tables/master_data_tables.dart`
- Drift database: `lib/core/database/app_database.dart`
- Sync services: `lib/features/sync/`
- POS repository: `lib/features/pos/data/pos_repository.dart`
- POS providers: `lib/features/pos/presentation/providers/`
