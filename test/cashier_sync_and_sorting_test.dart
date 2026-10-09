import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/settings/data/sync_coordinator_service.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';

void main() {
  group('SyncSummaryResult User-Friendly Messaging Tests', () {
    test('formats successful sync message without technical jargon', () {
      final result = SyncSummaryResult(
        syncedTransactionsCount: 0,
        failedTransactionsCount: 0,
        syncedShiftsCount: 1,
        masterDataSuccess: true,
        errorMessage: null,
        syncedAt: DateTime.now(),
      );

      expect(result.hasFailures, isFalse);
      expect(
        result.userFriendlyMessage,
        'Sinkronisasi selesai! Data transaksi dan produk telah diperbarui.',
      );
      expect(result.userFriendlyMessage.toLowerCase().contains('delta'), isFalse);
    });

    test('formats sync message with synced transactions count', () {
      final result = SyncSummaryResult(
        syncedTransactionsCount: 5,
        failedTransactionsCount: 0,
        syncedShiftsCount: 1,
        masterDataSuccess: true,
        errorMessage: null,
        syncedAt: DateTime.now(),
      );

      expect(result.hasFailures, isFalse);
      expect(
        result.userFriendlyMessage,
        '5 transaksi terkirim & data produk telah diperbarui.',
      );
    });

    test('formats sync message with partially failed transactions', () {
      final result = SyncSummaryResult(
        syncedTransactionsCount: 3,
        failedTransactionsCount: 2,
        syncedShiftsCount: 1,
        masterDataSuccess: true,
        errorMessage: null,
        syncedAt: DateTime.now(),
      );

      expect(result.hasFailures, isTrue);
      expect(
        result.userFriendlyMessage,
        '3 transaksi terkirim, 2 butuh perhatian (cek Riwayat Transaksi).',
      );
    });

    test('formats network offline error message appropriately', () {
      final result = SyncSummaryResult(
        syncedTransactionsCount: 0,
        failedTransactionsCount: 0,
        syncedShiftsCount: 0,
        masterDataSuccess: false,
        errorMessage: 'Tidak dapat terhubung ke server. Data transaksi tetap aman di perangkat kasir.',
        syncedAt: DateTime.now(),
      );

      expect(result.hasFailures, isTrue);
      expect(
        result.userFriendlyMessage,
        'Tidak dapat terhubung ke server. Data transaksi tetap aman di perangkat kasir.',
      );
    });
  });

  group('Product List Sorting (Name ASC) Tests', () {
    test('filteredPosItemsProvider sorts items by name ascending (A-Z case-insensitive)', () async {
      final mockItems = [
        PosItem(
          id: 'p-3',
          name: 'Zebra Cake',
          price: 25000,
          stock: 10,
          isActive: true,
          isProductMode: true,
        ),
        PosItem(
          id: 'p-1',
          name: 'americano',
          price: 18000,
          stock: 15,
          isActive: true,
          isProductMode: true,
        ),
        PosItem(
          id: 'p-2',
          name: 'Cappuccino',
          price: 22000,
          stock: 20,
          isActive: true,
          isProductMode: true,
        ),
        PosItem(
          id: 'p-4',
          name: 'Bakwan Jagung',
          price: 5000,
          stock: 30,
          isActive: true,
          isProductMode: true,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          posItemsProvider.overrideWith((ref) => Stream.value(mockItems)),
          posCategoriesProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      AsyncValue<List<PosItem>>? lastValue;
      final subscription = container.listen<AsyncValue<List<PosItem>>>(
        filteredPosItemsProvider,
        (previous, next) {
          lastValue = next;
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await pumpEventQueue();

      expect(lastValue?.hasValue, isTrue);
      final sortedList = lastValue!.value!;
      expect(sortedList.length, 4);

      // Verify alphabetical order: americano, Bakwan Jagung, Cappuccino, Zebra Cake
      expect(sortedList[0].name, 'americano');
      expect(sortedList[1].name, 'Bakwan Jagung');
      expect(sortedList[2].name, 'Cappuccino');
      expect(sortedList[3].name, 'Zebra Cake');
    });
  });
}
