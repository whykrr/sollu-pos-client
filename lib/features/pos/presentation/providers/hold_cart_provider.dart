import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../settings/presentation/providers/outlet_settings_provider.dart';
import '../../data/database/daos/held_bills_dao.dart';
import 'cart_provider.dart';

/// Stream Provider untuk daftar transaksi yang ditahan di SQLite lokal
final heldTransactionsStreamProvider =
    StreamProvider<List<HeldTransaction>>((ref) {
  final dao = ref.watch(heldBillsDaoProvider);
  final outletId = ref.watch(currentOutletIdProvider);
  return dao.watchHeldTransactions(outletId);
});

/// Service untuk mengelola transaksi yang ditahan (Hold & Resume) di SQLite
class HeldBillsService {
  final HeldBillsDao _dao;
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  HeldBillsService(this._dao, this._ref);

  /// Menahan pesanan keranjang saat ini secara persisten ke SQLite
  Future<HeldTransaction?> holdCurrentCart({
    required List<CartItem> items,
    required String holdLabel,
    String? customerName,
    String? tableNumber,
    String? notes,
  }) async {
    if (items.isEmpty) return null;

    final outletId = _ref.read(currentOutletIdProvider);
    final id = _uuid.v7(); // UUIDv7 untuk penomoran berurutan berbasis waktu

    final double subtotal = items.fold(
      0.0,
      (sum, item) => sum + item.calculatedSubtotal,
    );
    final double total = subtotal;

    final cartPayloadJson =
        jsonEncode(items.map((e) => e.toJson()).toList());

    final entry = HeldTransactionsCompanion.insert(
      id: id,
      outletId: outletId,
      holdLabel: holdLabel,
      customerName: Value(customerName),
      tableNumber: Value(tableNumber),
      subtotal: subtotal,
      total: total,
      cartPayload: cartPayloadJson,
      notes: Value(notes),
      heldAt: DateTime.now(),
    );

    await _dao.insertHeldTransaction(entry);

    // Bersihkan keranjang saat ini
    _ref.read(cartProvider.notifier).clearCart();

    return _dao.getHeldTransactionById(id);
  }

  /// Memulihkan transaksi yang ditahan kembali ke keranjang belanja
  Future<bool> resumeHeldBill(HeldTransaction heldTx) async {
    try {
      final decodedList = jsonDecode(heldTx.cartPayload) as List;
      final restoredItems = decodedList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();

      _ref.read(cartProvider.notifier).setCart(restoredItems);

      // Hapus dari SQLite setelah sukses dimuat kembali
      await _dao.deleteHeldTransaction(heldTx.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menghapus transaksi yang ditahan dari SQLite
  Future<void> deleteHeldBill(String id) async {
    await _dao.deleteHeldTransaction(id);
  }
}

final heldBillsServiceProvider = Provider<HeldBillsService>((ref) {
  final dao = ref.watch(heldBillsDaoProvider);
  return HeldBillsService(dao, ref);
});
