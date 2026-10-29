# Handoff Report: Milestone R5 — POS UI, Decoupled Stock Visualization & Barcode Scanning

**Agent:** Explorer 3 (`explorer_r5_3`)  
**Target Workspace:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`  
**Milestone:** R5 (Variant Dialog, Cart Integration & Decoupled Stock POS UI)  
**Date:** 2026-10-22  
**Status:** COMPLETE (Ready for Worker R5 Implementation)

---

## 1. Observation

### Current Codebase Anatomy & Locations

1. **POS Catalog Grid & Item Card (`lib/features/pos/presentation/widgets/product_grid.dart`):**
   - Lines 85–126 (`_handleSelectItem`):
     ```dart
     final displayMode = ref.read(posDisplayModeProvider);
     final isProductMode = displayMode == 'product';
     final hasVariantsOrModifiers = product.hasVariants || product.hasModifiers;

     if (isProductMode && hasVariantsOrModifiers) {
       VariantDialog.show(context, product);
     } else {
       final cartItem = CartItem(
         id: DateTime.now().millisecondsSinceEpoch.toString(),
         productId: product.isProductMode
             ? product.id
             : (product.inventory?.productId ?? product.product?.id ?? product.id),
         inventoryItemId: product.isProductMode ? '' : product.id,
         name: product.name,
         price: product.price,
         qty: 1,
       );
       ref.read(cartProvider.notifier).addItem(cartItem);
       ...
     }
     ```
   - Lines 203–352 (`_ProductCard`):
     - Displays `Icons.ramen_dining` circle avatar, `itemName`, `itemPrice`, and a `Nonaktif` banner if `!isActive`.
     - Lines 323–345: Displays a yellow badge `+ Opsi` at `top: 12, right: 12` if `showOptionsBadge && hasVariantsOrModifiers && isActive`.
     - **Deficiency:** `_ProductCard` currently does **NOT** display stock quantity anywhere on the card. Cashiers have no visibility of current stock or infinite stock (`track_inventory == false`).

2. **Catalog Products Management Screen (`lib/features/pos/presentation/pages/products_screen.dart`):**
   - Lines 79–84 (`_formatStock`): Formats `double stock` to integer or single decimal string.
   - Line 662 (List View):
     ```dart
     isService ? 'Produk Layanan' : 'Stok: ${_formatStock(stock)} ${item.unit}'
     ```
   - Line 843 (Card View):
     ```dart
     isService ? 'Layanan' : 'Stok: ${_formatStock(item.stock)} ${item.unit}'
     ```
   - **Deficiency:** When `trackInventory == false` or `item.stock == null`, it shows `Stok: 0 Pcs` instead of the required infinity symbol `∞`.

3. **Hardware Barcode Scanner & Omni-Search (`lib/features/pos/presentation/pages/pos_layout.dart`):**
   - Line 625: Wraps layout in `HardwareScannerListener(onBarcodeScanned: (barcode) => _handleBarcodeScanned(barcode), child: ...)`.
   - Lines 134–171 (`_handleBarcodeScanned`):
     ```dart
     Future<void> _handleBarcodeScanned(String barcode) async {
       final query = barcode.trim();
       if (query.isEmpty) return;
       final repository = ref.read(posRepositoryProvider);
       final matchedItem = await repository.findItemByBarcodeOrSku(query);

       if (matchedItem != null && mounted) {
         final cartItem = CartItem(...);
         ref.read(cartProvider.notifier).addItem(cartItem);
         ...
       }
     }
     ```
   - Lines 751–798 (`TextField.onSubmitted`): Duplicates the exact logic of `_handleBarcodeScanned`.
   - **Critical Deficiency:** If a cashier scans a **parent product barcode** (where `hasVariants == true`), both handlers unconditionally add the first `product_items` row to the cart instead of popping up `VariantDialog.show(context, parentPosItem)`. Conversely, scanning a specific **variant barcode** should directly add that variant to the cart.

4. **Data Repository Query Alias Gap (`lib/features/pos/data/pos_repository.dart`):**
   - Lines 442–491 (`findItemByBarcodeOrSku`):
     The query joins `product_items pi` with `products p`. It selects:
     `pi.name as name`, `pi.sku as sku`, `pi.barcode as barcode`.
     It does **NOT** alias `p.name as product_name`, `p.barcode as product_barcode`, `p.sku as product_sku`.
     As a result, at lines 575–589, `Product(...)` is instantiated using `pi.sku` and `pi.barcode`. If the scanned barcode matches `p.barcode`, `matchedItem.product.barcode` does not hold `p.barcode`, preventing Dart code from verifying whether the scan was a parent barcode or a variant barcode.

5. **Decoupled Stock Cart Validation (`lib/features/pos/data/pos_repository.dart` & `cart_panel.dart`):**
   - Lines 746–750 (`checkCartStockAvailability`):
     ```dart
     if (inventory != null && inventory.trackInventory) {
       if (inventory.stock < requiredQty) {
         insufficientItems.add(...);
       }
     }
     ```
     Items with `track_inventory == false` do not have inventory balance entries or have `trackInventory == false`. `CartItem` must carry `trackInventory: bool` to ensure cart validation never blocks checkout.

6. **Test Baseline:**
   - Command: `/Users/whykrr/flutter/bin/flutter test` -> **83 passing tests, 0 failures**.
   - No automated tests currently exist for `VariantDialog`, barcode resolution flow, or stock visualization widgets.

---

## 2. Logic Chain

### A. Decoupled Stock Visualization (`∞`)
1. In the unified item architecture, products or items with `track_inventory == false` (e.g. food items made to order, digital services, unmetered goods) have no stock constraints.
2. In `_ProductCard` (`product_grid.dart`):
   - A dedicated top-left stock status badge must be added, mirroring the top-right `+ Opsi` badge.
   - If `!posItem.trackInventory` (or `posItem.stock == null`):
     Render `Stok: ∞` using the infinity symbol `∞` (`\u221E`).
   - If `posItem.isService`:
     Render `Layanan`.
   - If `posItem.trackInventory`:
     Render `Stok: ${_formatStock(posItem.stock)}`, colored with `SolluColors.danger` if `stock <= 0`.
3. In `products_screen.dart`:
   - Both List View (`line 662`) and Card View (`line 843`) must call `_formatStockDisplay(item)`:
     ```dart
     String _formatStockDisplay(PosItem item) {
       if (item.isService) return 'Layanan';
       if (!item.trackInventory) return 'Stok: ∞';
       return 'Stok: ${_formatStock(item.stock)} ${item.unit}';
     }
     ```
   - Sorting by `stock_desc` / `stock_asc` (lines 460–470) should treat untracked products as `double.infinity`.

### B. Barcode Scanning & Omni-Search Differentiation
1. When a hardware scanner triggers `onBarcodeScanned` or user hits Enter on the Omni-Search field:
   - Call `posRepository.findItemByBarcodeOrSku(query)`.
2. In `pos_repository.dart`, update SQL select to include:
   `p.name as product_name, p.barcode as product_barcode, p.sku as product_sku`.
   Construct `Product` inside `PosItem` with `name: productName, sku: productSku, barcode: productBarcode`.
3. Evaluation Logic in `pos_layout.dart`:
   - **Case 1: Specific Variant Barcode Scanned**
     `query == matchedItem.barcode || query == matchedItem.sku`
     The barcode matches the physical variant item. The specific `product_item` is known.
     -> **Action:** Add directly to cart (`addItem(cartItem)` with `productItemId: matchedItem.id`, `variantCombination: matchedItem.variantCombination`). Show SnackBar: `Item ditambahkan: ${matchedItem.name}`. Do **not** open variant dialog.
   - **Case 2: Parent Product Barcode Scanned (Product Has Variants)**
     `matchedItem.hasVariants == true` AND `(query == matchedItem.product?.barcode || query == matchedItem.product?.sku || query != matchedItem.barcode)`
     The cashier scanned the parent box or shelf tag of a variant family. The specific variant has not been chosen.
     -> **Action:** Pop up `VariantDialog.show(context, parentPosItem)`. The cashier selects the variant and modifiers on screen.
   - **Case 3: Single Product (No Variants)**
     `matchedItem.hasVariants == false`
     -> **Action:** Add directly to cart.
   - **Case 4: Inactive Item**
     `!matchedItem.isActive`
     -> **Action:** Show warning SnackBar: `${matchedItem.name} sedang dinonaktifkan.` Do not add to cart or open dialog.

---

## 3. Caveats

1. **Co-Dependency with Explorer R5-1 & R5-2:**
   - Explorer R5-1 (`explorer_r5_1`) is refactoring `VariantDialogNotifier` to resolve prices and selections using SQLite table `product_item_variant_group_options`.
   - Explorer R5-2 (`explorer_r5_2`) is updating `CartItem` to include `productItemId`, `variantCombination`, and `trackInventory`.
   - The UI blueprints below align strictly with those contracts.
2. **Card Aspect Ratio:**
   `ProductGrid` uses `childAspectRatio: 0.85` in a 4-column layout. The stock badge must use compact typography (`fontSize: 10`, `padding: 6x3`) so it fits cleanly alongside the top-right `+ Opsi` badge without overlapping product images or titles.
3. **Linter Guard:**
   Ensure all `ScaffoldMessenger.of(context)` and `Navigator.of(context)` calls after `await` are guarded by `if (mounted)` to satisfy Flutter's `use_build_context_synchronously`.

---

## 4. Conclusion & Blueprints for Worker R5

### Blueprint 1: Decoupled Stock Badges in `lib/features/pos/presentation/widgets/product_grid.dart`

In `_ProductCard`:
Add a helper method `_formatStock`:
```dart
String _formatStock(double stock) {
  if (stock == stock.roundToDouble()) {
    return stock.toInt().toString();
  }
  return stock.toStringAsFixed(1);
}
```

In `Stack` of `_ProductCard` (around line 322):
```dart
// 1. Top-Left Stock Badge (Decoupled Stock Visualization)
Positioned(
  top: 12,
  left: 12,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: !posItem.trackInventory
          ? const Color(0xFFF1F5F9)
          : (posItem.stock <= 0
              ? SolluColors.danger.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9)),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: !posItem.trackInventory
            ? const Color(0xFFCBD5E1)
            : (posItem.stock <= 0
                ? SolluColors.danger.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0)),
        width: 0.8,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          !posItem.trackInventory
              ? Icons.all_inclusive_rounded
              : (posItem.isService ? Icons.room_service_rounded : Icons.inventory_2_outlined),
          size: 11,
          color: !posItem.trackInventory
              ? const Color(0xFF475569)
              : (posItem.stock <= 0 ? SolluColors.danger : const Color(0xFF475569)),
        ),
        const SizedBox(width: 3),
        Text(
          !posItem.trackInventory
              ? '∞'
              : (posItem.isService ? 'Layanan' : _formatStock(posItem.stock)),
          style: TextStyle(
            color: !posItem.trackInventory
                ? const Color(0xFF475569)
                : (posItem.stock <= 0 ? SolluColors.danger : const Color(0xFF475569)),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    ),
  ),
),

// 2. Top-Right Options Badge
if (showOptionsBadge && hasVariantsOrModifiers && isActive)
  Positioned(
    top: 12,
    right: 12,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107), // Yellow badge
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '+ Opsi',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    ),
  ),
```

---

### Blueprint 2: Decoupled Stock in `lib/features/pos/presentation/pages/products_screen.dart`

Add `_formatStockDisplay`:
```dart
String _formatStockDisplay(PosItem item) {
  if (item.isService) return 'Layanan';
  if (!item.trackInventory) return 'Stok: ∞';
  return 'Stok: ${_formatStock(item.stock)} ${item.unit}';
}
```

Update Line 662 (List View):
```dart
Text(
  _formatStockDisplay(item),
  style: TextStyle(
    color: item.isService ? const Color(0xFF0284C7) : SolluColors.textMuted,
    fontSize: 12,
    fontWeight: item.isService ? FontWeight.w500 : FontWeight.normal,
  ),
),
```

Update Line 843 (Card View):
```dart
Text(
  _formatStockDisplay(item),
  style: TextStyle(
    fontSize: 11,
    color: item.isService ? const Color(0xFF0284C7) : SolluColors.textMuted,
    fontWeight: item.isService ? FontWeight.w600 : FontWeight.normal,
  ),
),
```

Update Sorting (Lines 460–470):
```dart
case 'stock_desc':
  filteredProducts.sort((a, b) {
    final stockA = a.trackInventory ? a.stock : double.infinity;
    final stockB = b.trackInventory ? b.stock : double.infinity;
    return stockB.compareTo(stockA);
  });
  break;
case 'stock_asc':
  filteredProducts.sort((a, b) {
    final stockA = a.trackInventory ? a.stock : double.infinity;
    final stockB = b.trackInventory ? b.stock : double.infinity;
    return stockA.compareTo(stockB);
  });
  break;
```

---

### Blueprint 3: Repository Alias Preservation in `lib/features/pos/data/pos_repository.dart`

In `findItemByBarcodeOrSku`:
Update the SQL `SELECT`:
```sql
SELECT 
  pi.id as id,
  pi.product_id as product_id,
  pi.name as name,
  pi.variant_combination as variant_combination,
  pi.sku as sku,
  pi.barcode as barcode,
  pi.track_inventory as track_inventory,
  pi.is_active as item_is_active,
  pi.sellable as item_sellable,
  COALESCE(i.stock, 0.0) as stock,
  COALESCE(pi.unit, p.unit, 'Pcs') as unit,
  p.category_id as category_id,
  COALESCE(p.product_type, 'basic') as product_type,
  p.is_available as product_is_available,
  p.has_variants as product_has_variants,
  p.has_modifiers as product_has_modifiers,
  p.has_recipe as product_has_recipe,
  (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
  (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
  COALESCE(...) as item_price,
  i.id as inventory_id,
  p.name as product_name,
  p.barcode as product_barcode,
  p.sku as product_sku
FROM product_items pi
INNER JOIN products p ON pi.product_id = p.id
...
```

Instantiate `Product` with parent attributes:
```dart
final productName = row.read<String>('product_name');
final productBarcode = row.read<String?>('product_barcode');
final productSku = row.read<String?>('product_sku');

product: Product(
  id: productId,
  name: productName,
  categoryId: categoryId,
  sku: productSku,
  barcode: productBarcode,
  price: itemPrice,
  isAvailable: isProductAvailable,
  productType: productType,
  unit: unit,
  hasVariants: hasVariants,
  hasModifiers: hasModifiers,
  hasRecipe: hasRecipe,
  trackInventory: trackInventory,
),
```

---

### Blueprint 4: Unified Barcode & Omni-Search Handler in `lib/features/pos/presentation/pages/pos_layout.dart`

Replace `_handleBarcodeScanned` and `TextField.onSubmitted` with a unified method:

```dart
Future<void> _handleBarcodeOrSearchSubmit(
  String input, {
  bool fromSearchField = false,
}) async {
  final query = input.trim();
  if (query.isEmpty) return;

  final repository = ref.read(posRepositoryProvider);
  final matchedItem = await repository.findItemByBarcodeOrSku(query);

  if (!mounted) return;

  if (matchedItem == null) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode/SKU "$query" tidak ditemukan dalam katalog'),
        backgroundColor: SolluColors.danger,
        duration: const Duration(seconds: 2),
      ),
    );
    if (fromSearchField) {
      _searchController.clear();
      ref.read(posSearchQueryProvider.notifier).setQuery('');
      _searchFocusNode.requestFocus();
    }
    return;
  }

  if (!matchedItem.isActive) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${matchedItem.name} sedang dinonaktifkan dari kasir.'),
        backgroundColor: SolluColors.danger,
        duration: const Duration(seconds: 2),
      ),
    );
    if (fromSearchField) {
      _searchController.clear();
      ref.read(posSearchQueryProvider.notifier).setQuery('');
      _searchFocusNode.requestFocus();
    }
    return;
  }

  // Differentiate: Specific Variant Barcode vs Parent Product Barcode
  final isVariantBarcode =
      matchedItem.barcode == query || matchedItem.sku == query;
  final isParentScan = matchedItem.hasVariants && !isVariantBarcode;

  if (isParentScan) {
    final parentPosItem = PosItem(
      id: matchedItem.product?.id ?? matchedItem.id,
      name: matchedItem.product?.name ?? matchedItem.name,
      categoryId: matchedItem.categoryId,
      price: matchedItem.price,
      stock: matchedItem.stock,
      unit: matchedItem.unit,
      productType: matchedItem.productType,
      isActive: matchedItem.isActive,
      hasVariants: true,
      hasModifiers: matchedItem.hasModifiers,
      isProductMode: true,
      product: matchedItem.product,
      trackInventory: matchedItem.trackInventory,
    );

    if (fromSearchField) {
      _searchController.clear();
      ref.read(posSearchQueryProvider.notifier).setQuery('');
    }

    await VariantDialog.show(context, parentPosItem);
  } else {
    // Add specific variant item directly to cart
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: matchedItem.product?.id ??
          (matchedItem.isProductMode
              ? matchedItem.id
              : (matchedItem.inventory?.productId ?? matchedItem.id)),
      productItemId: matchedItem.productItemId ?? matchedItem.id,
      inventoryItemId: matchedItem.isProductMode ? '' : matchedItem.id,
      name: matchedItem.name,
      price: matchedItem.price,
      qty: 1,
      trackInventory: matchedItem.trackInventory,
    );
    ref.read(cartProvider.notifier).addItem(cartItem);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ditambahkan: ${matchedItem.name}'),
        backgroundColor: SolluColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    if (fromSearchField) {
      _searchController.clear();
      ref.read(posSearchQueryProvider.notifier).setQuery('');
      _searchFocusNode.requestFocus();
    }
  }
}
```

Connect both input channels:
1. `HardwareScannerListener`:
   ```dart
   HardwareScannerListener(
     onBarcodeScanned: (barcode) => _handleBarcodeOrSearchSubmit(barcode, fromSearchField: false),
     child: ...
   ```
2. `TextField`:
   ```dart
   TextField(
     controller: _searchController,
     focusNode: _searchFocusNode,
     onChanged: (val) {
       ref.read(posSearchQueryProvider.notifier).setQuery(val);
     },
     onSubmitted: (val) => _handleBarcodeOrSearchSubmit(val, fromSearchField: true),
     ...
   ```

---

## 5. Verification Method

### Test Suite Commands

```bash
# 1. Run all unit and widget tests
/Users/whykrr/flutter/bin/flutter test

# 2. Run static analysis
/Users/whykrr/flutter/bin/flutter analyze lib/features/pos/
```

### New Widget / Unit Tests to Implement in `test/features/pos/presentation/pos_barcode_and_stock_test.dart`

Worker R5 must create automated tests covering:

1. **Decoupled Stock Visualization Test:**
   - Verify that when `posItem.trackInventory == false`, `_ProductCard` renders the text `'∞'`.
   - Verify that when `posItem.trackInventory == true`, `_ProductCard` renders `posItem.stock.toInt().toString()`.
   - Verify that `products_screen.dart` renders `'Stok: ∞'` for untracked products.

2. **Barcode Scanning Distinction Test:**
   - Test scanning a specific variant barcode (`pi.barcode`): verifies `CartItem` with `productItemId == variant.id` is added directly to cart without opening dialog.
   - Test scanning a parent product barcode (`p.barcode` where `hasVariants == true`): verifies `VariantDialog` is opened.
   - Test scanning a single product barcode (`hasVariants == false`): verifies item is added directly to cart.
   - Test scanning an inactive product barcode: verifies item is not added and error message is displayed.

3. **Decoupled Stock Checkout Test:**
   - Verify that a cart containing an item with `trackInventory == false` and `stock == 0` completes checkout without triggering `InsufficientStockDialog`.
