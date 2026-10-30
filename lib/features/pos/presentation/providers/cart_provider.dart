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

      final sameModifiers = _modifiersEqual(
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
      ref.read(lastScannedCartItemProvider.notifier).setItem(updatedItem);
    } else {
      // Add new item
      state = [...state, item];
      ref.read(lastScannedCartItemProvider.notifier).setItem(item);
    }
  }

  bool _modifiersEqual(
    Map<String, List<String>> a,
    Map<String, List<String>> b,
  ) {
    final cleanA = Map.fromEntries(a.entries.where((e) => e.value.isNotEmpty));
    final cleanB = Map.fromEntries(b.entries.where((e) => e.value.isNotEmpty));
    return const DeepCollectionEquality.unordered().equals(cleanA, cleanB);
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
    final currentLast = ref.read(lastScannedCartItemProvider);
    if (currentLast?.id == id) {
      final updated = newState.firstWhereOrNull((item) => item.id == id);
      ref.read(lastScannedCartItemProvider.notifier).setItem(updated ?? newState.lastOrNull);
    }
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
        final updated = item.copyWith(
          qty: qty,
          discountType: discountType,
          discountValue: discountValue,
          notes: notes,
        );
        newState.add(updated);
        final currentLast = ref.read(lastScannedCartItemProvider);
        if (currentLast?.id == id) {
          ref.read(lastScannedCartItemProvider.notifier).setItem(updated);
        }
      } else {
        newState.add(item);
      }
    }
    state = newState;
  }

  void updatePrice(String id, double newPrice) {
    final newState = <CartItem>[];
    for (final item in state) {
      if (item.id == id) {
        final updated = item.copyWith(price: newPrice);
        newState.add(updated);
        final currentLast = ref.read(lastScannedCartItemProvider);
        if (currentLast?.id == id) {
          ref.read(lastScannedCartItemProvider.notifier).setItem(updated);
        }
      } else {
        newState.add(item);
      }
    }
    state = newState;
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    if (ref.read(lastScannedCartItemProvider)?.id == id) {
      ref.read(lastScannedCartItemProvider.notifier).setItem(state.lastOrNull);
    }
  }

  void clearCart() {
    state = [];
    ref.read(lastScannedCartItemProvider.notifier).setItem(null);
  }

  void setCart(List<CartItem> items) {
    state = items;
    ref.read(lastScannedCartItemProvider.notifier).setItem(items.lastOrNull);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class LastScannedCartItemNotifier extends Notifier<CartItem?> {
  @override
  CartItem? build() => null;

  @override
  set state(CartItem? value) => super.state = value;

  void setItem(CartItem? item) => state = item;
}

final lastScannedCartItemProvider =
    NotifierProvider<LastScannedCartItemNotifier, CartItem?>(
  LastScannedCartItemNotifier.new,
);

class SelectedCartIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  // Setter publik agar pemanggilan ref.read(selectedCartIndexProvider.notifier).state = ... tetap valid
  @override
  set state(int value) => super.state = value;

  void select(int index) => state = index;
}

final selectedCartIndexProvider =
    NotifierProvider<SelectedCartIndexNotifier, int>(
  SelectedCartIndexNotifier.new,
);
