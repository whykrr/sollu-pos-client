# Handoff Report: Milestone R2 (RawMaterial, RecipeTemplate & Modifier Controllers)

## 1. Observation

### A. ModifierGroupController & Routes
- **Route State:** In `routes/app/masters.php` (lines 39-42), the modifier route definition is commented out:
  ```php
  // Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)
  //     ->group(function () {
  //         Route::resource('modifiers', ModifierGroupController::class)->except(['create', 'edit']);
  //     });
  ```
- **Git Commit History:** `git log -n 1 -p routes/app/masters.php` showed commit `fef61d599c2aea69383a8c629b27db81d0efadbc` ("feat: add trial features configuration pop-up and integrate with cockpit settings") on Sun Oct 4 10:50:00 2026 temporarily commented out this route.
- **Controller Implementation:** `app/Http/Controllers/App/Master/ModifierGroupController.php` exists (lines 1-75). Methods implemented: `index`, `show`, `store`, `update`, `destroy`.
  - In `index()` (line 31): Renders `Inertia::render('Master/Product/Modifier/Index', ...)`.
  - In `store()` (line 49): Has a tenant isolation code smell:
    `$data['business_id'] = auth()->user()->business_id ?? Business::first()->id;`
- **Service & Tests:** `app/Services/App/Master/ModifierService.php` exists and `php artisan test --filter=ModifierServiceTest` passes completely (3 tests, 15 assertions passed in 1.04s).
- **Frontend Assets:** `resources/js/Pages/App/Master/Product/Modifier/Index.vue` and `ModifierForm.vue` already exist. In `resources/js/Composable/Sidebar/main.js` (lines 139-146), the sidebar menu item was commented out.

### B. RawMaterial Domain & Existing Implementations
- **Existing Route & Controller:** There is currently a `RawMaterialController` in the inventory module at `app/Http/Controllers/App/Inventory/RawMaterialController.php`, exposed via `routes/app/inventories.php` (lines 39-47) with URL `/inventories/raw-materials` and route names `inventory.raw-materials.*`.
- **No Controller in Master Namespace:** There is currently NO `RawMaterialController.php` in `app/Http/Controllers/App/Master/`.
- **Database Schema Defaults on `product_items`:** In `database/migrations/2026_09_25_190914_create_product_items_table.php` (lines 28-31):
  ```php
  $table->boolean('track_inventory')->default(false);
  $table->boolean('is_show')->default(true);
  $table->boolean('sellable')->default(true);
  $table->boolean('is_active')->default(true);
  ```
- **Discovered Data Inconsistency / Bug in `RawMaterialService`:**
  In `app/Services/App/Inventory/RawMaterialService.php` (lines 19-27):
  ```php
  $productItem = ProductItem::create([
      'business_id' => $business->id,
      'item_type' => 'raw_material',
      'name' => $data['name'],
      'sku' => $data['sku'] ?? null,
      'barcode' => $data['barcode'] ?? null,
      'track_inventory' => $data['track_inventory'] ?? $data['is_track_stock'] ?? true,
      'is_active' => $data['is_active'] ?? true,
  ]);
  ```
  `sellable` and `is_show` were omitted during creation, which means raw materials were created with `sellable = true` and `is_show = true` due to database defaults! This directly violates the strict architectural requirement: `sellable = false` and `is_show = false` for raw materials.

### C. RecipeTemplate Domain & BOM Structure
- **Controller Non-existence:** `RecipeTemplateController.php` does NOT exist in `app/Http/Controllers/App/Master/` or anywhere in the project.
- **Database Schema for Recipes:**
  - Table `recipe_versions`: Created in `2026_07_02_214446_create_product_management_tables.php` with columns `id`, `product_id`, `version_number`, `is_active`, `effective_from`.
  - Column `product_item_id` added in R1 migration `2026_10_22_100001_add_product_item_id_to_recipe_versions_table.php` as a nullable foreign key to `product_items(id)` with cascade delete.
  - Table `product_recipe_items`: Columns `id`, `recipe_version_id`, `product_item_id` (foreign key to raw material item in `product_items`), `qty`, `uom`.
- **Models:**
  - `RecipeVersion.php` has `$fillable = ['product_id', 'product_item_id', 'version_number', 'is_active', 'effective_from']`, `productItem(): BelongsTo`, `product(): BelongsTo`, and `items(): HasMany`.
  - `ProductRecipeItem.php` has `$fillable = ['recipe_version_id', 'product_item_id', 'qty', 'uom']`, `recipeVersion()`, and `productItem()`.
  - `ProductItem.php` has `recipeVersions(): HasMany`.
- **Existing `RecipeService`:** In `app/Services/App/Master/RecipeService.php` (lines 1-42), `syncRecipe(Product $product, array $items)` currently only attaches recipes to `$product->recipeVersions()`, does not accept `product_item_id`, does not support batch variant recipe syncing, and does not provide an automated HPP calculation method.

### D. Feature Gating Middleware in `routes/app/masters.php`
- `FeatureEnum.php` defines:
  - `FeatureEnum::PRODUCT_VARIANTS = 'product_variants'` (line 29)
  - `FeatureEnum::PRODUCT_MODIFIERS = 'product_modifiers'` (line 30)
  - `FeatureEnum::RECIPE_MANAGEMENT = 'recipe_management'` (line 31)
  - `FeatureEnum::RAW_MATERIALS = 'raw_materials'` (line 40)
- `bootstrap/app.php` registers middleware alias `'plan.feature' => CheckPlanFeature::class`.
- When `plan.feature:feature_name` blocks an unauthorized tier, `CheckPlanFeature::rejectAccess()` returns HTTP 403 with:
  ```json
  {
      "message": "paket langganan Anda tidak mendukung fitur ini. Tingkatkan paket langganan Anda untuk mengakses fitur ini.",
      "is_feature_locked": true,
      "feature": "<feature_name>"
  }
  ```
- R1 migration `2026_10_22_100004_add_product_features_and_plan_assignments.php` verified that `product_modifiers`, `recipe_management`, and `raw_materials` are registered features assigned to the `pro` subscription plan.

---

## 2. Logic Chain

1. **Routing and Modular Placement (Master Domain vs Inventory Domain):**
   - The original specification plan (`product_module_architecture_plan.md` §5.2 D, E & §5.3 A) establishes `/master/raw-materials`, `/master/recipes`, and `/master/modifiers` as core components under the Master Product menu group.
   - Therefore, a new `App\Http\Controllers\App\Master\RawMaterialController` and `App\Http\Controllers\App\Master\RecipeTemplateController` must be established under `routes/app/masters.php` with prefix `master.`.
   - Existing `/inventories/raw-materials` in `routes/app/inventories.php` can either be retained for backward compatibility or delegate to the service layer.

2. **Raw Material Data Invariants:**
   - Observations show that `product_items` defaults `is_show = true` and `sellable = true`.
   - The business rule requires: `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, and `track_inventory = true`.
   - RawMaterialController and its service MUST explicitly enforce these 4 attributes on every create/update operation, preventing any raw material from ever leaking into cashier POS catalogs.

3. **Recipe Template & Variant-Level BOM Architecture:**
   - Because R1 added `product_item_id` to `recipe_versions`, `RecipeVersion` can now represent both single-product BOM (`product_item_id = null` or pointing to default single `ProductItem`) and variant-specific BOM (`product_item_id = variant_item_id`).
   - `RecipeService` must be updated to accept `?string $productItemId` and provide `syncVariantRecipes(Product $product, array $recipes)`.
   - `RecipeTemplateController` will expose `/master/recipes` with full resource methods, calculating estimated HPP by joining ingredient raw materials with their `InventoryBalance` average costs.

4. **ModifierGroup Controller Activation:**
   - `ModifierGroupController` is already fully coded and tested; commenting it out in `routes/app/masters.php` was temporary.
   - Simply uncommenting the route group under `Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)` and removing the unsafe fallback `$data['business_id'] = auth()->user()->business_id ?? Business::first()->id` in `store()` fully resolves modifier management.

5. **Feature Gating Enforcement & Verification:**
   - Grouping `/master/modifiers` under `plan.feature:product_modifiers` ensures tenants on `micro` or `basic` tiers receive HTTP 403 `is_feature_locked = true`.
   - Grouping `/master/raw-materials` and `/master/recipes` under `plan.feature:recipe_management` ensures only `pro` tier users can access recipe and BOM endpoints.
   - For `product_variants`, creating or updating products with `has_variant = true` must be validated in `StoreProductRequest` / `UpdateProductRequest` or `ProductService` against `business->hasFeature(FeatureEnum::PRODUCT_VARIANTS)`.

---

## 3. Caveats

- **Frontend Views (Milestone R3 Dependency):** While `Inertia::render('Master/Product/Modifier/Index')` exists, `Master/Product/RawMaterial/Index.vue` and `Master/Product/Recipe/Index.vue` are slated for creation in Milestone R3. In R2, controllers can return these Inertia paths (or fallback gracefully) without breaking backend tests, as feature tests test JSON endpoints or Inertia response props without rendering Vue templates.
- **Inventory Balance Scoping:** Estimated HPP in recipe calculation requires an `outlet_id` for exact outlet-level costing, or defaults to the business-wide average across balances if no specific outlet is selected.

---

## 4. Conclusion & Blueprints

### Component Blueprint 1: `routes/app/masters.php`
Activate and add the missing route groups:
```php
// 4. Modul Modifier / Opsi Tambahan (Gated: product_modifiers)
Route::middleware('plan.feature:'.FeatureEnum::PRODUCT_MODIFIERS->value)
    ->group(function () {
        Route::resource('modifiers', ModifierGroupController::class)->except(['create', 'edit']);
    });

// 5. Modul Resep & Bahan Baku (Gated: recipe_management)
Route::middleware('plan.feature:'.FeatureEnum::RECIPE_MANAGEMENT->value)
    ->group(function () {
        Route::get('raw-materials/export', [RawMaterialController::class, 'export'])->name('raw-materials.export');
        Route::get('raw-materials/import/template', [RawMaterialController::class, 'importTemplate'])->name('raw-materials.importTemplate');
        Route::post('raw-materials/import', [RawMaterialController::class, 'import'])->name('raw-materials.import');
        Route::resource('raw-materials', RawMaterialController::class)->except(['create', 'edit']);

        Route::resource('recipes', RecipeTemplateController::class)->except(['create', 'edit']);
    });
```

### Component Blueprint 2: `app/Http/Controllers/App/Master/RawMaterialController.php`
```php
<?php

namespace App\Http\Controllers\App\Master;

use App\Constants\FlashDataVariable;
use App\Constants\ResourceMessage;
use App\Http\Controllers\Controller;
use App\Http\Requests\App\Inventory\RawMaterial\IndexRawMaterialRequest;
use App\Http\Requests\App\Inventory\RawMaterial\StoreRawMaterialRequest;
use App\Http\Requests\App\Inventory\RawMaterial\UpdateRawMaterialRequest;
use App\Jobs\Inventory\ExportRawMaterialJob;
use App\Jobs\Inventory\ImportRawMaterialJob;
use App\Models\Inventory\InventoryItem;
use App\Models\Master\ProductItem;
use App\Models\Uom;
use App\Services\App\Inventory\RawMaterialService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Facades\Excel;

class RawMaterialController extends Controller
{
    public function __construct(
        protected RawMaterialService $rawMaterialService
    ) {}

    public function index(IndexRawMaterialRequest $request): Response
    {
        $businessId = $request->user()->business_id;
        $validated = $request->validated();

        $rawMaterials = InventoryItem::query()
            ->where('inventory_items.business_id', $businessId)
            ->joinProductItem()
            ->where('product_items.item_type', 'raw_material')
            ->with(['uom:id,name', 'balances'])
            ->filters($validated)
            ->when($request->validated('sort'), function ($query, $sort) use ($request) {
                if ($sort === 'sku' || $sort === 'barcode') {
                    $query->orderBy("product_items.{$sort}", $request->validated('direction') ?? 'asc');
                } else {
                    $query->orderBy("inventory_items.{$sort}", $request->validated('direction') ?? 'asc');
                }
            }, function ($query) {
                $query->latest('inventory_items.created_at');
            })
            ->paginate($request->validated('per_page') ?? 15)
            ->withQueryString();

        $uoms = Uom::select('id', 'name')->where('status', 'active')->get();

        return Inertia::render('Master/Product/RawMaterial/Index', [
            'rawMaterials' => $rawMaterials,
            'uoms' => $uoms,
            'filters' => $request->only(['search', 'track_inventory', 'sort', 'direction']),
        ]);
    }

    public function store(StoreRawMaterialRequest $request): RedirectResponse
    {
        $data = $request->validated();
        // Mandatory invariants for raw materials
        $data['item_type'] = 'raw_material';
        $data['sellable'] = false;
        $data['is_show'] = false;
        $data['track_inventory'] = true;

        $this->rawMaterialService->createRawMaterial($data, $request->user()->business);

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Bahan baku berhasil ditambahkan.'
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $item = InventoryItem::currentBusiness()
            ->with(['uom', 'balances', 'productItem'])
            ->findOrFail($id);

        return response()->json($item);
    }

    public function update(UpdateRawMaterialRequest $request, string $id): RedirectResponse
    {
        $item = InventoryItem::currentBusiness()->findOrFail($id);
        $data = $request->validated();

        // Ensure invariants remain enforced
        $data['item_type'] = 'raw_material';
        $data['sellable'] = false;
        $data['is_show'] = false;
        $data['track_inventory'] = true;

        $this->rawMaterialService->updateRawMaterial($item, $data);

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Bahan baku berhasil diperbarui.'
        );
    }

    public function destroy(Request $request, string $id): RedirectResponse
    {
        $item = InventoryItem::currentBusiness()->findOrFail($id);

        // Check if raw material is referenced in any BOM recipes
        $isUsedInRecipe = \App\Models\Master\ProductRecipeItem::where('product_item_id', $item->product_item_id)->exists();
        if ($isUsedInRecipe) {
            return redirect()->back()->with(
                FlashDataVariable::FAILED->value,
                'Bahan baku tidak dapat dihapus karena sedang digunakan dalam resep aktif.'
            );
        }

        $hasMovements = $item->movements()->exists();
        $hasStock = $item->balances()->where('current_stock', '>', 0)->exists();

        if ($hasMovements || $hasStock) {
            $item->update(['is_active' => false]);
            if ($item->productItem) {
                $item->productItem->update(['is_active' => false]);
            }

            return redirect()->back()->with(
                FlashDataVariable::FAILED->value,
                'Bahan baku tidak dapat dihapus karena memiliki riwayat stok. Status telah dinonaktifkan.'
            );
        }

        if ($item->productItem) {
            $item->productItem->delete();
        }
        $item->delete();

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Bahan baku berhasil dihapus secara permanen.'
        );
    }

    public function export(IndexRawMaterialRequest $request): RedirectResponse
    {
        ExportRawMaterialJob::dispatch(
            Auth::user(),
            Auth::user()->business_id,
            $request->validated()
        );

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Ekspor sedang diproses di latar belakang.'
        );
    }

    public function importTemplate()
    {
        // Reuses standard export template logic
        $headers = ['Nama', 'SKU', 'Barcode', 'Satuan', 'Minimum Stok', 'Status Aktif'];
        $dummy = ['Gula Pasir', 'RM-GULA-01', '8991234567890', 'Kilogram', '10', 'Ya'];

        $export = new class([$dummy], $headers) implements FromArray, WithHeadings {
            public function __construct(private array $data, private array $headers) {}
            public function array(): array { return $this->data; }
            public function headings(): array { return $this->headers; }
        };

        return Excel::download($export, 'template_bahan_baku.xlsx');
    }

    public function import(Request $request): RedirectResponse
    {
        $request->validate(['file' => 'required|file|mimes:xlsx,xls,csv|max:10240']);
        $path = $request->file('file')->store('imports', 'local');

        ImportRawMaterialJob::dispatch(Auth::user(), $path, Auth::user()->business_id);

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'File berhasil diunggah. Proses impor sedang berjalan di latar belakang.'
        );
    }
}
```

### Component Blueprint 3: `app/Services/App/Inventory/RawMaterialService.php` Bugfix
Ensure `sellable` and `is_show` are strictly `false`:
```php
// In createRawMaterial():
$productItem = ProductItem::create([
    'business_id' => $business->id,
    'item_type' => 'raw_material',
    'name' => $data['name'],
    'sku' => $data['sku'] ?? null,
    'barcode' => $data['barcode'] ?? null,
    'track_inventory' => true,
    'is_show' => false,
    'sellable' => false,
    'is_active' => $data['is_active'] ?? true,
]);

// In updateRawMaterial():
if ($item->productItem) {
    $item->productItem->update(array_filter([
        'name' => $data['name'] ?? null,
        'sku' => $data['sku'] ?? null,
        'barcode' => $data['barcode'] ?? null,
        'track_inventory' => true,
        'is_show' => false,
        'sellable' => false,
        'is_active' => $data['is_active'] ?? null,
    ], fn ($val) => $val !== null));
}
```

### Component Blueprint 4: `app/Http/Controllers/App/Master/RecipeTemplateController.php`
```php
<?php

namespace App\Http\Controllers\App\Master;

use App\Constants\FlashDataVariable;
use App\Http\Controllers\Controller;
use App\Http\Requests\App\Master\Recipe\StoreRecipeTemplateRequest;
use App\Http\Requests\App\Master\Recipe\UpdateRecipeTemplateRequest;
use App\Models\Master\Product;
use App\Models\Master\ProductItem;
use App\Models\Master\RecipeVersion;
use App\Services\App\Master\RecipeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class RecipeTemplateController extends Controller
{
    public function __construct(
        protected RecipeService $recipeService
    ) {}

    public function index(Request $request): Response
    {
        $businessId = $request->user()->business_id;

        $recipes = RecipeVersion::query()
            ->whereHas('product', fn ($q) => $q->where('business_id', $businessId))
            ->where('is_active', true)
            ->with([
                'product:id,name,code,product_category_id',
                'product.category:id,name',
                'productItem:id,product_id,name,variant_combination,sku',
                'items.productItem.uom:id,name',
                'items.productItem.inventoryItem.balances',
            ])
            ->when($request->search, function ($q, $search) {
                $q->whereHas('product', fn ($sq) => $sq->whereLike('name', "%{$search}%"))
                    ->orWhereHas('productItem', fn ($sq) => $sq->whereLike('name', "%{$search}%"));
            })
            ->latest()
            ->paginate($request->per_page ?? 15)
            ->withQueryString();

        // Append estimated HPP
        $recipes->getCollection()->transform(function ($recipe) {
            $recipe->estimated_hpp = $this->recipeService->calculateEstimatedCost($recipe);
            return $recipe;
        });

        // Available products for recipe assignment
        $products = Product::currentBusiness()
            ->where('product_type', 'basic')
            ->select('id', 'name', 'has_variant')
            ->with('productItems:id,product_id,name,variant_combination,sku')
            ->get();

        // Available raw materials
        $rawMaterials = ProductItem::currentBusiness()
            ->where('item_type', 'raw_material')
            ->where('is_active', true)
            ->with(['uom:id,name', 'inventoryItem.balances'])
            ->get();

        return Inertia::render('Master/Product/Recipe/Index', [
            'recipes' => $recipes,
            'products' => $products,
            'rawMaterials' => $rawMaterials,
            'filters' => $request->only('search'),
        ]);
    }

    public function show(string $id): JsonResponse
    {
        $recipe = RecipeVersion::with([
            'product:id,name',
            'productItem:id,name,variant_combination',
            'items.productItem.uom',
            'items.productItem.inventoryItem.balances',
        ])->findOrFail($id);

        if ($recipe->product->business_id !== auth()->user()->business_id) {
            abort(403);
        }

        $recipe->estimated_hpp = $this->recipeService->calculateEstimatedCost($recipe);

        return response()->json($recipe);
    }

    public function store(StoreRecipeTemplateRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $product = Product::currentBusiness()->findOrFail($data['product_id']);

        $this->recipeService->syncRecipe(
            $product,
            $data['items'],
            $data['product_item_id'] ?? null
        );

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Template resep berhasil disimpan dan versi baru aktif.'
        );
    }

    public function update(UpdateRecipeTemplateRequest $request, string $id): RedirectResponse
    {
        $currentRecipe = RecipeVersion::with('product')->findOrFail($id);
        if ($currentRecipe->product->business_id !== $request->user()->business_id) {
            abort(403);
        }

        $data = $request->validated();
        $this->recipeService->syncRecipe(
            $currentRecipe->product,
            $data['items'],
            $data['product_item_id'] ?? $currentRecipe->product_item_id
        );

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Versi resep berhasil diperbarui.'
        );
    }

    public function destroy(string $id): RedirectResponse
    {
        $recipe = RecipeVersion::with('product')->findOrFail($id);
        if ($recipe->product->business_id !== auth()->user()->business_id) {
            abort(403);
        }

        $recipe->update(['is_active' => false]);

        // If no active recipes remain, update product has_recipe flag
        if (! $recipe->product->recipeVersions()->where('is_active', true)->exists()) {
            $recipe->product->update(['has_recipe' => false]);
        }

        return redirect()->back()->with(
            FlashDataVariable::SUCCESS->value,
            'Template resep berhasil dinonaktifkan.'
        );
    }
}
```

### Component Blueprint 5: FormRequests for Recipes
Create `app/Http/Requests/App/Master/Recipe/StoreRecipeTemplateRequest.php`:
```php
<?php

namespace App\Http\Requests\App\Master\Recipe;

use Illuminate\Foundation\Http\FormRequest;

class StoreRecipeTemplateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => ['required', 'uuid', 'exists:products,id'],
            'product_item_id' => ['nullable', 'uuid', 'exists:product_items,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_item_id' => ['required', 'uuid', 'exists:product_items,id'],
            'items.*.qty' => ['required', 'numeric', 'min:0.0001'],
            'items.*.uom' => ['required', 'string', 'max:50'],
        ];
    }
}
```
And `UpdateRecipeTemplateRequest.php` matching rules with optional `product_id`.

### Component Blueprint 6: `RecipeService.php` Enhancements
Update `app/Services/App/Master/RecipeService.php`:
```php
public function syncRecipe(Product $product, array $items, ?string $productItemId = null): RecipeVersion
{
    return DB::transaction(function () use ($product, $items, $productItemId) {
        $query = $product->recipeVersions();
        if ($productItemId) {
            $query->where('product_item_id', $productItemId);
        } else {
            $query->whereNull('product_item_id');
        }
        $query->update(['is_active' => false]);

        $nextVersion = ($product->recipeVersions()->max('version_number') ?? 0) + 1;

        $recipe = $product->recipeVersions()->create([
            'product_item_id' => $productItemId,
            'version_number' => $nextVersion,
            'is_active' => true,
            'effective_from' => now(),
        ]);

        foreach ($items as $item) {
            $recipe->items()->create([
                'product_item_id' => $item['product_item_id'],
                'qty' => $item['qty'],
                'uom' => $item['uom'],
            ]);
        }

        $product->update(['has_recipe' => true]);

        $this->auditLogService->log(
            $product->business_id,
            'recipe',
            $recipe->id,
            'created',
            null,
            $recipe->load('items')->toArray()
        );

        return $recipe;
    });
}

public function syncVariantRecipes(Product $product, array $recipes): Collection
{
    $synced = collect();
    foreach ($recipes as $entry) {
        $productItemId = $entry['product_item_id'] ?? null;
        $items = $entry['items'] ?? [];
        if (! empty($items)) {
            $synced->push($this->syncRecipe($product, $items, $productItemId));
        }
    }
    return $synced;
}

public function calculateEstimatedCost(RecipeVersion $recipe, ?string $outletId = null): float
{
    $totalCost = 0.0;
    $recipe->loadMissing('items.productItem.inventoryItem.balances');

    foreach ($recipe->items as $item) {
        $balances = $item->productItem?->inventoryItem?->balances;
        if (! $balances || $balances->isEmpty()) {
            continue;
        }

        $effectiveCost = $outletId
            ? ($balances->firstWhere('outlet_id', $outletId)?->average_cost ?? 0.0)
            : ($balances->avg('average_cost') ?? 0.0);

        $totalCost += ((float) $item->qty * (float) $effectiveCost);
    }

    return round($totalCost, 2);
}
```

### Component Blueprint 7: `ModifierGroupController.php` Fix
In `app/Http/Controllers/App/Master/ModifierGroupController.php` line 49:
```php
// BEFORE:
$data['business_id'] = auth()->user()->business_id ?? Business::first()->id;

// AFTER:
$data['business_id'] = $request->user()->business_id;
```

### Component Blueprint 8: `tests/Feature/Master/ProductFeatureGatingTest.php`
Automated test suite verifying 403 `is_feature_locked` responses:
- `test_modifiers_route_locked_for_micro_tier()`
- `test_modifiers_route_accessible_for_pro_tier()`
- `test_raw_materials_route_locked_for_micro_tier()`
- `test_raw_materials_route_accessible_for_pro_tier()`
- `test_recipes_route_locked_for_micro_tier()`
- `test_recipes_route_accessible_for_pro_tier()`

---

## 5. Verification Method

1. **Verify Routes in CLI:**
   Run:
   ```bash
   php artisan route:list --path=master
   ```
   Confirm `master.modifiers.*`, `master.raw-materials.*`, and `master.recipes.*` appear with their corresponding `plan.feature:...` middleware.

2. **Verify Tests:**
   Run:
   ```bash
   php artisan test --compact --filter=ModifierServiceTest
   php artisan test --compact --filter=RecipeServiceTest
   php artisan test --compact --filter=ProductFeatureGatingTest
   ```

3. **Verify Code Formatting:**
   Run:
   ```bash
   vendor/bin/pint --dirty --format agent
   ```
