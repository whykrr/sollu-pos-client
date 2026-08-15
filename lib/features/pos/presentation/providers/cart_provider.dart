import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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

  CartItem({
    required this.id,
    required this.productId,
    required this.inventoryItemId,
    this.variantGroupOptionId,
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
      // Cap at price if needed, but assuming valid percentage
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
    int? qty,
    String? discountType,
    double? discountValue,
    String? notes,
    String? variantGroupOptionId,
  }) {
    return CartItem(
      id: id,
      productId: productId,
      inventoryItemId: inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      name: name,
      price: price,
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      notes: notes ?? this.notes,
      selectedVariants: selectedVariants,
      selectedModifiers: selectedModifiers,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    // Check if an identical item exists (same inventory/product and same modifiers/variants)
    final existingIndex = state.indexWhere((element) {
      final sameInventory = element.inventoryItemId == item.inventoryItemId && element.productId == item.productId;
      final sameVariants = const DeepCollectionEquality().equals(element.selectedVariants, item.selectedVariants);
      final sameModifiers = const DeepCollectionEquality().equals(element.selectedModifiers, item.selectedModifiers);
      return sameInventory && sameVariants && sameModifiers;
    });

    if (existingIndex != -1) {
      // Increase qty of existing item
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(qty: existingItem.qty + item.qty);
      
      final newState = List<CartItem>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new item
      state = [...state, item];
    }
  }

  void updateQty(String id, int delta) {
    final newState = <CartItem>[];
    for (final item in state) {
      if (item.id == id) {
        final newQty = item.qty + delta;
        if (newQty > 0) {
          newState.add(item.copyWith(qty: newQty));
        }
      } else {
        newState.add(item);
      }
    }
    state = newState;
  }

  void updateItemDetails(
    String id, {
    required int qty,
    String? discountType,
    double? discountValue,
    String? notes,
  }) {
    final newState = <CartItem>[];
    for (final item in state) {
      if (item.id == id) {
        newState.add(CartItem(
          id: item.id,
          productId: item.productId,
          inventoryItemId: item.inventoryItemId,
          variantGroupOptionId: item.variantGroupOptionId,
          name: item.name,
          price: item.price,
          qty: qty,
          discountType: discountType,
          discountValue: discountValue,
          notes: notes,
          selectedVariants: item.selectedVariants,
          selectedModifiers: item.selectedModifiers,
        ));
      } else {
        newState.add(item);
      }
    }
    state = newState;
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
