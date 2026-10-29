## 2026-10-22T14:17:28Z
You are Worker R4 (worker_r4).
Your working directory is: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r4/
Target Workspace: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Read:
- Authoritative User Request: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md (§ R4)
- Explorer R4 Blueprint: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r4_1/handoff.md
- Architecture Plan: /Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md (§ 5.1 B, § 5.4, § 6 Tahap 4)
- Guidelines: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/AGENTS.md

Scope of Work for Milestone R4 (Flutter POS Drift SQLite & PosRepository):
1. Drift Database Tables & Schema Migration:
   - In `lib/core/database/tables/master_data_tables.dart`:
     - Add `ProductItems` table and `ProductItemVariantGroupOptions` table.
     - Add `hasVariants`, `hasModifiers`, `hasRecipe`, `trackInventory` to `Products`.
     - Add `productItemId` to `Inventories` and `ProductPrices`.
   - In `lib/core/database/tables/transaction_tables.dart`:
     - Add `productItemId` to `TransactionItems`.
   - In `lib/core/database/app_database.dart`:
     - Register `ProductItems` and `ProductItemVariantGroupOptions` in `@DriftDatabase`.
     - Increment `schemaVersion` to `10`.
     - Add `if (from < 10)` migration block in `MigrationStrategy.onUpgrade`.
2. Run Drift Code Generation:
   - Run `/Users/whykrr/flutter/bin/flutter pub run build_runner build --delete-conflicting-outputs` (with BypassSandbox: true if executing terminal command).
3. Ingest Master Data in Sync Pipeline:
   - In `lib/features/pos/data/sync/initial_sync_service.dart`:
     - Ingest `product_items` and `product_item_variant_group_options`.
     - Clear tables in safe foreign-key order.
     - Insert `Products`, `ProductItems`, `ProductItemVariantGroupOptions`, `Inventories`, `ProductPrices`.
   - In `lib/features/pos/data/sync/delta_sync_service.dart`:
     - Upsert updated `product_items` and delete `deleted_product_item_ids`.
4. Refactor PosRepository:
   - In `lib/features/pos/data/pos_repository.dart`:
     - Replace legacy UNION query in `watchVariantModeItems()` with clean unified query on `ProductItems` inner joined with `Products` and left joined with `Inventories`.
     - Implement instant multi-key omni-search in `findItemByBarcodeOrSku(String query)` matching `barcode`, `sku`, `name`, and `variant_combination`.
     - Implement `findProductItemIdForVariants(productId, variantGroupOptionIds)` using `product_item_variant_group_options`.
     - Implement aggregative category filtering (`p.category_id IN (SELECT id FROM product_categories WHERE id = ? OR parent_id = ?)`).
5. Automated Tests & Code Quality:
   - Add/update tests in `test/features/pos/pos_repository_test.dart` verifying the unified query, omni-search, and category aggregative filter.
   - Run `/Users/whykrr/flutter/bin/flutter test`.
   - Run `/Users/whykrr/flutter/bin/flutter analyze` and ensure zero errors.
6. Documentation & Completion:
   - Write comprehensive handoff report to `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r4/handoff.md`.
   - Report completion back to orchestrator_3 via send_message.
