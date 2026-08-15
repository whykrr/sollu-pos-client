import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../pos/presentation/providers/transaction_provider.dart';

class LocalPaymentMethodOrderNotifier extends Notifier<List<String>> {
  static const String _key = 'sollu_local_payment_methods_order';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveOrder(List<String> orderedIds) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, jsonEncode(orderedIds));
    final repo = ref.read(transactionRepositoryProvider);
    await repo.updatePaymentMethodsLocalOrder(orderedIds);
    state = List.unmodifiable(orderedIds);
  }

  Future<void> resetToDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
    final repo = ref.read(transactionRepositoryProvider);
    await repo.resetPaymentMethodsLocalOrder();
    state = [];
  }
}

final localPaymentMethodOrderProvider =
    NotifierProvider<LocalPaymentMethodOrderNotifier, List<String>>(
  LocalPaymentMethodOrderNotifier.new,
);

/// Provider metode pembayaran terurut:
/// Menggunakan kolom localSortOrder jika dikustomisasi per device, fallback ke sortOrder pusat.
final orderedActivePaymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);

  return repository.watchActivePaymentMethods().map((methods) {
    final sorted = List<PaymentMethod>.from(methods);
    sorted.sort((a, b) {
      final orderA = a.localSortOrder ?? a.sortOrder;
      final orderB = b.localSortOrder ?? b.sortOrder;
      final compareOrder = orderA.compareTo(orderB);
      if (compareOrder != 0) return compareOrder;
      return a.name.compareTo(b.name);
    });

    return sorted;
  });
});
