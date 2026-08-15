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
    this.notes,
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
  });

  CartItem copyWith({
    int? qty,
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

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
