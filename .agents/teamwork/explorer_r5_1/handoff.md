# Handoff Report: Milestone R5 — Variant Dialog & Cart Integration (sollu-pos-client)

**Agent:** explorer_r5_1  
**Target Workspace:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`  
**Handoff Type:** Hard (Investigation complete, full implementation blueprint delivered)

---

## 1. Observation

### A. Current Implementation of Variant Dialog & Providers
1. **`lib/features/pos/presentation/providers/variant_dialog_provider.dart`**:
   - **Null Pointer Bug on Initialization (Line 80-83):**
     ```dart
     final productId = _posItem.isProductMode
         ? _posItem.id
         : _posItem.inventory!.productId;
     ```
     For products with `track_inventory = false` (or service products), `_posItem.inventory` is `null`. Accessing `_posItem.inventory!.productId` throws an unhandled `Null check operator used on a null value` error.
   - **Single Option Resolution & Obsolete Pivot Query (Line 151-175):**
     ```dart
     final variantOptionId = currentVariants.values.firstOrNull; // Only takes 1 option!
     ...
     FROM inventories i
     INNER JOIN inventory_item_variant_group_options piv ON piv.inventory_item_id = i.id
     WHERE i.product_id = ? AND piv.variant_group_option_id = ?
     ```
     This query is fundamentally broken in three ways:
     - It only reads `firstOrNull` (1-dimensional), completely incapable of resolving multi-attribute combinations (e.g. Size + Color + Ice).
     - It queries the deprecated table `inventory_item_variant_group_options`, which is empty because backend sync now populates `product_item_variant_group_options`.
     - It assumes an `inventories` row exists; if `track_inventory = false`, no inventory record exists, so price resolves to `0.0`.
   - **Missing `productItemId` Tracking:**
     `VariantDialogState` does not store `resolvedProductItemId` or `resolvedPosItem`, nor does it validate if the combination actually exists in `product_items` and is active/sellable.
   - **Missing Validation for Required Modifiers:**
     `ModifierGroup.minSelected` is ignored by the submit action, allowing the user to bypass mandatory modifiers.

2. **`lib/features/pos/presentation/widgets/variant_dialog.dart`**:
   - In lines 236-259, `CartItem` is constructed with `variantGroupOptionId: state.selectedVariants.values.firstOrNull` and without `productItemId` or `trackInventory`.
   - Subtotal is computed without reactive awareness of non-existent combinations (if a variant combination does not exist, "Tambah" button remains enabled).

3. **`lib/features/pos/presentation/providers/cart_provider.dart`**:
   - `CartItem` currently has:
     ```dart
     class CartItem {
       final String id;
       final String productId;
       final String inventoryItemId;
       final String? variantGroupOptionId;
       final String name;
       final double price;
       final int qty;
       final String? discountType;
       final double? discountValue;
       final String? notes;
       final Map<String, String> selectedVariants;
       final Map<String, List<String>> selectedModifiers;
     }
     ```
   - Missing fields: `productItemId`, `trackInventory`, and `variantCombination`.
   - In `CartNotifier.addItem` (lines 127-140), equality check relies on `inventoryItemId` and `productId`. If two different variants of a non-inventory product are added, they both have empty `inventoryItemId` and may collide or mishandle merges unless checked by `productItemId`.
   - In `CartNotifier.updateItemDetails` (lines 173-204), `CartItem` is reconstructed with hardcoded arguments omitting modern attributes.

4. **`lib/features/pos/data/pos_repository.dart`**:
   - `findProductItemIdForVariants(productId, variantGroupOptionIds)` is implemented at lines 597-627 and verified passing tests in `test/features/pos/data/pos_repository_unified_items_test.dart`:
     ```sql
     SELECT piv.product_item_id
     FROM product_item_variant_group_options piv
     INNER JOIN product_items pi ON pi.id = piv.product_item_id
     WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
     GROUP BY piv.product_item_id
     HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
       AND (SELECT COUNT(*) FROM product_item_variant_group_options WHERE product_item_id = piv.product_item_id) = ?
     LIMIT 1
     ```
   - `checkCartStockAvailability(items)` (lines 671-754) already has:
     ```dart
     try {
       if (item.trackInventory == false) {
         continue; // Skips stock check!
       }
     } catch (_) {}
     ```
     Once `CartItem.trackInventory` is exposed, non-inventory items are cleanly skipped from stock validation.
   - However, `PosRepository` lacks direct helper methods:
     - `getPosItemByProductItemId(String productItemId)`
     - `findDefaultProductItemId(String productId)`

5. **`lib/features/pos/data/transaction_repository.dart`**:
   - Lines 272-288: When inserting into `_database.transactionItems`, `productItemId` is omitted despite `TransactionItems.productItemId` existing in Drift schema (`transaction_tables.dart` line 93).
   - Lines 792-805: Online transaction sync payload does not send `'product_item_id'`.
   - Lines 309-322: Stock deduction checks `inventory.trackInventory`, but does not guard against items where `cartItem.trackInventory == false`.

6. **Stock Display (`∞`) & Decoupled Stock Behavior**:
   - `lib/features/pos/presentation/pages/products_screen.dart` (lines 662 & 843) formats stock via `_formatStock(stock)` without checking `!item.trackInventory`.
   - `lib/features/pos/presentation/widgets/product_grid.dart` (`_ProductCard`) displays no stock information.
   - `variant_dialog.dart` displays no stock information for the selected variant.

---

## 2. Logic Chain

1. **Multi-Attribute Resolution:**
   - A product may have $N$ variant groups (e.g. Size, Color, Temperature).
   - In `VariantDialogState`, each group has a selected option: `selectedVariants = { "grp-size": "opt-large", "grp-temp": "opt-ice" }`.
   - Passing `['opt-large', 'opt-ice']` into `posRepo.findProductItemIdForVariants(productId, optionIds)` finds the unique `ProductItem` whose pivot rows in `product_item_variant_group_options` match all $N$ options and has no extraneous options.
   - If found, `getPosItemByProductItemId(productItemId)` fetches the item's resolved price, stock, and metadata.
   - If not found (unregistered combination in matrix), `resolvedProductItemId` is `null`, `isCombinationAvailable = false`, and the UI disables the "Tambah" button with a clear Indonesian warning: *"Kombinasi varian ini tidak tersedia"*.

2. **Single Product with Modifiers Support:**
   - If a product has no variant groups (`variantGroups.isEmpty`) but has modifiers (`hasModifiers == true`), `findDefaultProductItemId(productId)` resolves the default `ProductItem`.
   - The dialog skips the variant section and displays only modifier groups.

3. **Modifier Selection and Total Pricing:**
   - Modifier groups can be `radio` / `maxSelected == 1` (single choice) or `checkbox` (multiple choices up to `maxSelected`).
   - Total unit price = `variantPrice + sum(selectedModifierPrices)`.
   - Subtotal = `totalUnitPrice * qty`.
   - Validation ensures `selectedModifiers.length >= minSelected` for mandatory groups.

4. **Decoupled Stock & Cart Integration:**
   - When added to `CartItem`, `productItemId` and `trackInventory` are explicitly populated.
   - In `checkCartStockAvailability(items)`, `item.trackInventory == false` skips stock availability checks, guaranteeing checkout is never blocked by zero stock for non-tracked or service items.
   - Stock display shows `Stok: ∞` when `track_inventory == false`.

---

## 3. Implementation Blueprints for Worker R5

### Blueprint 1: Add Helper Methods in `lib/features/pos/data/pos_repository.dart`

Add the following methods to `PosRepository`:

```dart
  /// Fetches a PosItem directly by its product_item_id
  Future<PosItem?> getPosItemByProductItemId(String productItemId) async {
    final rows = await _database
        .customSelect(
          '''
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
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE pi.id = ?
      LIMIT 1
      ''',
          variables: [Variable.withString(productItemId)],
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.productPrices,
            _database.variantGroups,
            _database.productModifierGroups,
          },
        )
        .get();

    if (rows.isEmpty) return null;

    final row = rows.first;
    final id = row.read<String>('id');
    final productId = row.read<String>('product_id');
    final name = row.read<String>('name');
    final variantCombination = row.read<String?>('variant_combination');
    final sku = row.read<String?>('sku');
    final barcode = row.read<String?>('barcode');
    final trackInventory = row.read<bool>('track_inventory');
    final isItemActive = row.read<bool>('item_is_active');
    final isProductAvailable = row.read<bool>('product_is_available');
    final stock = row.read<double>('stock');
    final unit = row.read<String>('unit');
    final categoryId = row.read<String?>('category_id');
    final productType = row.read<String>('product_type');
    final variantCount = row.read<int>('variant_count');
    final modifierCount = row.read<int>('modifier_count');
    final itemPrice = row.read<double>('item_price');
    final inventoryId = row.read<String?>('inventory_id');
    final hasVariants =
        row.read<bool?>('product_has_variants') ?? (variantCount > 0);
    final hasModifiers =
        row.read<bool?>('product_has_modifiers') ?? (modifierCount > 0);
    final hasRecipe = row.read<bool?>('product_has_recipe') ?? false;

    final effectiveActive = isItemActive && isProductAvailable;

    return PosItem(
      id: id,
      name: name,
      categoryId: categoryId,
      price: itemPrice,
      stock: stock,
      unit: unit,
      productType: productType,
      isActive: effectiveActive,
      hasVariants: hasVariants,
      hasModifiers: hasModifiers,
      isProductMode: false,
      productItemId: id,
      variantCombination: variantCombination,
      sku: sku,
      barcode: barcode,
      trackInventory: trackInventory,
      inventory: inventoryId != null
          ? Inventory(
              id: inventoryId,
              productId: productId,
              productItemId: id,
              name: name,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              isActive: effectiveActive,
              stock: stock,
              unit: unit,
            )
          : null,
      product: Product(
        id: productId,
        name: name,
        categoryId: categoryId,
        sku: sku,
        barcode: barcode,
        price: itemPrice,
        isAvailable: isProductAvailable,
        productType: productType,
        unit: unit,
        hasVariants: hasVariants,
        hasModifiers: hasModifiers,
        hasRecipe: hasRecipe,
        trackInventory: trackInventory,
      ),
    );
  }

  /// Resolves the default product_item_id for a single product without variants
  Future<String?> findDefaultProductItemId(String productId) async {
    final row = await _database.customSelect(
      '''
      SELECT id FROM product_items
      WHERE product_id = ?
      ORDER BY (variant_combination IS NULL) DESC, id ASC
      LIMIT 1
      ''',
      variables: [Variable.withString(productId)],
    ).getSingleOrNull();

    return row?.read<String>('id');
  }
```

In `watchProductModeItems` (around line 183), update the SQL query to include `default_product_item_id`:
```sql
      SELECT 
        p.*,
        (SELECT id FROM product_items WHERE product_id = p.id AND (variant_combination IS NULL OR variant_combination = '') LIMIT 1) as default_product_item_id,
        COALESCE((SELECT SUM(stock) FROM inventories WHERE product_id = p.id), 0.0) as total_stock,
...
```
And populate `productItemId`:
```dart
final defaultProductItemId = row.read<String?>('default_product_item_id');
...
productItemId: defaultProductItemId,
```

---

### Blueprint 2: Refactor `lib/features/pos/presentation/providers/variant_dialog_provider.dart`

```dart
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../data/pos_repository.dart';
import 'pos_provider.dart';

class VariantDialogState {
  final bool isLoading;
  final List<VariantGroup> variantGroups;
  final Map<String, List<VariantGroupOption>> variantOptions;
  final List<ModifierGroup> modifierGroups;
  final Map<String, List<ModifierOption>> modifierOptions;

  // Selected state
  final Map<String, String> selectedVariants; // variantGroupId -> optionId
  final Map<String, List<String>> selectedModifiers; // modifierGroupId -> list of optionId
  final double variantPrice; // specific price for selected variant combination

  // Resolution state
  final String? resolvedProductItemId;
  final PosItem? resolvedPosItem;
  final bool isCombinationAvailable;
  final String? errorMessage;

  final int qty;
  final String? discountType;
  final double? discountValue;

  VariantDialogState({
    this.isLoading = true,
    this.variantGroups = const [],
    this.variantOptions = const {},
    this.modifierGroups = const [],
    this.modifierOptions = const {},
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
    this.variantPrice = 0.0,
    this.resolvedProductItemId,
    this.resolvedPosItem,
    this.isCombinationAvailable = true,
    this.errorMessage,
    this.qty = 1,
    this.discountType,
    this.discountValue,
  });

  bool get hasRequiredModifiersSelected {
    for (final group in modifierGroups) {
      if (group.minSelected > 0) {
        final count = (selectedModifiers[group.id] ?? []).length;
        if (count < group.minSelected) {
          return false;
        }
      }
    }
    return true;
  }

  bool get canAddToCart {
    if (isLoading) return false;
    if (variantGroups.isNotEmpty &&
        (resolvedProductItemId == null || !isCombinationAvailable)) {
      return false;
    }
    if (!hasRequiredModifiersSelected) {
      return false;
    }
    return true;
  }

  VariantDialogState copyWith({
    bool? isLoading,
    List<VariantGroup>? variantGroups,
    Map<String, List<VariantGroupOption>>? variantOptions,
    List<ModifierGroup>? modifierGroups,
    Map<String, List<ModifierOption>>? modifierOptions,
    Map<String, String>? selectedVariants,
    Map<String, List<String>>? selectedModifiers,
    double? variantPrice,
    String? resolvedProductItemId,
    PosItem? resolvedPosItem,
    bool? isCombinationAvailable,
    String? errorMessage,
    int? qty,
    String? discountType,
    double? discountValue,
    bool clearResolvedItem = false,
  }) {
    return VariantDialogState(
      isLoading: isLoading ?? this.isLoading,
      variantGroups: variantGroups ?? this.variantGroups,
      variantOptions: variantOptions ?? this.variantOptions,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      modifierOptions: modifierOptions ?? this.modifierOptions,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      variantPrice: variantPrice ?? this.variantPrice,
      resolvedProductItemId: clearResolvedItem
          ? null
          : (resolvedProductItemId ?? this.resolvedProductItemId),
      resolvedPosItem: clearResolvedItem
          ? null
          : (resolvedPosItem ?? this.resolvedPosItem),
      isCombinationAvailable:
          isCombinationAvailable ?? this.isCombinationAvailable,
      errorMessage: clearResolvedItem ? errorMessage : (errorMessage ?? this.errorMessage),
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }
}

class VariantDialogNotifier extends Notifier<VariantDialogState> {
  final PosItem _posItem;

  VariantDialogNotifier(this._posItem);

  @override
  VariantDialogState build() {
    _init();
    return VariantDialogState();
  }

  Future<void> _init() async {
    final db = ref.watch(databaseProvider);
    final posRepo = ref.watch(posRepositoryProvider);
    final productId = _posItem.isProductMode
        ? _posItem.id
        : (_posItem.product?.id ?? _posItem.inventory?.productId ?? _posItem.id);

    // 1. Fetch variant groups if in product mode
    List<VariantGroup> vGroups = [];
    Map<String, List<VariantGroupOption>> vOptions = {};
    Map<String, String> initialSelectedVariants = {};

    if (_posItem.isProductMode) {
      vGroups = await (db.select(
        db.variantGroups,
      )..where((tbl) => tbl.productId.equals(productId))).get();
      for (var group in vGroups) {
        final options = await (db.select(
          db.variantGroupOptions,
        )..where((tbl) => tbl.variantGroupId.equals(group.id))).get();
        vOptions[group.id] = options;
        if (options.isNotEmpty) {
          initialSelectedVariants[group.id] = options.first.id;
        }
      }
    }

    // 2. Fetch modifiers
    final pmg = await (db.select(
      db.productModifierGroups,
    )..where((tbl) => tbl.productId.equals(productId))).get();
    final mGroupIds = pmg.map((e) => e.modifierGroupId).toList();

    List<ModifierGroup> mGroups = [];
    Map<String, List<ModifierOption>> mOptions = {};
    Map<String, List<String>> initialSelectedModifiers = {};

    if (mGroupIds.isNotEmpty) {
      mGroups = await (db.select(
        db.modifierGroups,
      )..where((tbl) => tbl.id.isIn(mGroupIds))).get();
      for (var group in mGroups) {
        final options = await (db.select(
          db.modifierOptions,
        )..where((tbl) => tbl.modifierGroupId.equals(group.id))).get();
        mOptions[group.id] = options;
        initialSelectedModifiers[group.id] = [];
      }
    }

    // 3. Resolve initial product item & price
    String? initialProductItemId;
    PosItem? initialResolvedPosItem;
    double initialPrice = _posItem.price;
    bool isAvail = true;
    String? error;

    if (_posItem.isProductMode) {
      if (vGroups.isNotEmpty && initialSelectedVariants.isNotEmpty) {
        final optionIds = initialSelectedVariants.values.toList();
        initialProductItemId =
            await posRepo.findProductItemIdForVariants(productId, optionIds);
        if (initialProductItemId != null) {
          initialResolvedPosItem =
              await posRepo.getPosItemByProductItemId(initialProductItemId);
          if (initialResolvedPosItem != null) {
            initialPrice = initialResolvedPosItem.price;
            isAvail = initialResolvedPosItem.isActive;
          }
        } else {
          isAvail = false;
          error = 'Kombinasi varian ini tidak tersedia';
        }
      } else {
        // Single product in product mode
        initialProductItemId =
            await posRepo.findDefaultProductItemId(productId);
        if (initialProductItemId != null) {
          initialResolvedPosItem =
              await posRepo.getPosItemByProductItemId(initialProductItemId);
          if (initialResolvedPosItem != null) {
            initialPrice = initialResolvedPosItem.price;
            isAvail = initialResolvedPosItem.isActive;
          }
        }
      }
    } else {
      // Variant mode: already a variant SKU
      initialProductItemId = _posItem.productItemId ?? _posItem.id;
      initialResolvedPosItem = _posItem;
      initialPrice = _posItem.price;
      isAvail = _posItem.isActive;
    }

    state = state.copyWith(
      isLoading: false,
      variantGroups: vGroups,
      variantOptions: vOptions,
      modifierGroups: mGroups,
      modifierOptions: mOptions,
      selectedVariants: initialSelectedVariants,
      selectedModifiers: initialSelectedModifiers,
      resolvedProductItemId: initialProductItemId,
      resolvedPosItem: initialResolvedPosItem,
      variantPrice: initialPrice,
      isCombinationAvailable: isAvail,
      errorMessage: error,
    );
  }

  Future<void> selectVariant(String groupId, String optionId) async {
    final updated = Map<String, String>.from(state.selectedVariants);
    updated[groupId] = optionId;
    state = state.copyWith(selectedVariants: updated);
    await _updateVariantResolution(updated);
  }

  Future<void> _updateVariantResolution(
    Map<String, String> currentVariants,
  ) async {
    if (currentVariants.isEmpty) return;

    final posRepo = ref.read(posRepositoryProvider);
    final productId = _posItem.isProductMode
        ? _posItem.id
        : (_posItem.product?.id ?? _posItem.inventory?.productId ?? _posItem.id);

    final optionIds = currentVariants.values.toList();
    final pItemId =
        await posRepo.findProductItemIdForVariants(productId, optionIds);

    if (pItemId != null) {
      final resolvedPosItem = await posRepo.getPosItemByProductItemId(pItemId);
      if (resolvedPosItem != null) {
        state = state.copyWith(
          resolvedProductItemId: pItemId,
          resolvedPosItem: resolvedPosItem,
          variantPrice: resolvedPosItem.price,
          isCombinationAvailable: resolvedPosItem.isActive,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          resolvedProductItemId: pItemId,
          clearResolvedItem: true,
          isCombinationAvailable: false,
          errorMessage: 'Item varian sedang dinonaktifkan',
        );
      }
    } else {
      state = state.copyWith(
        clearResolvedItem: true,
        variantPrice: 0.0,
        isCombinationAvailable: false,
        errorMessage: 'Kombinasi varian ini tidak tersedia',
      );
    }
  }

  void toggleModifier(String groupId, String optionId, bool isSelected) {
    final group = state.modifierGroups.firstWhere((g) => g.id == groupId);
    final updatedList = List<String>.from(
      state.selectedModifiers[groupId] ?? [],
    );

    if (isSelected) {
      if (group.type == 'radio' || group.maxSelected == 1) {
        updatedList.clear();
        updatedList.add(optionId);
      } else {
        if (group.maxSelected == 0 || updatedList.length < group.maxSelected) {
          updatedList.add(optionId);
        }
      }
    } else {
      updatedList.remove(optionId);
    }

    final updated = Map<String, List<String>>.from(state.selectedModifiers);
    updated[groupId] = updatedList;
    state = state.copyWith(selectedModifiers: updated);
  }

  void setQty(int qty) {
    if (qty > 0) {
      state = state.copyWith(qty: qty);
    }
  }

  void setDiscount(String? type, double? value) {
    state = state.copyWith(discountType: type, discountValue: value);
  }

  double calculateTotalPrice() {
    double total = state.variantPrice;

    for (var groupId in state.selectedModifiers.keys) {
      final selectedOpts = state.selectedModifiers[groupId]!;
      final opts = state.modifierOptions[groupId] ?? [];
      for (var optId in selectedOpts) {
        final opt = opts.firstWhereOrNull((o) => o.id == optId);
        if (opt != null) {
          total += opt.price;
        }
      }
    }

    return total;
  }
}

final variantDialogProvider = NotifierProvider.autoDispose
    .family<VariantDialogNotifier, VariantDialogState, PosItem>((posItem) {
      return VariantDialogNotifier(posItem);
    });
```

---

### Blueprint 3: Update `lib/features/pos/presentation/widgets/variant_dialog.dart`

Key enhancements:
1. Show stock badge with `Stok: ∞` when `track_inventory == false`:
   ```dart
   final resolvedItem = state.resolvedPosItem;
   final stockText = resolvedItem?.isService == true
       ? 'Layanan'
       : (resolvedItem?.trackInventory == false
           ? 'Stok: ∞'
           : (resolvedItem != null
               ? 'Stok: ${resolvedItem.stock.toInt()} ${resolvedItem.unit}'
               : ''));
   ```
2. Display error message banner if combination is invalid:
   ```dart
   if (state.errorMessage != null) ...[
     Container(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       decoration: BoxDecoration(
         color: SolluColors.danger.withValues(alpha: 0.1),
         borderRadius: BorderRadius.circular(8),
       ),
       child: Row(
         children: [
           const Icon(Icons.error_outline, color: SolluColors.danger, size: 18),
           const SizedBox(width: 8),
           Expanded(
             child: Text(
               state.errorMessage!,
               style: const TextStyle(color: SolluColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
             ),
           ),
         ],
       ),
     ),
     const SizedBox(height: 12),
   ]
   ```
3. "Tambah" button disabled when `!state.canAddToCart`:
   ```dart
   ElevatedButton(
     onPressed: state.canAddToCart
         ? () {
             final resolvedItem = state.resolvedPosItem;
             final cartItem = CartItem(
               id: DateTime.now().millisecondsSinceEpoch.toString(),
               productId: posItem.isProductMode
                   ? posItem.id
                   : (posItem.product?.id ?? posItem.inventory?.productId ?? posItem.id),
               productItemId: state.resolvedProductItemId,
               inventoryItemId: resolvedItem?.inventory?.id ?? '',
               trackInventory: resolvedItem?.trackInventory ?? posItem.trackInventory,
               variantGroupOptionId: state.selectedVariants.values.firstOrNull,
               variantCombination: resolvedItem?.variantCombination,
               name: resolvedItem?.name ?? posItem.name,
               price: totalPrice,
               qty: state.qty,
               discountType: state.discountType,
               discountValue: state.discountValue,
               selectedVariants: state.selectedVariants,
               selectedModifiers: state.selectedModifiers,
             );

             ref.read(cartProvider.notifier).addItem(cartItem);
             Navigator.of(context).pop();
           }
         : null,
     child: const Text('Tambah'),
   )
   ```

---

### Blueprint 4: Update `lib/features/pos/presentation/providers/cart_provider.dart`

```dart
class CartItem {
  final String id;
  final String productId;
  final String? productItemId; // Bound to ProductItem
  final String inventoryItemId;
  final String? variantGroupOptionId;
  final String? variantCombination;
  final bool trackInventory;
  final String name;
  final double price;
  final int qty;
  final String? discountType;
  final double? discountValue;
  final String? notes;

  // Storing this for reference/display
  final Map<String, String> selectedVariants;
  final Map<String, List<String>> selectedModifiers;

  CartItem({
    required this.id,
    required this.productId,
    this.productItemId,
    this.inventoryItemId = '',
    this.variantGroupOptionId,
    this.variantCombination,
    this.trackInventory = false,
    required this.name,
    required this.price,
    this.qty = 1,
    this.discountType,
    this.discountValue,
    this.notes,
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
  });

  double get calculatedDiscountAmount {
    if (discountValue == null || discountValue == 0) return 0.0;
    if (discountType == 'percentage') {
      final val = (price * discountValue!) / 100.0;
      return val > price ? price : val;
    } else if (discountType == 'fixed') {
      return discountValue! > price ? price : discountValue!;
    }
    return 0.0;
  }

  double get calculatedSubtotal {
    return (price - calculatedDiscountAmount) * qty;
  }

  CartItem copyWith({
    String? productItemId,
    bool? trackInventory,
    String? variantCombination,
    double? price,
    int? qty,
    String? discountType,
    double? discountValue,
    String? notes,
    String? variantGroupOptionId,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      productItemId: productItemId ?? this.productItemId,
      trackInventory: trackInventory ?? this.trackInventory,
      inventoryItemId: inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      variantCombination: variantCombination ?? this.variantCombination,
      name: name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      notes: notes ?? this.notes,
      selectedVariants: selectedVariants,
      selectedModifiers: selectedModifiers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_item_id': productItemId,
      'track_inventory': trackInventory,
      'inventory_item_id': inventoryItemId,
      'variant_group_option_id': variantGroupOptionId,
      'variant_combination': variantCombination,
      'name': name,
      'price': price,
      'qty': qty,
      'discount_type': discountType,
      'discount_value': discountValue,
      'notes': notes,
      'selected_variants': selectedVariants,
      'selected_modifiers': selectedModifiers,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productItemId: json['product_item_id'] as String?,
      trackInventory: json['track_inventory'] as bool? ?? false,
      inventoryItemId: json['inventory_item_id'] as String? ?? '',
      variantGroupOptionId: json['variant_group_option_id'] as String?,
      variantCombination: json['variant_combination'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      selectedVariants:
          (json['selected_variants'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v.toString()),
              ) ??
              const {},
      selectedModifiers:
          (json['selected_modifiers'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(
                  k,
                  (v as List).map((e) => e.toString()).toList(),
                ),
              ) ??
              const {},
    );
  }
}
```

In `CartNotifier.addItem`:
```dart
  void addItem(CartItem item) {
    // Check if an identical item exists (same product_item_id, or same inventory/product, and identical modifiers/variants)
    final existingIndex = state.indexWhere((element) {
      final sameItem = (element.productItemId != null && item.productItemId != null)
          ? (element.productItemId == item.productItemId)
          : (element.productId == item.productId && element.inventoryItemId == item.inventoryItemId);

      final sameVariants = const DeepCollectionEquality().equals(
        element.selectedVariants,
        item.selectedVariants,
      );
      final sameModifiers = const DeepCollectionEquality().equals(
        element.selectedModifiers,
        item.selectedModifiers,
      );
      return sameItem && sameVariants && sameModifiers;
    });

    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(
        qty: existingItem.qty + item.qty,
      );
      final newState = List<CartItem>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      state = [...state, item];
    }
  }
```

In `CartNotifier.updateItemDetails`:
Preserve `productItemId: item.productItemId`, `trackInventory: item.trackInventory`, `variantCombination: item.variantCombination`.

---

### Blueprint 5: Update `product_grid.dart` & `pos_layout.dart`

1. In `product_grid.dart` (`_onProductTap`):
   ```dart
   final displayMode = ref.read(posDisplayModeProvider);
   final isProductMode = displayMode == 'product';
   final hasVariantsOrModifiers = product.hasVariants || product.hasModifiers;

   final shouldOpenDialog = isProductMode
       ? hasVariantsOrModifiers
       : product.hasModifiers;

   if (shouldOpenDialog) {
     VariantDialog.show(context, product);
   } else {
     final cartItem = CartItem(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       productId: product.isProductMode
           ? product.id
           : (product.inventory?.productId ?? product.product?.id ?? product.id),
       productItemId: product.productItemId,
       inventoryItemId: product.isProductMode ? '' : (product.inventory?.id ?? product.id),
       trackInventory: product.trackInventory,
       variantCombination: product.variantCombination,
       name: product.name,
       price: product.price,
       qty: 1,
     );
     ref.read(cartProvider.notifier).addItem(cartItem);
     ...
   ```

2. In `_ProductCard` (`product_grid.dart`):
   Display stock indicator under price:
   ```dart
   Text(
     posItem.isService
         ? 'Layanan'
         : (!posItem.trackInventory
             ? 'Stok: ∞'
             : 'Stok: ${posItem.stock.toInt()} ${posItem.unit}'),
     style: const TextStyle(
       color: SolluColors.textMuted,
       fontSize: 11,
     ),
   ),
   ```

3. In `products_screen.dart` (lines 662 and 843):
   ```dart
   isService ? 'Produk Layanan' : (!item.trackInventory ? 'Stok: ∞' : 'Stok: ${_formatStock(stock)} ${item.unit}'),
   ```
   and
   ```dart
   isService ? 'Layanan' : (!item.trackInventory ? 'Stok: ∞' : 'Stok: ${_formatStock(item.stock)} ${item.unit}'),
   ```

4. In `pos_layout.dart` (barcode scanning and enter-query item creation):
   Populate `productItemId: matchedItem.productItemId ?? matchedItem.id`, `trackInventory: matchedItem.trackInventory`, `variantCombination: matchedItem.variantCombination`.

---

### Blueprint 6: Update `TransactionRepository` (`transaction_repository.dart`)

1. In `createTransaction` (lines 272-288):
   ```dart
   final resolvedProductItemId = cartItem.productItemId ??
       (cartItem.selectedVariants.isNotEmpty
           ? await _posRepo.findProductItemIdForVariants(
               resolvedProductId!,
               cartItem.selectedVariants.values.toList(),
             )
           : await _posRepo.findDefaultProductItemId(resolvedProductId!));

   await _database.into(_database.transactionItems).insert(
     TransactionItemsCompanion.insert(
       id: itemId,
       transactionId: txId,
       productId: Value(resolvedProductId),
       productItemId: Value(resolvedProductItemId), // <--- Recorded!
       inventoryItemId: Value(resolvedInventoryItemId),
       variantGroupOptionId: Value(resolvedVariantGroupOptionId),
       productName: cartItem.name,
       price: cartItem.price,
       qty: cartItem.qty.toDouble(),
       ...
     ),
   );
   ```
2. In stock deduction (lines 309-322):
   Only deduct stock if `cartItem.trackInventory` is `true`.
3. In `_syncTransactionOnline` (lines 792-805):
   Include `'product_item_id': item.productItemId` in `itemsPayload`.

---

### Blueprint 7: Unit & Widget Test Suite for R5

Create `test/features/pos/presentation/variant_dialog_test.dart` to verify:
1. Multi-attribute resolution: Selecting Size (Reg/Lrg) and Ice (Hot/Ice) updates `resolvedProductItemId` and `variantPrice`.
2. Non-existent combination: Selecting an unregistered pair (e.g. Lrg + Hot) sets `resolvedProductItemId = null`, `isCombinationAvailable = false`, and disables `canAddToCart`.
3. Modifiers: Toggling checkbox and radio modifiers adds/removes to `selectedModifiers`, and `calculateTotalPrice()` correctly sums variant base + modifier prices.
4. Mandatory modifier enforcement: If `minSelected > 0`, `canAddToCart` is false until selected.
5. CartItem & Decoupled Stock: Adding non-inventory item (`trackInventory = false`) sets `cartItem.trackInventory = false`, which is skipped by `checkCartStockAvailability` (never triggers `InsufficientStockDialog`).

---

## 4. Caveats

1. **Category Filter in Dialog:**
   The variant dialog is item-specific and does not interact with the category filter bar.
2. **Offline-First Drift SQLite:**
   All queries (`product_item_variant_group_options`, `product_items`, `variant_groups`, `modifier_groups`) execute locally against SQLite without requiring network roundtrips.
3. **Hardware Barcode Scans:**
   Barcode scanning directly resolves variant items via `findItemByBarcodeOrSku` (which queries `product_items.barcode` and `product_items.sku`), directly setting `cartItem.productItemId`. The variant dialog is only opened when tapping a parent product card in Product Mode or when modifiers need to be selected.

---

## 5. Conclusion

The multi-attribute resolution architecture is cleanly supported by the normalized SQLite schema (`product_items` and `product_item_variant_group_options`) implemented in R4. The existing `VariantDialogNotifier` failed because it used obsolete `inventories` queries and `firstOrNull` 1D selection.

With the blueprints provided above:
1. `VariantDialogNotifier` seamlessly resolves multi-attribute combinations through `posRepo.findProductItemIdForVariants(productId, optionIds)`.
2. `CartItem` and `CartProvider` are strictly bound to `product_item_id`.
3. Products with `track_inventory = false` display `∞` across the UI and pass through checkout without stock blocks.
4. Backward compatibility with held transactions and existing test suites is 100% maintained.

---

## 6. Verification Method

To verify the implementation once executed by Worker R5:
1. Run Drift / Dart analyzer:
   ```bash
   /Users/whykrr/flutter/bin/flutter analyze
   ```
   *Expected:* Zero issues.
2. Run automated test suite:
   ```bash
   /Users/whykrr/flutter/bin/flutter test test/features/pos/presentation/variant_dialog_test.dart
   /Users/whykrr/flutter/bin/flutter test test/features/pos/presentation/cart_held_transaction_test.dart
   /Users/whykrr/flutter/bin/flutter test test/features/pos/data/pos_repository_unified_items_test.dart
   ```
   *Expected:* All tests pass.
3. Full test suite run:
   ```bash
   /Users/whykrr/flutter/bin/flutter test
   ```
   *Expected:* All tests pass cleanly.
