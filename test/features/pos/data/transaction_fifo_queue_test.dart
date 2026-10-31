import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/enums/transaction_enums.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DioClient dioClient;
  late TransactionRepository repository;

  setUp(() {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dioClient = DioClient(SecureStorageService());
    repository = TransactionRepository(db, dioClient);
  });

  tearDown(() async {
    await db.close();
  });

  group('Background FIFO Transaction Queue Tests', () {
    test('Pushes accumulated pending transactions in strict FIFO sequential order (createdAt ASC)', () async {
      final sentTxNumbers = <String>[];

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              final data = options.data as Map<String, dynamic>;
              sentTxNumbers.add(data['transaction_number'].toString());
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'message': 'Synced'},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final t1 = DateTime(2026, 10, 10, 8, 0, 0);
      final t2 = DateTime(2026, 10, 10, 8, 5, 0);
      final t3 = DateTime(2026, 10, 10, 8, 10, 0);

      // Insert 3 transactions with different timestamps (simulate offline backlog)
      final txData = [
        ('tx-1', 'TRX-001', t2), // inserted out of order
        ('tx-2', 'TRX-002', t1), // earliest
        ('tx-3', 'TRX-003', t3), // latest
      ];

      for (final (id, number, createdAt) in txData) {
        await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: id,
                outletId: 'outlet-1',
                transactionNumber: number,
                subtotal: 50000.0,
                total: 50000.0,
                paymentStatus: TransactionPaymentStatus.paid.value,
                status: TransactionStatus.completed.value,
                isOffline: const Value(true),
                syncStatus: const Value('pending'),
                createdAt: Value(createdAt),
              ),
            );

        await db.into(db.transactionPayments).insert(
              TransactionPaymentsCompanion.insert(
                id: 'pay-$id',
                transactionId: id,
                paymentMethodId: const Value('cash'),
                amount: 50000.0,
                changeAmount: const Value(0.0),
              ),
            );
      }

      final syncedCount = await repository.syncPendingTransactions();

      expect(syncedCount, 3);
      // Strictly verified: FIFO order TRX-002 (t1) -> TRX-001 (t2) -> TRX-003 (t3)
      expect(sentTxNumbers, ['TRX-002', 'TRX-001', 'TRX-003']);

      final allTxs = await db.select(db.transactions).get();
      for (final tx in allTxs) {
        expect(tx.isOffline, false);
        expect(tx.syncStatus, 'synced');
        expect(tx.lastSyncError, isNull);
      }
    });

    test('Anti Head-of-Line Blocking: HTTP 422 failure marks tx as failed and continues next pending tx', () async {
      final sentTxNumbers = <String>[];

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              final data = options.data as Map<String, dynamic>;
              final txNum = data['transaction_number'].toString();
              sentTxNumbers.add(txNum);

              if (txNum == 'TRX-FAIL') {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 422,
                      data: {'message': 'Data transaksi tidak valid (422)'},
                    ),
                  ),
                );
              }

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final t1 = DateTime(2026, 10, 10, 8, 0, 0);
      final t2 = DateTime(2026, 10, 10, 8, 5, 0);

      // Insert failing transaction first, then valid transaction
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-fail',
              outletId: 'outlet-1',
              transactionNumber: 'TRX-FAIL',
              subtotal: 10000.0,
              total: 10000.0,
              paymentStatus: TransactionPaymentStatus.paid.value,
              status: TransactionStatus.completed.value,
              isOffline: const Value(true),
              syncStatus: const Value('pending'),
              createdAt: Value(t1),
            ),
          );
      await db.into(db.transactionPayments).insert(
            TransactionPaymentsCompanion.insert(
              id: 'pay-fail',
              transactionId: 'tx-fail',
              paymentMethodId: const Value('cash'),
              amount: 10000.0,
              changeAmount: const Value(0.0),
            ),
          );

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-success',
              outletId: 'outlet-1',
              transactionNumber: 'TRX-SUCCESS',
              subtotal: 25000.0,
              total: 25000.0,
              paymentStatus: TransactionPaymentStatus.paid.value,
              status: TransactionStatus.completed.value,
              isOffline: const Value(true),
              syncStatus: const Value('pending'),
              createdAt: Value(t2),
            ),
          );
      await db.into(db.transactionPayments).insert(
            TransactionPaymentsCompanion.insert(
              id: 'pay-success',
              transactionId: 'tx-success',
              paymentMethodId: const Value('cash'),
              amount: 25000.0,
              changeAmount: const Value(0.0),
            ),
          );

      final syncedCount = await repository.syncPendingTransactions();

      expect(syncedCount, 1);
      expect(sentTxNumbers, ['TRX-FAIL', 'TRX-SUCCESS']);

      final failedTx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-fail'))).getSingle();
      expect(failedTx.syncStatus, 'failed');
      expect(failedTx.isOffline, true);
      expect(failedTx.lastSyncError, contains('422'));

      final successTx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-success'))).getSingle();
      expect(successTx.syncStatus, 'synced');
      expect(successTx.isOffline, false);
    });

    test('Network offline stops batch and preserves pending status for retry', () async {
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException.connectionError(
                requestOptions: options,
                reason: 'No internet connection',
              ),
            );
          },
        ),
      );

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-offline',
              outletId: 'outlet-1',
              transactionNumber: 'TRX-OFFLINE',
              subtotal: 30000.0,
              total: 30000.0,
              paymentStatus: TransactionPaymentStatus.paid.value,
              status: TransactionStatus.completed.value,
              isOffline: const Value(true),
              syncStatus: const Value('pending'),
              createdAt: Value(DateTime.now()),
            ),
          );
      await db.into(db.transactionPayments).insert(
            TransactionPaymentsCompanion.insert(
              id: 'pay-offline',
              transactionId: 'tx-offline',
              paymentMethodId: const Value('cash'),
              amount: 30000.0,
              changeAmount: const Value(0.0),
            ),
          );

      final syncedCount = await repository.syncPendingTransactions();

      expect(syncedCount, 0);

      final tx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-offline'))).getSingle();
      // Should remain pending (not failed), ready for reconnection replay
      expect(tx.syncStatus, 'pending');
      expect(tx.isOffline, true);
    });

    test('createTransaction saves to SQLite atomik with pending status and triggers background queue non-blocking', () async {
      bool networkReached = false;
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            networkReached = true;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      final paymentMethod = PaymentMethod(
        id: 'pm-cash',
        name: 'Tunai',
        type: 'cash',
        referencePolicy: 'hidden',
        openCashDrawer: true,
        isSystem: true,
        isActive: true,
      );

      final List<CartItem> cartItems = [
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          inventoryItemId: 'inv-1',
          name: 'Ice Americano',
          price: 25000.0,
          qty: 1,
        ),
      ];

      final result = await repository.createTransaction(
        items: cartItems,
        subtotal: 25000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 25000.0,
        paymentMethod: paymentMethod,
        cashReceived: 50000.0,
        changeAmount: 25000.0,
      );

      expect(result.transaction.total, 25000.0);
      expect(result.detail.items.length, 1);
      expect(result.detail.items.first.productName, 'Ice Americano');

      // Allow background microtask / future to complete
      await pumpEventQueue();

      expect(networkReached, true);

      final savedTx = await (db.select(db.transactions)..where((t) => t.id.equals(result.transaction.id))).getSingle();
      expect(savedTx.syncStatus, 'synced');
      expect(savedTx.isOffline, false);
    });

    test('Mutex lock prevents duplicate concurrent execution and shares running completer', () async {
      int requestCount = 0;
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (options.path == ApiEndpoints.transactions) {
              requestCount++;
              // Delay slightly to simulate in-flight network roundtrip
              await Future.delayed(const Duration(milliseconds: 50));
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-mutex',
              outletId: 'outlet-1',
              transactionNumber: 'TRX-MUTEX-001',
              subtotal: 10000.0,
              total: 10000.0,
              paymentStatus: TransactionPaymentStatus.paid.value,
              status: TransactionStatus.completed.value,
              isOffline: const Value(true),
              syncStatus: const Value('pending'),
              createdAt: Value(DateTime.now()),
            ),
          );
      await db.into(db.transactionPayments).insert(
            TransactionPaymentsCompanion.insert(
              id: 'pay-mutex',
              transactionId: 'tx-mutex',
              paymentMethodId: const Value('cash'),
              amount: 10000.0,
              changeAmount: const Value(0.0),
            ),
          );

      // Launch 3 concurrent calls simultaneously
      final future1 = repository.syncPendingTransactions();
      final future2 = repository.syncPendingTransactions();
      repository.enqueueSyncQueue();

      final results = await Future.wait([future1, future2]);

      expect(results[0], 1);
      expect(results[1], 1);
      // The HTTP endpoint should only be called EXACTLY ONCE!
      expect(requestCount, 1);
      expect(repository.isSyncQueueRunning, false);
    });
  });
}
