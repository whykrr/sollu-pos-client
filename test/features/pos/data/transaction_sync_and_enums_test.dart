import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/enums/transaction_enums.dart';

void main() {
  group('Transaction Enums SSOT Tests', () {
    test('TransactionStatus values match Laravel backend enum values', () {
      expect(TransactionStatus.draft.value, 'draft');
      expect(TransactionStatus.hold.value, 'hold');
      expect(TransactionStatus.completed.value, 'completed');
      expect(TransactionStatus.voided.value, 'void');
      expect(TransactionStatus.cancelled.value, 'cancel');

      expect(TransactionStatus.fromValue('draft'), TransactionStatus.draft);
      expect(TransactionStatus.fromValue('completed'), TransactionStatus.completed);
      expect(TransactionStatus.fromValue('void'), TransactionStatus.voided);
      expect(TransactionStatus.fromValue('cancel'), TransactionStatus.cancelled);
      expect(TransactionStatus.fromValue('unknown'), TransactionStatus.completed);
    });

    test('TransactionPaymentStatus values match Laravel backend enum values', () {
      expect(TransactionPaymentStatus.draft.value, 'draft');
      expect(TransactionPaymentStatus.unpaid.value, 'unpaid');
      expect(TransactionPaymentStatus.partial.value, 'partial');
      expect(TransactionPaymentStatus.paid.value, 'paid');

      expect(TransactionPaymentStatus.fromValue('paid'), TransactionPaymentStatus.paid);
      expect(TransactionPaymentStatus.fromValue('unpaid'), TransactionPaymentStatus.unpaid);
      expect(TransactionPaymentStatus.fromValue('partial'), TransactionPaymentStatus.partial);
      expect(TransactionPaymentStatus.fromValue('unknown'), TransactionPaymentStatus.paid);
    });

    test('SyncStatus enum values', () {
      expect(SyncStatus.pending.value, 'pending');
      expect(SyncStatus.syncing.value, 'syncing');
      expect(SyncStatus.synced.value, 'synced');
      expect(SyncStatus.failed.value, 'failed');

      expect(SyncStatus.fromValue('failed'), SyncStatus.failed);
      expect(SyncStatus.fromValue('unknown'), SyncStatus.pending);
    });
  });

  group('Drift Transactions Table v8 Schema & Sync Tracking Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Stores and updates sync status, attempts, and error details correctly', () async {
      final now = DateTime.now();

      // Insert transaction with pending sync status
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-offline-1',
              outletId: 'out-1',
              transactionNumber: 'TRX-TEST-001',
              total: 50000.0,
              subtotal: 50000.0,
              createdAt: Value(now),
              status: TransactionStatus.completed.value,
              paymentStatus: TransactionPaymentStatus.paid.value,
              isOffline: const Value(true),
              syncStatus: Value(SyncStatus.pending.value),
              syncAttempts: const Value(0),
            ),
          );

      var tx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-offline-1'))).getSingle();
      expect(tx.syncStatus, SyncStatus.pending.value);
      expect(tx.syncAttempts, 0);
      expect(tx.lastSyncError, isNull);

      // Simulate failure recording (HTTP 422 / max attempts)
      await (db.update(db.transactions)..where((t) => t.id.equals('tx-offline-1'))).write(
        TransactionsCompanion(
          syncStatus: Value(SyncStatus.failed.value),
          syncAttempts: const Value(1),
          lastSyncError: const Value('HTTP 422: Unprocessable Entity (Invalid modifier)'),
          lastSyncAttemptAt: Value(now),
        ),
      );

      tx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-offline-1'))).getSingle();
      expect(tx.syncStatus, SyncStatus.failed.value);
      expect(tx.syncAttempts, 1);
      expect(tx.lastSyncError, contains('HTTP 422'));

      // Query failed offline transactions
      final failedTxs = await (db.select(db.transactions)
            ..where((t) => t.isOffline.equals(true) & t.syncStatus.equals(SyncStatus.failed.value)))
          .get();
      expect(failedTxs.length, 1);
      expect(failedTxs.first.id, 'tx-offline-1');
    });
  });
}
