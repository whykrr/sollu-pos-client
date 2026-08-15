import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_provider.dart';

class HoldOrder {
  final String id;
  final String? customerName;
  final String? note;
  final List<CartItem> items;
  final double subtotal;
  final DateTime heldAt;

  HoldOrder({
    required this.id,
    this.customerName,
    this.note,
    required this.items,
    required this.subtotal,
    required this.heldAt,
  });
}

class HoldCartNotifier extends Notifier<List<HoldOrder>> {
  @override
  List<HoldOrder> build() => [];

  /// Menahan pesanan keranjang saat ini
  HoldOrder? holdCurrentCart(List<CartItem> items, {String? customerName, String? note}) {
    if (items.isEmpty) return null;

    final subtotal = items.fold(0.0, (sum, item) => sum + (item.price * item.qty));
    final newHoldOrder = HoldOrder(
      id: 'HOLD-${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      note: note,
      items: List.from(items),
      subtotal: subtotal,
      heldAt: DateTime.now(),
    );

    state = [newHoldOrder, ...state];
    return newHoldOrder;
  }

  /// Menghapus transaksi yang ditahan dari antrean
  void removeHoldOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }

  /// Mengambil transaksi yang ditahan untuk dimuat kembali ke keranjang
  HoldOrder? restoreHoldOrder(String id) {
    final order = state.firstWhere((element) => element.id == id, orElse: () => throw Exception('Order not found'));
    removeHoldOrder(id);
    return order;
  }
}

final holdCartProvider = NotifierProvider<HoldCartNotifier, List<HoldOrder>>(HoldCartNotifier.new);
