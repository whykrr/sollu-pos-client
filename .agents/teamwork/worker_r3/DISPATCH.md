## 2026-10-22T13:40:33Z

You are Worker R3 (worker_r3).
Your working directory is: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r3/
Target Workspace: /Users/whykrr/Documents/Projects/Laravel/sollu-app

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Read:
- /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md (§ R3)
- Explorer R3 Blueprint: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r3_1/handoff.md
- Architecture Plan: /Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md (§ 5.2)
- Guidelines: /Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md

Scope of Work for Milestone R3 (Admin Web UI/UX Inertia Vue 3):
1. Product Create & Edit (5-Tab Structure & Causality Invariant):
   - In `resources/js/Pages/App/Master/Product/Components/StepBasicInfo.vue`:
     - Bind `is_show` with `:disabled="!form.sellable"`. When `!form.sellable`, show helper text: "Produk yang tidak dapat dijual otomatis disembunyikan dari katalog kasir." Style disabled state appropriately.
   - In `resources/js/Pages/App/Master/Product/CreateEdit.vue`:
     - Add bi-directional watchers: When `form.sellable` becomes `false`, set `form.is_show = false` and cascade `sellable = false, is_show = false` to `form.variant_combinations`.
     - When `form.is_show` is turned on while `!form.sellable`, prevent it.
     - Expand `steps` computed property to 5 steps:
       1. `basic` (StepBasicInfo.vue)
       2. `inventory` (StepInventorySetup.vue) — ensure variants section is wrapped in `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">`
       3. `pricing` (StepPricing.vue)
       4. `recipe` (StepRecipeSetup.vue) — wrapped in `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`
       5. `modifier` (StepModifierSetup.vue) — wrapped in `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`
   - Create `StepRecipeSetup.vue` and `StepModifierSetup.vue` in `resources/js/Pages/App/Master/Product/Components/` following Explorer R3 blueprint.

2. Category Form Strict 2-Level Depth:
   - In `resources/js/Pages/App/Master/Product/Category/Components/CategoryForm.vue`:
     - Ensure parent selector strictly shows root categories (`!c.parent_id`), excludes current category, and is hidden if category already has children (`v-if="!hasChildren"`).

3. Sidebar Navigation & Commercial Feature Lock:
   - In `resources/js/Composable/Sidebar/main.js`:
     - Under `Master Produk`, register:
       - `Opsi Tambahan` (`route('master.modifiers.index')`, feature: `enums.FeatureEnum.PRODUCT_MODIFIERS`, `lock: true`)
       - `Bahan Baku` (`route('master.raw-materials.index')`, feature: `enums.FeatureEnum.RECIPE_MANAGEMENT`, `lock: true`)
       - `Template Resep` (`route('master.recipes.index')`, feature: `enums.FeatureEnum.RECIPE_MANAGEMENT`, `lock: true`)
   - In `resources/js/Components/Layout/Sidebar/NavigationNode.vue`:
     - Update `isVisible` so items with `targetItem.lock === true` remain visible even if the user's plan doesn't have the feature.
     - In the submenu dropdown rendering, render locked items with `v-feature.lock="submenu.feature"` so clicking them triggers `FeatureLockedModal`.

4. Raw Material Views:
   - Create `resources/js/Pages/App/Master/Product/RawMaterial/Index.vue` and `Components/Form.vue` (drawer/PopUpPage) matching the existing `MainPage` 5-slot architecture and table styling.
   - Form fields: `name`, `sku`, `barcode`, `uom_id` (dropdown from `uoms`), `track_inventory` (Switch, default true), `minimum_stock` (NumberField).

5. Recipe Template Views:
   - Create `resources/js/Pages/App/Master/Product/Recipe/Index.vue` and `Components/Form.vue` (drawer/PopUpPage).
   - Display recipe templates table (product, variant, version, ingredient count, estimated HPP, status).
   - Form drawer supports selecting product, variant (if has_variant), and dynamic ingredient rows (raw material item, quantity, UOM label, real-time estimated cost and total HPP).

6. Verification & Quality:
   - Run `npm run lint` and `npm run format`.
   - Run `npm run build` to verify the Vite bundle compiles cleanly with 0 errors.
   - Write comprehensive report to `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r3/handoff.md`.
   - Send completion message back via send_message.
