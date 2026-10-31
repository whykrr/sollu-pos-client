import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PosRepository posRepo;
  late DioClient dioClient;
  late TransactionRepository txRepo;

  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    posRepo = PosRepository(db);
    dioClient = DioClient(SecureStorageService());
    txRepo = TransactionRepository(db, dioClient);

    // Setup Parent Product with Barcode
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: 'prod-coffee-parent',
            name: 'Kopi Susu Senja',
            price: const Value(18000.0),
            barcode: const Value('8990001000'),
            sku: const Value('KSS-PARENT'),
            isAvailable: const Value(true),
            hasVariants: const Value(true),
            trackInventory: const Value(true),
          ),
        );

    // Setup Specific Variant Product Items
    // 1. Regular Hot: specific barcode
    await db.into(db.productItems).insert(
          ProductItemsCompanion.insert(
            id: 'pi-coffee-reg-hot',
            productId: 'prod-coffee-parent',
            name: 'Kopi Susu Senja - Regular Hot',
            variantCombination: const Value('Regular - Hot'),
            barcode: const Value('8990001001'),
            sku: const Value('KSS-REG-HOT'),
            trackInventory: const Value(true),
            isActive: const Value(true),
            sellable: const Value(true),
          ),
        );
    await db.into(db.productPrices).insert(
          ProductPricesCompanion.insert(
            id: 'price-1',
            productId: 'prod-coffee-parent',
            productItemId: const Value('pi-coffee-reg-hot'),
            amount: const Value(18000.0),
          ),
        );
    await db.into(db.inventories).insert(
          InventoriesCompanion.insert(
            id: 'inv-reg-hot',
            productId: 'prod-coffee-parent',
            productItemId: const Value('pi-coffee-reg-hot'),
            name: 'Kopi Susu Senja - Regular Hot',
            stock: const Value(20.0),
            trackInventory: const Value(true),
          ),
        );

    // 2. Untracked Service Product (trackInventory: false)
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: 'prod-service',
            name: 'Cuci Sepatu Premium',
            price: const Value(35000.0),
            barcode: const Value('8990002000'),
            isAvailable: const Value(true),
            hasVariants: const Value(false),
            trackInventory: const Value(false),
          ),
        );
    await db.into(db.productItems).insert(
          ProductItemsCompanion.insert(
            id: 'pi-service-default',
            productId: 'prod-service',
            name: 'Cuci Sepatu Premium',
            trackInventory: const Value(false),
            isActive: const Value(true),
            sellable: const Value(true),
          ),
        );
    await db.into(db.productPrices).insert(
          ProductPricesCompanion.insert(
            id: 'price-service',
            productId: 'prod-service',
            productItemId: const Value('pi-service-default'),
            amount: const Value(35000.0),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Barcode Omni-Search Differentiation Tests', () {
    test('scanning parent product barcode returns parent item with hasVariants=true', () async {
      final item = await posRepo.findItemByBarcodeOrSku('8990001000');
      expect(item, isNotNull);
      expect(item!.hasVariants, isTrue);
      expect(item.product?.id, 'prod-coffee-parent');
      expect(item.product?.barcode, '8990001000');
    });

    test('scanning specific variant barcode returns specific variant productItem', () async {
      final item = await posRepo.findItemByBarcodeOrSku('8990001001');
      expect(item, isNotNull);
      expect(item!.productItemId, 'pi-coffee-reg-hot');
      expect(item.variantCombination, 'Regular - Hot');
      expect(item.price, 18000.0);
    });
  });

  group('Decoupled Stock & Transaction Persistence Tests', () {
    test('persists productItemId and bypasses stock decrement for untracked items', () async {
      Map<String, dynamic>? syncedPayload;

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              syncedPayload = options.data as Map<String, dynamic>;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'message': 'OK'},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final cartItems = [
        // Tracked item
        CartItem(
          id: 'cart-1',
          productId: 'prod-coffee-parent',
          productItemId: 'pi-coffee-reg-hot',
          inventoryItemId: 'inv-reg-hot',
          name: 'Kopi Susu Senja - Regular Hot',
          price: 18000.0,
          qty: 2,
          trackInventory: true,
        ),
        // Untracked service item
        CartItem(
          id: 'cart-2',
          productId: 'prod-service',
          productItemId: 'pi-service-default',
          inventoryItemId: '',
          name: 'Cuci Sepatu Premium',
          price: 35000.0,
          qty: 1,
          trackInventory: false,
        ),
      ];

      const paymentMethod = PaymentMethod(
        id: 'pm-cash',
        name: 'Tunai',
        type: 'cash',
        referencePolicy: 'hidden',
        openCashDrawer: true,
        isSystem: true,
        isActive: true,
      );

      final result = await txRepo.createTransaction(
        items: cartItems,
        subtotal: 71000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 71000.0,
        paymentMethod: paymentMethod,
        cashReceived: 71000.0,
        changeAmount: 0.0,
      );

      expect(result.transaction, isNotNull);

      // Await sync queue to finish sending transaction
      await txRepo.syncPendingTransactions();

      // Verify transaction_items table in SQLite has productItemId populated
      final savedItems = await (db.select(db.transactionItems)
            ..where((tbl) => tbl.transactionId.equals(result.transaction.id)))
          .get();
      expect(savedItems.length, 2);

      final trackedItem = savedItems.firstWhere((i) => i.productId == 'prod-coffee-parent');
      expect(trackedItem.productItemId, 'pi-coffee-reg-hot');

      final untrackedItem = savedItems.firstWhere((i) => i.productId == 'prod-service');
      expect(untrackedItem.productItemId, 'pi-service-default');

      // Verify stock deduction:
      // Tracked item was 20.0, sold 2 -> should be 18.0
      final inv = await (db.select(db.inventories)
            ..where((tbl) => tbl.id.equals('inv-reg-hot')))
          .getSingle();
      expect(inv.stock, 18.0);

      // Verify online sync payload has product_item_id
      expect(syncedPayload, isNotNull);
      final itemsPayload = syncedPayload!['items'] as List<dynamic>;
      expect(itemsPayload.length, 2);

      final p1 = itemsPayload.firstWhere((i) => i['product_id'] == 'prod-coffee-parent');
      expect(p1['product_item_id'], 'pi-coffee-reg-hot');

      final p2 = itemsPayload.firstWhere((i) => i['product_id'] == 'prod-service');
      expect(p2['product_item_id'], 'pi-service-default');
    });
  });
}
