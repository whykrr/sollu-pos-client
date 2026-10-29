# Handoff Report — Explorer R3: Frontend Inertia Vue 3 Architecture (`sollu-app`)

**Date:** 2026-10-22  
**Agent:** Explorer R3 (`explorer_r3_1`)  
**Target Milestone:** R3 — Admin Web UI/UX Inertia Vue 3  
**Target Workspace:** `/Users/whykrr/Documents/Projects/Laravel/sollu-app`  

---

## 1. Observation

### 1.1 Product Create & Edit (`resources/js/Pages/App/Master/Product/`)
- **Existing Files:**
  - `CreateEdit.vue` (544 lines): Uses `FormStepper` in Create mode and `FormTabs` in Edit mode.
  - `CreateEditWrapper.vue` (99 lines): Loads categories, outlets, uoms, and modifier groups on-demand via `axios.get(route('master.products.formOptions'))`.
  - Component Steps currently in `CreateEdit.vue` (lines 405–452):
    - `basic` (StepBasicInfo.vue) — "Informasi Dasar"
    - `inventory` (StepInventorySetup.vue) — "Stok & Varian"
    - `pricing` (StepPricing.vue) — "Harga & Outlet"
- **Current `sellable` and `is_show` bindings in `StepBasicInfo.vue` (lines 72–98):**
  - `<Switch v-model="form.is_show" size="sm" />` (Tampilkan di Kasir)
  - `<Switch v-model="form.sellable" size="sm" />` (Dapat Dijual)
  - There is currently **no watcher** or disabled state linking `sellable` and `is_show` in `StepBasicInfo.vue` or `CreateEdit.vue`.
- **Existing `FeatureLock` implementation:**
  - `resources/js/Components/UI/FeatureLock.vue` (81 lines): Registered globally as `<FeatureLock>` in `resources/js/access-handle.js`.
  - Props: `:feature` (String | Array), `:requireAll`, `:as` (default 'div'), `:badgePosition`, `:customLabel`.
  - `StepInventorySetup.vue` (lines 35 & 262) already wraps its variant section with:
    `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS" as="div" class="w-full">`
  - Exact enum keys in `app/Enums/FeatureEnum.php`:
    - `PRODUCT_VARIANTS = 'product_variants'`
    - `RECIPE_MANAGEMENT = 'recipe_management'`
    - `PRODUCT_MODIFIERS = 'product_modifiers'`
    - `PRODUCT_CATALOG = 'product_catalog'`
    - `PRODUCT_CATEGORIES = 'product_categories'`
    - `SERVICE_CATALOG = 'service_catalog'`
    - `RAW_MATERIALS = 'raw_materials'`

### 1.2 Category Form & 2-Level Hierarchy (`resources/js/Pages/App/Master/Product/Category/`)
- **Existing Files:**
  - `Index.vue` (131 lines): Renders `MainPage` with `CategoryTree.vue` and opens `CategoryForm.vue` via `popUpStore.open()`.
  - `Components/CategoryForm.vue` (140 lines):
    - `availableParents` (lines 100–108):
      ```javascript
      const availableParents = computed(() => {
          return props.allCategories.filter(c => {
              if (c.parent_id) return false
              if (props.category && c.id === props.category.id) return false
              return true
          })
      })
      ```
    - Parent selection is rendered via `DropdownField` (lines 13–20) with `v-if="!hasChildren"`.
    - If a category already has children, `hasChildren` is `true`, hiding the parent selector completely and preventing a root category from becoming a child (which would create 3 levels).
  - **Backend Validation:**
    - `StoreCategoryRequest.php` & `UpdateCategoryRequest.php` (lines 46–51, 57–67) enforce strict 1-level parent depth (`$parentCategory->parent_id !== null` causes validation failure) and prevent circular reference.

### 1.3 Sidebar Navigation (`resources/js/Composable/Sidebar/` & `Components/Layout/Sidebar/`)
- **Existing Files:**
  - `useSidebar.js` (22 lines): Selects between `mainSidebars` and `settingSidebars`.
  - `main.js` (lines 107–148): Defines the `Master Produk` dropdown menu with 3 items currently active:
    1. `Kategori Produk` (`master.categories.index`) — feature `PRODUCT_CATEGORIES`
    2. `Produk Barang` (`master.products.index`) — feature `PRODUCT_CATALOG`
    3. `Produk Layanan` (`master.services.index`) — feature `SERVICE_CATALOG`
    - Lines 139–146 have `Opsi Tambahan` (`master.modifiers.index`) commented out!
    - Lines 158–165 under `Inventori` have `Bahan Baku` commented out!
  - `NavigationNode.vue` (111 lines): Evaluates `isVisible`:
    ```javascript
    const isVisible = targetItem => {
        const userPerms = page.props.auth?.permissions || []
        const userFeats = page.props.auth?.features || []

        if (!checkPerm(userPerms, targetItem.permissions)) return false
        if (!checkFeat(userFeats, targetItem.feature || targetItem.features)) return false

        return true
    }
    ```
    Currently, if `checkFeat` returns `false`, `isVisible` returns `false`, hiding the menu item completely. To support commercial lock visualization (`v-feature.lock`), `targetItem.lock = true` must keep the item visible in `NavigationNode.vue`.

### 1.4 Raw Material & Recipe Controllers & UI Patterns
- **Controllers & Routes:**
  - `RawMaterialController.php` (198 lines):
    - `index()` renders `Inertia::render('Master/Product/RawMaterial/Index', ['rawMaterials' => ..., 'uoms' => ..., 'filters' => ...])`.
    - Routes: `master.raw-materials.index`, `store`, `update`, `destroy`, `export`, `import`, `importTemplate` in `routes/app/masters.php` (line 51).
  - `RecipeTemplateController.php` (151 lines):
    - `index()` renders `Inertia::render('Master/Product/Recipe/Index', ['recipes' => ..., 'products' => ..., 'rawMaterials' => ..., 'filters' => ...])`.
    - Routes: `master.recipes.index`, `store`, `show`, `update`, `destroy` in `routes/app/masters.php` (line 53).
- **Existing UI Patterns (`MainPage` 5-Slot Architecture):**
  - Canonical reference: `resources/js/Pages/App/Master/Product/Modifier/Index.vue` and `ModifierForm.vue`.
  - `#header`: `<MainPageHeader title="..." description="..." />`
  - `#filter`: `<ActionBar><template #search><FilterSearch .../></template><template #create><button class="btn btn-main btn-sm h-[30px] ...">...</button></template></ActionBar>`
  - Default slot: `<Table :headers="headers" :data="...data" :action="true">`
  - `#footer`: `<Pagination ... />`
  - Form Dialog: `popUpStore.open({ title, subTitle, size, component, props })` with form buttons teleported to `#popUpFooter`.

### 1.5 Tooling & Linters
- `package.json`:
  - `npm run lint` -> `eslint resources/js/` (Executed: **0 errors, 51 warnings**).
  - `npm run format:check` -> `prettier --check resources/js/` (Executed: **0 errors, All matched files use Prettier code style**).

---

## 2. Logic Chain

1. **CreateEdit 5-Tab Architecture:**
   - **Requirement:** 5 tabs: Informasi Dasar, Stok & Varian, Harga & Outlet, Resep Bahan Baku (BOM), Modifier / Opsi Tambahan.
   - **Current:** Only 3 tabs (`basic`, `inventory`, `pricing`).
   - **Action for Worker R3:** Add 2 new steps to `computed(() => steps)` in `CreateEdit.vue`:
     - Step 4: `recipe` -> `StepRecipeSetup.vue` (wrapped in `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`)
     - Step 5: `modifier` -> `StepModifierSetup.vue` (wrapped in `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`)
   - Tab 2 (`StepInventorySetup.vue`) already wraps variants with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">`.

2. **`sellable` & `is_show` Bi-directional Watcher & Disabled State:**
   - **Business Rule (§ 5.1 A):**
     $$\text{sellable} = \text{false} \implies \text{is\_show} = \text{false}$$
   - When `sellable` is turned off, `is_show` must automatically be set to `false`, and the switch must be disabled.
   - Helper text must display: *"Produk yang tidak dapat dijual otomatis disembunyikan dari katalog kasir."*
   - In `CreateEdit.vue` & `StepBasicInfo.vue`: Add watcher on `form.sellable` and `form.is_show`, and `:disabled="!form.sellable"` on the `is_show` switch.

3. **Category Form 2-Level Depth Guarantee:**
   - `CategoryForm.vue` already enforces `!c.parent_id` in `availableParents` and disables parent selection if `hasChildren` is true.
   - Verification confirms frontend and backend (`StoreCategoryRequest` / `UpdateCategoryRequest`) are 100% aligned with strict 2-tier hierarchy (Root -> Child).

4. **Sidebar Navigation & Feature Locks:**
   - In `resources/js/Composable/Sidebar/main.js`:
     - Under `Master Produk`, uncomment/add `Opsi Tambahan` (`/master/modifiers`), `Bahan Baku` (`/master/raw-materials`), and `Template Resep` (`/master/recipes`).
     - Set `lock: true` and the corresponding `feature` enum.
   - In `resources/js/Components/Layout/Sidebar/NavigationNode.vue`:
     - Update `isVisible` so items with `targetItem.lock === true` are not discarded when feature is missing.
     - In the dropdown submenu loop, render locked items using `v-feature.lock="submenu.feature"` or a locked lock badge button so clicking them triggers `FeatureLockedModal`.

5. **Raw Material & Recipe Views Construction:**
   - `Inertia::render('Master/Product/RawMaterial/Index')` resolves to `resources/js/Pages/App/Master/Product/RawMaterial/Index.vue`.
   - `Inertia::render('Master/Product/Recipe/Index')` resolves to `resources/js/Pages/App/Master/Product/Recipe/Index.vue`.
   - Worker R3 needs to build these two pages using `MainPage`, `ActionBar`, `Table`, `Pagination`, and `usePopUpStore`.

---

## 3. Caveats

1. **Inventory RawMaterial vs Master RawMaterial:**
   - Note that an older view existed at `resources/js/Pages/App/Inventory/RawMaterial/Index.vue` pointing to `inventory.raw-materials.*`.
   - The architectural plan (§ 5.2) and `RawMaterialController` explicitly place Raw Materials under Master Produk (`master.raw-materials.*`) with page path `Master/Product/RawMaterial/Index`.
   - Do NOT edit or overwrite `Pages/App/Inventory/RawMaterial/Index.vue`. Create the new, modern Master component at `resources/js/Pages/App/Master/Product/RawMaterial/Index.vue` and its form drawer at `resources/js/Pages/App/Master/Product/RawMaterial/Components/Form.vue`.
2. **FeatureEnum Consistency:**
   - Both `RAW_MATERIALS` and `RECIPE_MANAGEMENT` exist in `FeatureEnum.php`.
   - Route `master.raw-materials.*` and `master.recipes.*` are protected by `FeatureEnum::RECIPE_MANAGEMENT` in `routes/app/masters.php` (line 46).
   - Therefore, use `$enums.FeatureEnum.RECIPE_MANAGEMENT` (or `'recipe_management'`) as the feature lock key for both Raw Materials and Recipes/BOM.

---

## 4. Conclusion & Complete Blueprint for Worker R3

Below are the exact blueprints, component templates, and code snippets ready to be implemented by Worker R3.

### Component Blueprint 1: `resources/js/Pages/App/Master/Product/CreateEdit.vue`
Update `steps` computed property to support all 5 tabs and add bi-directional watchers for `sellable` / `is_show`:

```javascript
// Add imports:
import StepRecipeSetup from './Components/StepRecipeSetup.vue'
import StepModifierSetup from './Components/StepModifierSetup.vue'
import { faUtensils, faSliders } from '@fortawesome/free-solid-svg-icons'

// In form initialization (lines 144-164):
const form = useForm({
    // ... existing fields ...
    recipe_items: props.product?.active_recipe?.items || [],
    modifier_group_ids: props.product?.modifier_groups?.map(g => g.id) || [],
})

// Bi-directional Watchers:
watch(
    () => form.sellable,
    isSellable => {
        if (!isSellable) {
            form.is_show = false
            if (Array.isArray(form.variant_combinations)) {
                form.variant_combinations.forEach(combo => {
                    combo.sellable = false
                    combo.is_show = false
                })
            }
        }
    }
)

watch(
    () => form.is_show,
    isShow => {
        if (isShow && !form.sellable) {
            form.is_show = false
        }
    }
)

// In steps computed property:
const steps = computed(() => {
    const s = [
        {
            id: 'basic',
            component: StepBasicInfo,
            title: 'Informasi Dasar',
            icon: faPencil,
            fields: ['name', 'code', 'product_category_id', 'description', 'images', 'is_show', 'sellable', 'outlets'],
        },
    ]

    if (form.product_type === 'basic') {
        s.push({
            id: 'inventory',
            component: StepInventorySetup,
            title: 'Stok & Varian',
            icon: faBoxesStacked,
            fields: ['uom_id', 'barcode', 'variants', 'variant_combinations', 'track_inventory', 'has_variant'],
        })
    }

    s.push({
        id: 'pricing',
        component: StepPricing,
        title: 'Harga & Outlet',
        icon: faTag,
        fields: ['base_price', 'outlet_prices'],
    })

    if (form.product_type === 'basic') {
        s.push({
            id: 'recipe',
            component: StepRecipeSetup,
            title: 'Resep (BOM)',
            icon: faUtensils,
            fields: ['recipe_items'],
        })
        s.push({
            id: 'modifier',
            component: StepModifierSetup,
            title: 'Opsi Tambahan',
            icon: faSliders,
            fields: ['modifier_group_ids'],
        })
    }

    return s
})
```

### Component Blueprint 2: `resources/js/Pages/App/Master/Product/Components/StepBasicInfo.vue`
Update lines 72–98 for the switches:

```vue
<!-- Switch Visibilitas POS & Jual -->
<div class="grid grid-cols-1 sm:grid-cols-2 gap-2 pt-1">
    <div
        class="flex items-center justify-between border border-slate-200 p-2.5 rounded-xl transition"
        :class="!form.sellable ? 'bg-slate-50 opacity-60 cursor-not-allowed' : 'hover:bg-slate-50'"
    >
        <div class="pr-2">
            <div class="font-semibold text-xs text-slate-800">
                Tampilkan di Kasir
            </div>
            <div class="text-[11px] text-slate-500">
                <span v-if="!form.sellable" class="text-amber-600 font-medium">
                    Produk yang tidak dapat dijual otomatis disembunyikan dari katalog kasir.
                </span>
                <span v-else>
                    Muncul di katalog transaksi kasir
                </span>
            </div>
        </div>
        <Switch v-model="form.is_show" size="sm" :disabled="!form.sellable" />
    </div>

    <div
        class="flex items-center justify-between border border-slate-200 p-2.5 rounded-xl hover:bg-slate-50 transition"
    >
        <div>
            <div class="font-semibold text-xs text-slate-800">Dapat Dijual</div>
            <div class="text-[11px] text-slate-500">
                Aktif untuk transaksi penjualan
            </div>
        </div>
        <Switch v-model="form.sellable" size="sm" />
    </div>
</div>
```

### Component Blueprint 3: `StepRecipeSetup.vue` and `StepModifierSetup.vue`
Create:
- `resources/js/Pages/App/Master/Product/Components/StepRecipeSetup.vue`:
  - Wrapped with `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT" as="div" class="w-full">`.
  - Allows linking raw material items, quantity, and unit.
- `resources/js/Pages/App/Master/Product/Components/StepModifierSetup.vue`:
  - Wrapped with `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS" as="div" class="w-full">`.
  - Multi-select checkbox/cards of available modifier groups from `ProductController::formOptions`.

### Component Blueprint 4: Sidebar Navigation (`main.js` & `NavigationNode.vue`)
In `resources/js/Composable/Sidebar/main.js`:
```javascript
    {
        type: 'dropdown',
        url: '#',
        icon: faBox,
        label: 'Master Produk',
        permissions: [],
        activeRoute: 'master.',
        items: [
            {
                type: 'item',
                url: route('master.categories.index'),
                label: 'Kategori Produk',
                feature: enums.FeatureEnum.PRODUCT_CATEGORIES,
                permissions: ['category.view'],
                activeRoute: 'master.categories.',
            },
            {
                type: 'item',
                url: route('master.products.index'),
                label: 'Produk Barang',
                feature: enums.FeatureEnum.PRODUCT_CATALOG,
                permissions: ['product.view'],
                activeRoute: 'master.products.',
            },
            {
                type: 'item',
                url: route('master.services.index'),
                label: 'Produk Layanan',
                feature: enums.FeatureEnum.SERVICE_CATALOG,
                permissions: ['service.view'],
                activeRoute: 'master.services.',
            },
            {
                type: 'item',
                url: route('master.modifiers.index'),
                label: 'Opsi Tambahan',
                feature: enums.FeatureEnum.PRODUCT_MODIFIERS,
                lock: true,
                permissions: [],
                activeRoute: 'master.modifiers.',
            },
            {
                type: 'item',
                url: route('master.raw-materials.index'),
                label: 'Bahan Baku',
                feature: enums.FeatureEnum.RECIPE_MANAGEMENT,
                lock: true,
                permissions: [],
                activeRoute: 'master.raw-materials.',
            },
            {
                type: 'item',
                url: route('master.recipes.index'),
                label: 'Template Resep',
                feature: enums.FeatureEnum.RECIPE_MANAGEMENT,
                lock: true,
                permissions: [],
                activeRoute: 'master.recipes.',
            },
        ],
    },
```

In `resources/js/Components/Layout/Sidebar/NavigationNode.vue`:
Support `lock: true` so the menu item is rendered and clickable (opening `FeatureLockedModal`) rather than hidden when the tenant's tier doesn't include the feature:
```javascript
const isVisible = targetItem => {
    const userPerms = page.props.auth?.permissions || []
    const userFeats = page.props.auth?.features || []

    if (!checkPerm(userPerms, targetItem.permissions)) return false
    if (!checkFeat(userFeats, targetItem.feature || targetItem.features)) {
        if (targetItem.lock) return true
        return false
    }

    return true
}
```
And in `<NavigationDropdown>` template:
```vue
<template v-for="(submenu, subIndex) in visibleItems" :key="submenu.url || submenu.label || subIndex">
    <Link
        v-if="!isLocked(submenu)"
        :href="submenu.url"
        class="nav-dropdown-item"
        :class="{ active: isActive(submenu) }"
    >
        {{ submenu.label }}
    </Link>
    <div
        v-else
        class="nav-dropdown-item flex items-center justify-between cursor-pointer group"
        v-feature.lock="submenu.feature"
    >
        <span class="truncate">{{ submenu.label }}</span>
    </div>
</template>
```

### Component Blueprint 5: `Master/Product/RawMaterial/Index.vue` & `Components/Form.vue`
- Path: `resources/js/Pages/App/Master/Product/RawMaterial/Index.vue`
- Uses `MainPage`, `MainPageHeader`, `ActionBar`, `FilterSearch`, `Table`, `Pagination`.
- PopUpPage opens `Components/Form.vue`:
  - Form Fields: `name` (required), `sku`, `barcode`, `uom_id` (required, dropdown from `uoms`), `track_inventory` (Switch, default true), `minimum_stock` (NumberField, visible when `track_inventory`).
  - Routes: `master.raw-materials.store`, `master.raw-materials.update`, `master.raw-materials.destroy`.

### Component Blueprint 6: `Master/Product/Recipe/Index.vue` & `Components/Form.vue`
- Path: `resources/js/Pages/App/Master/Product/Recipe/Index.vue`
- Uses `MainPage`, `MainPageHeader`, `ActionBar`, `Table`, `Pagination`.
- Columns: Produk (`product.name`), Varian (`product_item.variant_combination` or '-'), Versi (`v${version_number}`), Jumlah Bahan (`items.length`), Estimasi HPP (`estimated_hpp`), Status, Actions (Edit & Nonaktifkan).
- PopUpPage opens `Components/Form.vue`:
  - Product Selector (`product_id`) from `products`.
  - Variant Selector (`product_item_id`) if product `has_variant`.
  - Dynamic Ingredient Matrix:
    - Add Ingredient Row: Select raw material (`product_item_id`), input quantity (`qty`), UOM badge/label, real-time estimated cost (`qty * average_cost`).
    - Real-time Total Estimated HPP calculation displayed in form header/footer.
  - Submits to `master.recipes.store` and `master.recipes.update`.

---

## 5. Verification Method

To independently verify after implementation:
1. **Linter & Code Style:**
   ```bash
   cd /Users/whykrr/Documents/Projects/Laravel/sollu-app
   npm run lint
   npm run format:check
   ```
   *Expected:* Exit code 0, zero lint errors.
2. **Page Resolution & Build:**
   ```bash
   npm run build
   ```
   *Expected:* Vite build completes without missing imports or template syntax errors.
3. **Route Integration & Permission Check:**
   ```bash
   php artisan route:list --name=master.raw-materials
   php artisan route:list --name=master.recipes
   php artisan route:list --name=master.modifiers
   ```
   *Expected:* All endpoints registered and pointing to their respective controllers.

---
*Report produced by Explorer R3 (`explorer_r3_1`).*
