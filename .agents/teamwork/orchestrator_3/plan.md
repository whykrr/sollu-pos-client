# Execution Plan — Project Orchestrator (orchestrator_3)

## Milestone Overview
- **Milestone R1**: Database Foundation, Migrations & Normalization (`sollu-app`) -> **PASSED & VERIFIED**
- **Milestone R2**: Backend Service Layer, Feature Gating & Sync API (`sollu-app`) -> **IN PROGRESS (Iteration 2 Gate Clearance)**
- **Milestone R3**: Admin Web UI/UX Inertia Vue 3 (`sollu-app`) -> **PLANNED**
- **Milestone R4**: Flutter POS Drift SQLite & PosRepository Omni-Search (`sollu-pos-client`) -> **PLANNED**
- **Milestone R5**: Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`) -> **PLANNED**

---

## Phase 1: Milestone R2 Iteration 2 Gate Clearance
1. **Dispatch Worker R2 Iteration 2** (`worker_r2_it2`):
   - Scope:
     - `app/Services/App/Master/ProductService.php`:
       - `deleteProduct`: Swap execution order to deactivate inventory items *before* soft-deleting product items.
       - `updateProduct`: If `$product->sellable === false`, cascade `sellable = false` and `is_show = false` to all child `productItems`. If `$product->is_show === false`, cascade `is_show = false` to all child `productItems`.
     - `app/Http/Controllers/App/Master/ServiceProductController.php`:
       - `destroy`: Delegate deletion to `$this->productService->deleteService($service)`.
       - Verify tenant isolation on all service endpoints.
     - `app/Http/Controllers/App/Master/ModifierGroupController.php`:
       - Add tenant isolation check (`$modifier->business_id !== $request->user()->business_id => abort(403)`) to `update` and `destroy`.
     - Tests & Code Style:
       - Update or add test cases for these invariant cascades and tenant checks in `tests/Feature/Product/ProductManagementTest.php` and `tests/Feature/Product/ProductFeatureGatingTest.php`.
       - Run `vendor/bin/pint --dirty --format agent`.
       - Clean up any broken/stale test files.
2. **Dispatch Gate Verification Team for R2 Iteration 2**:
   - 2 Reviewers (`reviewer_r2_it2_1`, `reviewer_r2_it2_2`)
   - 2 Challengers (`challenger_r2_it2_1`, `challenger_r2_it2_2`)
   - 1 Forensic Auditor (`auditor_r2_it2`)
3. **Gate Clearance**:
   - Ensure all APPROVE and Auditor CLEAN. Record in `GATE_STATUS.md`. Report milestone completion to Sentinel.

---

## Phase 2: Milestone R3 — Admin Web UI/UX Inertia Vue 3 (`sollu-app`)
1. **Dispatch Worker R3** (`worker_r3`):
   - Scope:
     - `resources/js/Pages/App/Master/Product/CreateEdit.vue`:
       - Bi-directional watcher on `sellable`: if `false`, set `form.is_show = false` and disable the `is_show` switch with clear helper text.
       - Tab 2 (Variants): Wrap with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">` or `v-feature.lock`.
       - Tab 4 (Recipe/BOM): Wrap with `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`.
       - Tab 5 (Modifiers): Wrap with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`.
     - `resources/js/Pages/App/Master/Product/RawMaterial/Index.vue` & Drawer form for Raw Material management.
     - `resources/js/Pages/App/Master/Product/Recipe/Index.vue` & Drawer form for Recipe Template management.
     - `resources/js/Composable/Sidebar/main.js`: Add sub-menus for Raw Materials, Recipe Templates, and Modifiers with `v-feature.lock` awareness.
     - `resources/js/Pages/App/Master/Category/Partials/CategoryForm.vue`: Strict 2-level hierarchy restriction (Root -> Child).
     - Run `npm run lint` & `npm run format`.
2. **Dispatch Gate Verification Team for R3**:
   - 2 Reviewers, 2 Challengers, 1 Forensic Auditor.
   - Gate Clearance -> Report milestone completion to Sentinel.

---

## Phase 3: Milestone R4 — Flutter POS Drift SQLite & PosRepository (`sollu-pos-client`)
1. **Dispatch Worker R4** (`worker_r4`):
   - Scope:
     - `lib/core/database/tables/master_data_tables.dart`: Define `ProductItems` and `ProductItemVariantGroupOptions` tables.
     - Run `flutter pub run build_runner build --delete-conflicting-outputs`.
     - `lib/features/sync/data/initial_sync_service.dart` & `delta_sync_service.dart`: Ingest `product_items` and `product_item_variant_group_options`.
     - `lib/features/pos/data/pos_repository.dart`: Refactor to query `ProductItems` joined with `Inventories` instead of legacy UNION; implement multi-key instant omni-search (`barcode`, `sku`, `name`, `variant_combination`); aggregative category filtering.
     - Run `flutter analyze` & `flutter test`.
2. **Dispatch Gate Verification Team for R4**:
   - Reviewers, Challengers, Auditor -> Gate Clearance.

---

## Phase 4: Milestone R5 — Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`)
1. **Dispatch Worker R5** (`worker_r5`):
   - Scope:
     - `lib/features/pos/presentation/providers/variant_dialog_provider.dart`: Match price and availability using `ProductItemVariantGroupOptions` pivot in Drift; modifier support.
     - `lib/features/cart/domain/cart_item.dart` & `cart_provider.dart`: Bind cart items to `product_item_id`.
     - Decoupled stock behavior: `track_inventory = false` displays infinity (`∞`) stock, never blocks checkout.
     - Run `flutter analyze` & `flutter test`.
2. **Dispatch Gate Verification Team for R5**:
   - Reviewers, Challengers, Auditor -> Gate Clearance.

---

## Phase 5: Final Acceptance & Victory Audit
- Run complete end-to-end regression across both `sollu-app` and `sollu-pos-client`.
- Verify all checklist items from `ORIGINAL_REQUEST.md`.
- Report victory to Sentinel (`b9cf86e5-ab4d-4c0a-8088-78646c3a905b`).
