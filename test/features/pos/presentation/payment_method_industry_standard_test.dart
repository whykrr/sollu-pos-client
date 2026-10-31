import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<PaymentMethod> methods;

  FakeTransactionRepository(this.methods);

  @override
  Stream<List<PaymentMethod>> watchActivePaymentMethods() {
    return Stream.value(methods);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Payment Methods Industry Standard Ordering Tests', () {
    test('activePaymentMethodsProvider sorts methods strictly by industry standard hierarchy', () async {
      final unsortedMethods = [
        const PaymentMethod(
          id: 'pm-custom',
          name: 'Voucher Karyawan',
          type: 'custom',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-transfer',
          name: 'Transfer Mandiri',
          type: 'bank_transfer',
          accountNumber: '987654321',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-ewallet',
          name: 'GoPay',
          type: 'ewallet',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-edc-bca',
          name: 'EDC BCA',
          type: 'edc',
          referencePolicy: 'mandatory',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-qris',
          name: 'QRIS Statis BCA',
          type: 'qris',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-cash',
          name: 'Tunai',
          type: 'cash',
          referencePolicy: 'hidden',
          openCashDrawer: true,
          isSystem: true,
          isActive: true,
        ),
      ];

      final fakeRepo = FakeTransactionRepository(unsortedMethods);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final completer = Completer<List<PaymentMethod>>();
      final sub = container.listen(
        activePaymentMethodsProvider,
        (prev, next) {
          next.whenData((data) {
            if (!completer.isCompleted) {
              completer.complete(data);
            }
          });
        },
        fireImmediately: true,
      );

      final result = await completer.future.timeout(const Duration(seconds: 3));
      sub.close();
      container.dispose();

      // Expected order:
      // 1. Tunai (cash)
      // 2. QRIS Statis BCA (qris)
      // 3. EDC BCA (edc)
      // 4. GoPay (ewallet)
      // 5. Transfer Mandiri (bank_transfer)
      // 6. Voucher Karyawan (custom)
      expect(result.map((m) => m.type).toList(), [
        'cash',
        'qris',
        'edc',
        'ewallet',
        'bank_transfer',
        'custom',
      ]);

      expect(result.first.name, 'Tunai');
      expect(result.first.openCashDrawer, isTrue);
      expect(result.first.referencePolicy, 'hidden');
    });

    test('Methods in same category are sorted by isSystem DESC, name ASC', () async {
      final methods = [
        const PaymentMethod(
          id: 'pm-cash-custom',
          name: 'Tunai Kas Kecil',
          type: 'cash',
          referencePolicy: 'hidden',
          openCashDrawer: true,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-cash-system',
          name: 'Tunai',
          type: 'cash',
          referencePolicy: 'hidden',
          openCashDrawer: true,
          isSystem: true,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-qris-b',
          name: 'QRIS Mandiri',
          type: 'qris',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
        const PaymentMethod(
          id: 'pm-qris-a',
          name: 'QRIS BCA',
          type: 'qris',
          referencePolicy: 'optional',
          openCashDrawer: false,
          isSystem: false,
          isActive: true,
        ),
      ];

      final fakeRepo = FakeTransactionRepository(methods);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final completer = Completer<List<PaymentMethod>>();
      final sub = container.listen(
        activePaymentMethodsProvider,
        (prev, next) {
          next.whenData((data) {
            if (!completer.isCompleted) {
              completer.complete(data);
            }
          });
        },
        fireImmediately: true,
      );

      final result = await completer.future.timeout(const Duration(seconds: 3));
      sub.close();
      container.dispose();

      expect(result.map((m) => m.name).toList(), [
        'Tunai', // isSystem: true comes before isSystem: false
        'Tunai Kas Kecil',
        'QRIS BCA', // name A before M
        'QRIS Mandiri',
      ]);
    });
  });
}
