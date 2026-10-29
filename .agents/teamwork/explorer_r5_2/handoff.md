# Milestone R5 Investigation Report & Handoff: Cart Domain, State, and Transaction Persistence

**Agent:** Explorer 2 for Milestone R5 (`explorer_r5_2`)  
**Target Workspace:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`  
**Milestone:** R5 — Flutter POS Variant Dialog & Cart Integration  
**Date:** 2026-10-22  

---

## 1. Observation

### 1.1 Cart Domain Entity & File Organization
- `lib/features/cart/domain/cart_item.dart` does **not** currently exist on the filesystem (`stat: no such file or directory`).
- `CartItem` is defined directly inside `lib/features/pos/presentation/providers/cart_provider.dart` (lines 4–119).
- `CartItem` currently has the following fields (`lib/features/pos/presentation/providers/cart_provider.dart` lines 4–19):
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

    // Storing this for reference/display
    final Map<String, String> selectedVariants;
    final Map<String, List<String>> selectedModifiers;
  ```
- **Missing fields on `CartItem`**:
  - `productItemId` (Unified Item Pattern identifier for the specific variant/single item).
  - `variantCombination` (e.g., `"Large - Ice"`).
  - `trackInventory` (boolean flag to indicate if stock tracking and decrements apply).
- `inventoryItemId` is currently declared non-nullable without default (`required this.inventoryItemId`), which forces callers to pass dummy empty strings (`''`) when dealing with decoupled products that do not track inventory (e.g. `product_grid.dart:110`, `variant_dialog.dart:244`, `pos_layout.dart:147`).

### 1.2 Cart Deduplication Logic in `CartNotifier.addItem`
- In `lib/features/pos/presentation/providers/cart_provider.dart` (lines 125–140):
  ```dart
  void addItem(CartItem item) {
    // Check if an identical item exists (same inventory/product and same modifiers/variants)
    final existingIndex = state.indexWhere((element) {
      final sameInventory =
          element.inventoryItemId == item.inventoryItemId &&
          element.productId == item.productId;
      final sameVariants = const DeepCollectionEquality().equals(
        element.selectedVariants,
        item.selectedVariants,
      );
      final sameModifiers = const DeepCollectionEquality().equals(
        element.selectedModifiers,
        item.selectedModifiers,
      );
      return sameInventory && sameVariants && sameModifiers;
    });
  ```
- **Defects identified**:
  1. Deduplication does not check `productItemId`. If two different variants of a product have empty `inventoryItemId` (`''`), they only check `selectedVariants`.
  2. For items added via barcode scanner (`findItemByBarcodeOrSku`) or text search, `selectedVariants` map is empty, while `productItemId` uniquely differentiates the item.
  3. `const DeepCollectionEquality().equals(...)` on modifier lists is order-sensitive. If modifiers are added in different orders (`['A', 'B']` vs `['B', 'A']`), deduplication fails and duplicates the row.

### 1.3 Cart Stock Availability Check & `trackInventory` Bypass
- In `lib/features/pos/data/pos_repository.dart` (lines 679–684):
  ```dart
  for (final item in items) {
    // Lewati pengecekan stok jika item tidak melacak stok (trackInventory = false)
    try {
      if (item.trackInventory == false) {
        continue;
      }
    } catch (_) {}
  ```
- In Dart, because `CartItem` did not have a `trackInventory` property, any typed `CartItem` or invocation would trigger the `catch (_) {}` block, preventing actual bypass from working based on `CartItem` state.
- In `lib/features/pos/data/pos_repository.dart` (lines 703–713):
  ```dart
  if (resolvedInvId == null) {
    try {
      if (item.productItemId != null &&
          item.productItemId.toString().isNotEmpty) {
        final inv = await (_database.select(_database.inventories)
              ..where(
                (i) => i.productItemId.equals(item.productItemId.toString()),
              ))
            .getSingleOrNull();
        resolvedInvId = inv?.id;
      }
    } catch (_) {}
  }
  ```
  The repository already had defensive code expecting `item.productItemId`, but `CartItem` was missing that field.

### 1.4 Stock Decrement in `TransactionRepository.createTransaction`
- In `lib/features/pos/data/transaction_repository.dart` (lines 309–322):
  ```dart
  // Potong stok dari database lokal jika produk melacak stok
  if (resolvedInventoryItemId != null) {
    final inventory =
        await (_database.select(_database.inventories)
              ..where((i) => i.id.equals(resolvedInventoryItemId!)))
              .getSingleOrNull();

    if (inventory != null && inventory.trackInventory) {
      final newStock = inventory.stock - cartItem.qty;
      await (_database.update(_database.inventories)
            ..where((i) => i.id.equals(resolvedInventoryItemId!)))
          .write(InventoriesCompanion(stock: Value(newStock)));
    }
  }
  ```
- **Defects identified**:
  - The check solely relies on `resolvedInventoryItemId != null && inventory.trackInventory`.
  - It does not check `cartItem.trackInventory`. If `cartItem.trackInventory == false`, stock deduction should be bypassed immediately without attempting to resolve or deduct inventory stock.

### 1.5 SQLite Table `TransactionItems` vs Repository Persistence
- In `lib/core/database/tables/transaction_tables.dart` (lines 89–95):
  ```dart
  @DataClassName('TransactionItem')
  class TransactionItems extends Table {
    TextColumn get id => text()(); // UUID
    TextColumn get transactionId => text().references(Transactions, #id)();
    TextColumn get productId => text().nullable()();
    TextColumn get productItemId => text().nullable()();
    TextColumn get inventoryItemId => text().nullable()();
    TextColumn get variantGroupOptionId => text().nullable()();
    TextColumn get productName => text()(); // Denormalized
  ```
- In `lib/core/database/app_database.g.dart`:
  - `TransactionItem` constructor (line 8223) includes `this.productItemId`.
  - `TransactionItemsCompanion.insert` includes `Value<String?> productItemId = const Value.absent()`.
- In `lib/features/pos/data/transaction_repository.dart` (lines 269–288):
  ```dart
  await _database
      .into(_database.transactionItems)
      .insert(
        TransactionItemsCompanion.insert(
          id: itemId,
          transactionId: txId,
          productId: Value(resolvedProductId),
          inventoryItemId: Value(resolvedInventoryItemId),
          variantGroupOptionId: Value(resolvedVariantGroupOptionId),
          productName: cartItem.name,
          price: cartItem.price,
          qty: cartItem.qty.toDouble(),
          discountType: Value(itemDiscountType),
          discountValue: Value(itemDiscountValue),
          discountAmount: Value(itemDiscountAmount),
          subtotal: itemSubtotal,
          notes: Value(cartItem.notes),
          createdAt: Value(now),
        ),
      );
  ```
- **CRITICAL DEFECT**: `productItemId` is **NOT passed** into `TransactionItemsCompanion.insert`!
  As a result, `transaction_items.product_item_id` in SQLite is **permanently written as NULL** for all sales transactions!
- Additionally, lines 291–306:
  ```dart
  createdItems.add(
    TransactionItem(
      id: itemId,
      transactionId: txId,
      productId: resolvedProductId,
      // productItemId is missing here!
      inventoryItemId: resolvedInventoryItemId,
  ```
  The returned in-memory `TransactionItem` object also leaves `productItemId` null.
- Additionally, lines 792–805 and 885–898:
  The online sync `itemsPayload` omits `'product_item_id'`, which means backend synchronization does not receive `product_item_id`.

### 1.6 Variant Dialog Notifier Query Asymmetry
- In `lib/features/pos/presentation/providers/variant_dialog_provider.dart` (lines 144–180):
  ```dart
  Future<void> _updateVariantPrice(Map<String, String> currentVariants) async {
    if (currentVariants.isEmpty) return;
    ...
    final variantOptionId = currentVariants.values.firstOrNull;

    if (variantOptionId != null) {
      final row = await db
          .customSelect(
            '''
        SELECT COALESCE(
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = ? AND inventory_item_id IS NULL LIMIT 1),
          (SELECT price FROM products WHERE id = ?),
          0.0
        ) as price
        FROM inventories i
        INNER JOIN inventory_item_variant_group_options piv ON piv.inventory_item_id = i.id
        WHERE i.product_id = ? AND piv.variant_group_option_id = ?
        LIMIT 1
        ''',
  ```
- **Defects identified**:
  1. It uses `currentVariants.values.firstOrNull`, completely ignoring multi-group variants (e.g. Size + Sugar Level).
  2. It queries `inventory_item_variant_group_options` (the old dropped table) instead of `product_item_variant_group_options` (normalized in R1 & R4).
  3. It requires an `inventories` row, which breaks for decoupled products where `track_inventory == false`.
  4. It does not resolve `product_item_id`, `variant_combination`, or `track_inventory`.

---

## 2. Logic Chain

1. **Clean Architecture Separation:**
   - Per `AGENTS.md` and Clean Architecture rules (`02-clean-architecture.md`), domain models belong in `domain/` directories.
   - Creating `lib/features/cart/domain/cart_item.dart` creates a dedicated entity.
   - Re-exporting `CartItem` in `lib/features/pos/presentation/providers/cart_provider.dart` ensures 100% backward compatibility for all existing imports across 12+ files without breaking existing code.

2. **Unified Item Representation in Cart:**
   - In the Unified Item Pattern, every sellable product unit is represented by a `ProductItem`.
   - By adding `productItemId`, `variantCombination`, and `trackInventory` to `CartItem`, the cart line item carries complete catalog context.
   - Making `inventoryItemId` optional (default `''`) avoids synthetic IDs for non-inventory products.
   - Serializing these new fields in `toJson()` and deserializing in `fromJson()` ensures `HeldTransactions` (Hold & Resume cart) and local persistence remain completely lossless.

3. **Deterministic Deduplication:**
   - If two cart additions share the exact same `productItemId` (or fallback to `productId` + `selectedVariants`), and identical modifier choices, they are physically and commercially the same item.
   - Using `DeepCollectionEquality.unordered()` on modifier lists prevents duplicate rows caused solely by difference in option selection order.
   - Incrementing `qty` on identical items keeps the cart compact and user-friendly.

4. **Decoupled Stock & Zero-Blocking Checkout:**
   - If `cartItem.trackInventory == false`, the product is a service or non-tracked good.
   - Skipping `checkCartStockAvailability` when `item.trackInventory == false` allows cashier checkout to proceed unhindered, even if local inventory balance is 0 or non-existent.
   - In `TransactionRepository.createTransaction`, skipping stock deduction when `!cartItem.trackInventory` prevents database errors and maintains inventory integrity.

5. **Relational Integrity in SQLite Sales Transactions:**
   - `TransactionItems.productItemId` is the foreign key connecting sales to `product_items`.
   - Explicitly passing `productItemId: Value(resolvedProductItemId)` into `TransactionItemsCompanion.insert` guarantees that POS sales records accurately store which product item SKU was sold.
   - Including `product_item_id` in sync payloads ensures backend inventory and revenue attribution match Shopify/Square standards.

---

## 3. Caveats

- **Existing Tests:** Several existing unit tests (`test/widget_test.dart`, `test/features/pos/presentation/cart_held_transaction_test.dart`, `test/features/pos/data/transaction_fifo_queue_test.dart`) instantiate `CartItem` without specifying `productItemId`, `variantCombination`, or `trackInventory`. The constructor parameters MUST be optional with safe defaults so those existing tests continue to compile and pass without modification.
- **Legacy Fallback:** If a cart item is created without a `productItemId` (e.g. from an old held cart or mock), `TransactionRepository` must include a fallback lookup to resolve the default `product_items` row for `resolvedProductId`.
- **UI Infinity Symbol (`∞`):** Both `products_screen.dart` and `product_grid.dart` should visually display `∞` when `trackInventory == false`.

---

## 4. Conclusion & Actionable Blueprints for Worker R5

### Blueprint 1: `lib/features/cart/domain/cart_item.dart`
Create new file with the following complete implementation:
```dart
import 'package:collection/collection.dart';

class CartItem {
  final String id;
  final String productId;
  final String? productItemId;
  final String inventoryItemId;
  final String? variantGroupOptionId;
  final String name;
  final String? variantCombination;
  final bool trackInventory;
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
    required this.name,
    this.variantCombination,
    this.trackInventory = true,
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
    String? inventoryItemId,
    String? variantGroupOptionId,
    String? name,
    String? variantCombination,
    bool? trackInventory,
    double? price,
    int? qty,
    String? discountType,
    double? discountValue,
    String? notes,
    Map<String, String>? selectedVariants,
    Map<String, List<String>>? selectedModifiers,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      productItemId: productItemId ?? this.productItemId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      name: name ?? this.name,
      variantCombination: variantCombination ?? this.variantCombination,
      trackInventory: trackInventory ?? this.trackInventory,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      notes: notes ?? this.notes,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_item_id': productItemId,
      'inventory_item_id': inventoryItemId,
      'variant_group_option_id': variantGroupOptionId,
      'name': name,
      'variant_combination': variantCombination,
      'track_inventory': trackInventory,
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
      inventoryItemId: (json['inventory_item_id'] as String?) ?? '',
      variantGroupOptionId: json['variant_group_option_id'] as String?,
      name: json['name'] as String,
      variantCombination: json['variant_combination'] as String?,
      trackInventory: json['track_inventory'] as bool? ?? true,
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

### Blueprint 2: `lib/features/pos/presentation/providers/cart_provider.dart`
Export `CartItem` and update `CartNotifier.addItem`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../cart/domain/cart_item.dart';

export '../../../cart/domain/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    // Check if an identical item exists (same product_item_id/product and matching modifiers)
    final existingIndex = state.indexWhere((element) {
      final bool sameProductItem;
      if (element.productItemId != null &&
          element.productItemId!.isNotEmpty &&
          item.productItemId != null &&
          item.productItemId!.isNotEmpty) {
        sameProductItem = element.productItemId == item.productItemId;
      } else {
        final sameInventory =
            element.inventoryItemId == item.inventoryItemId &&
            element.productId == item.productId;
        final sameVariants = const DeepCollectionEquality().equals(
          element.selectedVariants,
          item.selectedVariants,
        );
        sameProductItem = sameInventory && sameVariants;
      }

      final sameModifiers = const DeepCollectionEquality.unordered().equals(
        element.selectedModifiers,
        item.selectedModifiers,
      );

      return sameProductItem && sameModifiers;
    });

    if (existingIndex != -1) {
      // Increase qty of existing item
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(
        qty: existingItem.qty + item.qty,
      );

      final newState = List<CartItem>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new item
      state = [...state, item];
    }
  }
  ...
```

### Blueprint 3: `lib/features/pos/presentation/providers/variant_dialog_provider.dart`
Refactor state and price/item resolution using `findProductItemIdForVariants`:
```dart
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
  final String? resolvedProductItemId;
  final String? resolvedVariantCombination;
  final bool trackInventory;
  final double stock;

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
    this.resolvedVariantCombination,
    this.trackInventory = true,
    this.stock = 0.0,
    this.qty = 1,
    this.discountType,
    this.discountValue,
  });

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
    String? resolvedVariantCombination,
    bool? trackInventory,
    double? stock,
    int? qty,
    String? discountType,
    double? discountValue,
  }) { ... }
}
```
And inside `VariantDialogNotifier`:
```dart
  Future<void> _resolveVariant(Map<String, String> currentVariants) async {
    final db = ref.read(databaseProvider);
    final posRepo = ref.read(posRepositoryProvider);
    final productId = _posItem.isProductMode
        ? _posItem.id
        : _posItem.inventory!.productId;

    final optionIds = currentVariants.values.toList();
    if (optionIds.isEmpty) {
      state = state.copyWith(
        variantPrice: _posItem.price,
        resolvedProductItemId: _posItem.productItemId,
        resolvedVariantCombination: _posItem.variantCombination,
        trackInventory: _posItem.trackInventory,
      );
      return;
    }

    final productItemId = await posRepo.findProductItemIdForVariants(productId, optionIds);

    double resolvedPrice = _posItem.price;
    String? combination;
    bool trackInv = _posItem.trackInventory;
    double currentStock = 0.0;

    if (productItemId != null) {
      final productItem = await (db.select(db.productItems)
        ..where((tbl) => tbl.id.equals(productItemId)))
        .getSingleOrNull();

      if (productItem != null) {
        combination = productItem.variantCombination;
        trackInv = productItem.trackInventory;
      }

      final priceRow = await db.customSelect(
        '''
        SELECT COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = ? LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = ? AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT price FROM products WHERE id = ?),
          0.0
        ) as price
        ''',
        variables: [
          Variable.withString(productItemId),
          Variable.withString(productId),
          Variable.withString(productId),
        ],
      ).getSingleOrNull();

      if (priceRow != null) {
        resolvedPrice = priceRow.read<double>('price');
      }

      if (trackInv) {
        final inv = await (db.select(db.inventories)
          ..where((i) => i.productItemId.equals(productItemId)))
          .getSingleOrNull();
        currentStock = inv?.stock ?? 0.0;
      } else {
        currentStock = double.infinity;
      }
    }

    state = state.copyWith(
      variantPrice: resolvedPrice,
      resolvedProductItemId: productItemId,
      resolvedVariantCombination: combination,
      trackInventory: trackInv,
      stock: currentStock,
    );
  }
```

### Blueprint 4: `lib/features/pos/presentation/widgets/variant_dialog.dart`
In "Tambah" button callback (lines 235–259):
```dart
  ElevatedButton(
    onPressed: () {
      final selectedVariantOptionId =
          state.selectedVariants.values.firstOrNull;

      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: posItem.isProductMode
            ? posItem.id
            : (posItem.inventory?.productId ?? posItem.product?.id ?? posItem.id),
        productItemId: state.resolvedProductItemId,
        inventoryItemId: posItem.isProductMode ? '' : posItem.id,
        variantGroupOptionId: selectedVariantOptionId,
        name: posItem.name,
        variantCombination: state.resolvedVariantCombination,
        trackInventory: state.trackInventory,
        price: totalPrice,
        qty: state.qty,
        discountType: state.discountType,
        discountValue: state.discountValue,
        selectedVariants: state.selectedVariants,
        selectedModifiers: state.selectedModifiers,
      );

      ref.read(cartProvider.notifier).addItem(cartItem);
      Navigator.of(context).pop();
    },
    child: const Text('Tambah'),
  ),
```

### Blueprint 5: `lib/features/pos/presentation/widgets/product_grid.dart` & `pos_layout.dart`
- In `product_grid.dart` (lines 105–115):
  ```dart
  final cartItem = CartItem(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    productId: product.isProductMode
        ? product.id
        : (product.inventory?.productId ?? product.product?.id ?? product.id),
    productItemId: product.productItemId,
    inventoryItemId: product.isProductMode ? '' : product.id,
    name: product.name,
    variantCombination: product.variantCombination,
    trackInventory: product.trackInventory,
    price: product.price,
    qty: 1,
  );
  ```
- In `product_grid.dart` `ProductCard` (lines 280–290):
  If `!posItem.trackInventory`, display infinity icon (`∞`) badge (e.g. `Container` with `Text('∞', style: TextStyle(...))`).
- In `pos_layout.dart` (lines 142 & 766):
  Pass `productItemId: matchedItem.productItemId`, `variantCombination: matchedItem.variantCombination`, `trackInventory: matchedItem.trackInventory`.

### Blueprint 6: `lib/features/pos/data/transaction_repository.dart`
In `createTransaction` (lines 185–322):
```dart
  for (final cartItem in items) {
    final itemId = _uuid.v4();

    String? resolvedProductId = cartItem.productId.isNotEmpty
        ? cartItem.productId
        : null;
    String? resolvedProductItemId = (cartItem.productItemId != null && cartItem.productItemId!.isNotEmpty)
        ? cartItem.productItemId
        : null;
    String? resolvedInventoryItemId = cartItem.inventoryItemId.isNotEmpty
        ? cartItem.inventoryItemId
        : null;
    String? resolvedVariantGroupOptionId = cartItem.variantGroupOptionId;

    if (resolvedVariantGroupOptionId == null &&
        cartItem.selectedVariants.isNotEmpty) {
      resolvedVariantGroupOptionId =
          cartItem.selectedVariants.values.firstOrNull;
    }

    // Fallback: Resolve productItemId if not provided on cart item
    if (resolvedProductItemId == null && resolvedProductId != null) {
      final variantOptionIds = cartItem.selectedVariants.values.toList();
      if (resolvedVariantGroupOptionId != null && !variantOptionIds.contains(resolvedVariantGroupOptionId)) {
        variantOptionIds.add(resolvedVariantGroupOptionId);
      }
      if (variantOptionIds.isNotEmpty) {
        final inClause = List.filled(variantOptionIds.length, '?').join(',');
        final row = await _database.customSelect(
          '''
          SELECT piv.product_item_id
          FROM product_item_variant_group_options piv
          INNER JOIN product_items pi ON pi.id = piv.product_item_id
          WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
          GROUP BY piv.product_item_id
          HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
            AND (SELECT COUNT(*) FROM product_item_variant_group_options WHERE product_item_id = piv.product_item_id) = ?
          LIMIT 1
          ''',
          variables: [
            Variable.withString(resolvedProductId),
            ...variantOptionIds.map((id) => Variable.withString(id)),
            Variable.withInt(variantOptionIds.length),
            Variable.withInt(variantOptionIds.length),
          ],
        ).getSingleOrNull();
        resolvedProductItemId = row?.read<String>('product_item_id');
      }

      // Default item for single product
      if (resolvedProductItemId == null) {
        final pi = await (_database.select(_database.productItems)
          ..where((p) => p.productId.equals(resolvedProductId))
          ..limit(1))
          .getSingleOrNull();
        resolvedProductItemId = pi?.id;
      }
    }

    // Resolve inventoryItemId via productItemId if tracked
    if (resolvedInventoryItemId == null && resolvedProductItemId != null && cartItem.trackInventory) {
      final inv = await (_database.select(_database.inventories)
        ..where((i) => i.productItemId.equals(resolvedProductItemId!))
        ..limit(1))
        .getSingleOrNull();
      resolvedInventoryItemId = inv?.id;
    }

    // Compute item discount
    ...
    await _database
        .into(_database.transactionItems)
        .insert(
          TransactionItemsCompanion.insert(
            id: itemId,
            transactionId: txId,
            productId: Value(resolvedProductId),
            productItemId: Value(resolvedProductItemId), // <-- CRITICAL FIX: Persist product_item_id
            inventoryItemId: Value(resolvedInventoryItemId),
            variantGroupOptionId: Value(resolvedVariantGroupOptionId),
            productName: cartItem.name,
            price: cartItem.price,
            qty: cartItem.qty.toDouble(),
            discountType: Value(itemDiscountType),
            discountValue: Value(itemDiscountValue),
            discountAmount: Value(itemDiscountAmount),
            subtotal: itemSubtotal,
            notes: Value(cartItem.notes),
            createdAt: Value(now),
          ),
        );

    createdItems.add(
      TransactionItem(
        id: itemId,
        transactionId: txId,
        productId: resolvedProductId,
        productItemId: resolvedProductItemId, // <-- CRITICAL FIX
        inventoryItemId: resolvedInventoryItemId,
        variantGroupOptionId: resolvedVariantGroupOptionId,
        productName: cartItem.name,
        price: cartItem.price,
        qty: cartItem.qty.toDouble(),
        discountType: itemDiscountType,
        discountValue: itemDiscountValue,
        discountAmount: itemDiscountAmount,
        subtotal: itemSubtotal,
        notes: cartItem.notes,
        createdAt: now,
      ),
    );

    // Potong stok HANYA jika item melacak stok (trackInventory == true)
    if (cartItem.trackInventory && resolvedInventoryItemId != null) {
      final inventory =
          await (_database.select(_database.inventories)
                ..where((i) => i.id.equals(resolvedInventoryItemId!)))
                .getSingleOrNull();

      if (inventory != null && inventory.trackInventory) {
        final newStock = inventory.stock - cartItem.qty;
        await (_database.update(_database.inventories)
              ..where((i) => i.id.equals(resolvedInventoryItemId!)))
            .write(InventoriesCompanion(stock: Value(newStock)));
      }
    }
```
And in online sync `itemsPayload` (lines 792 & 885):
Add `'product_item_id': item.productItemId`.

---

## 5. Verification Method

To independently verify the implementation, Worker and Auditors should run:

1. **Verify Unit & Widget Tests:**
   ```bash
   flutter test test/features/pos/presentation/cart_held_transaction_test.dart
   flutter test test/features/pos/data/pos_repository_empirical_challenge_test.dart
   flutter test test/widget_test.dart
   ```
2. **Execute New Variant Dialog & Cart Integration Test:**
   ```bash
   flutter test test/features/pos/presentation/variant_dialog_test.dart
   ```
3. **Verify Entire Flutter Test Suite:**
   ```bash
   flutter test
   ```
4. **Static Analysis Verification:**
   ```bash
   flutter analyze lib/features/cart/ lib/features/pos/
   ```
   Must yield 0 errors and 0 warnings.
