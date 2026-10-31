import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/outlet_settings_service.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/data/sync/delta_sync_service.dart';
import 'package:sollu_pos_client/features/pos/data/sync/initial_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DioClient dioClient;
  late SharedPreferences prefs;
  late OutletSettingsService outletSettingsService;
  late PosRepository posRepository;

  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    db = AppDatabase.forTesting(NativeDatabase.memory());
    dioClient = DioClient(SecureStorageService());
    outletSettingsService = OutletSettingsService(prefs);
    posRepository = PosRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Stress & Edge Case Harness: Initial Sync Batch Ingestion', () {
    test('Batch insertion with 2-level variant groups, non-tracked items, and idempotency', () async {
      final initialPayload = {
        'synced_at': '2026-10-22T12:00:00Z',
        'product_categories': [
          {'id': 'cat-beverage', 'name': 'Beverages', 'parent_id': null, 'sort_order': 1},
          {'id': 'cat-coffee', 'name': 'Coffee', 'parent_id': 'cat-beverage', 'sort_order': 2},
        ],
        'products': [
          {
            'id': 'prod-latte',
            'name': 'Caffe Latte',
            'product_category_id': 'cat-coffee',
            'sku': 'PRD-LAT',
            'barcode': 'BC-LAT-ROOT',
            'price': 25000.0,
            'is_show': 1,
            'product_type': 'basic',
            'unit': 'Cup',
            'has_variant': 1,
            'track_inventory': 1,
          },
          {
            'id': 'prod-service',
            'name': 'Delivery Fee',
            'product_category_id': null,
            'sku': 'SRV-DLV',
            'barcode': 'SRV-001',
            'price': 15000.0,
            'is_show': 1,
            'product_type': 'service',
            'unit': 'Service',
            'has_variant': 0,
            'track_inventory': 0,
          },
        ],
        'variant_groups': [
          {'id': 'vg-size', 'product_id': 'prod-latte', 'name': 'Size'},
          {'id': 'vg-temp', 'product_id': 'prod-latte', 'name': 'Temperature'},
        ],
        'variant_group_options': [
          {'id': 'vgo-reg', 'variant_group_id': 'vg-size', 'name': 'Regular'},
          {'id': 'vgo-lrg', 'variant_group_id': 'vg-size', 'name': 'Large'},
          {'id': 'vgo-hot', 'variant_group_id': 'vg-temp', 'name': 'Hot'},
          {'id': 'vgo-ice', 'variant_group_id': 'vg-temp', 'name': 'Iced'},
        ],
        'product_items': [
          // 4 combinations for Latte
          {
            'id': 'item-lat-reg-hot',
            'product_id': 'prod-latte',
            'name': 'Caffe Latte - Regular / Hot',
            'variant_combination': 'Regular / Hot',
            'sku': 'SKU-LAT-RH',
            'barcode': 'BC-LAT-RH',
            'track_inventory': 1,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Cup',
          },
          {
            'id': 'item-lat-reg-ice',
            'product_id': 'prod-latte',
            'name': 'Caffe Latte - Regular / Iced',
            'variant_combination': 'Regular / Iced',
            'sku': 'SKU-LAT-RI',
            'barcode': 'BC-LAT-RI',
            'track_inventory': 1,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Cup',
          },
          {
            'id': 'item-lat-lrg-hot',
            'product_id': 'prod-latte',
            'name': 'Caffe Latte - Large / Hot',
            'variant_combination': 'Large / Hot',
            'sku': 'SKU-LAT-LH',
            'barcode': 'BC-LAT-LH',
            'track_inventory': 1,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Cup',
          },
          {
            'id': 'item-lat-lrg-ice',
            'product_id': 'prod-latte',
            'name': 'Caffe Latte - Large / Iced',
            'variant_combination': 'Large / Iced',
            'sku': 'SKU-LAT-LI',
            'barcode': 'BC-LAT-LI',
            'track_inventory': 1,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Cup',
          },
          // Single product item for Delivery Fee (no inventory)
          {
            'id': 'item-srv-dlv',
            'product_id': 'prod-service',
            'name': 'Delivery Fee',
            'variant_combination': null,
            'sku': 'SRV-DLV',
            'barcode': 'SRV-001',
            'track_inventory': 0,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Service',
          },
        ],
        'product_item_variant_group_options': [
          {'product_item_id': 'item-lat-reg-hot', 'variant_group_option_id': 'vgo-reg'},
          {'product_item_id': 'item-lat-reg-hot', 'variant_group_option_id': 'vgo-hot'},
          {'product_item_id': 'item-lat-reg-ice', 'variant_group_option_id': 'vgo-reg'},
          {'product_item_id': 'item-lat-reg-ice', 'variant_group_option_id': 'vgo-ice'},
          {'product_item_id': 'item-lat-lrg-hot', 'variant_group_option_id': 'vgo-lrg'},
          {'product_item_id': 'item-lat-lrg-hot', 'variant_group_option_id': 'vgo-hot'},
          {'product_item_id': 'item-lat-lrg-ice', 'variant_group_option_id': 'vgo-lrg'},
          {'product_item_id': 'item-lat-lrg-ice', 'variant_group_option_id': 'vgo-ice'},
        ],
        'inventory_items': [
          {
            'id': 'inv-lat-reg-hot',
            'product_id': 'prod-latte',
            'product_item_id': 'item-lat-reg-hot',
            'name': 'Caffe Latte - Regular / Hot',
            'sku': 'SKU-LAT-RH',
            'barcode': 'BC-LAT-RH',
            'track_inventory': 1,
            'is_active': 1,
            'unit': 'Cup',
          },
        ],
        'inventory_balances': [
          {'inventory_item_id': 'inv-lat-reg-hot', 'current_stock': 25.0},
        ],
        'product_prices': [
          {'id': 'pr-lat-rh', 'product_id': 'prod-latte', 'product_item_id': 'item-lat-reg-hot', 'amount': 25000.0},
          {'id': 'pr-lat-ri', 'product_id': 'prod-latte', 'product_item_id': 'item-lat-reg-ice', 'amount': 27000.0},
          {'id': 'pr-lat-lh', 'product_id': 'prod-latte', 'product_item_id': 'item-lat-lrg-hot', 'amount': 30000.0},
          {'id': 'pr-lat-li', 'product_id': 'prod-latte', 'product_item_id': 'item-lat-lrg-ice', 'amount': 32000.0},
          {'id': 'pr-srv', 'product_id': 'prod-service', 'product_item_id': 'item-srv-dlv', 'amount': 15000.0},
        ],
      };

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.syncInitial) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': initialPayload},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final initialSyncService = InitialSyncService(
        dioClient,
        db,
        outletSettingsService,
        prefs,
      );

      // First initial sync
      final sync1 = await initialSyncService.syncInitialSnapshot();
      expect(sync1, isNotNull);

      // Verify all tables populated correctly
      final products = await db.select(db.products).get();
      expect(products.length, 2);

      final items = await db.select(db.productItems).get();
      expect(items.length, 5);

      final pivots = await db.select(db.productItemVariantGroupOptions).get();
      expect(pivots.length, 8);

      final prices = await db.select(db.productPrices).get();
      expect(prices.length, 5);

      // Test multi-variant resolution via PosRepository
      final resolvedItemId = await posRepository.findProductItemIdForVariants(
        'prod-latte',
        ['vgo-lrg', 'vgo-ice'],
      );
      expect(resolvedItemId, 'item-lat-lrg-ice');

      // Test aggregative category filtering
      final rootCategoryItems = await posRepository.watchItemsByCategory(categoryId: 'cat-beverage').first;
      expect(rootCategoryItems.length, 4); // All 4 latte items match under cat-coffee which has parent cat-beverage

      final childCategoryItems = await posRepository.watchItemsByCategory(categoryId: 'cat-coffee').first;
      expect(childCategoryItems.length, 4);

      // Verify non-inventory service item
      final srvItem = await (db.select(db.productItems)..where((t) => t.id.equals('item-srv-dlv'))).getSingle();
      expect(srvItem.trackInventory, false);
      expect(srvItem.variantCombination, isNull);

      // Second initial sync (Idempotency test)
      final sync2 = await initialSyncService.syncInitialSnapshot();
      expect(sync2, isNotNull);
      final itemsAfterSecondSync = await db.select(db.productItems).get();
      expect(itemsAfterSecondSync.length, 5);
      final pivotsAfterSecondSync = await db.select(db.productItemVariantGroupOptions).get();
      expect(pivotsAfterSecondSync.length, 8);
    });
  });

  group('Stress & Edge Case Harness: Delta Sync Upsert and Cascade', () {
    test('Delta sync handles updates, new item addition, and item deletion cascade', () async {
      // 1. Pre-seed database with a product and two items
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-teh',
              name: 'Teh Manis',
              price: const Value(5000.0),
              isAvailable: const Value(true),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-teh-panas',
              productId: 'prod-teh',
              name: 'Teh Manis Panas',
              variantCombination: const Value('Panas'),
              sku: const Value('SKU-TP'),
              barcode: const Value('BC-TP'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'vg-teh-temp',
              productId: 'prod-teh',
              name: 'Suhu',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'vgo-teh-panas',
              variantGroupId: 'vg-teh-temp',
              name: 'Panas',
            ),
          );

      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-teh-panas',
              variantGroupOptionId: 'vgo-teh-panas',
            ),
          );

      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'price-teh-panas',
              productId: 'prod-teh',
              productItemId: const Value('item-teh-panas'),
              amount: const Value(5000.0),
            ),
          );

      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-teh-panas',
              productId: 'prod-teh',
              productItemId: const Value('item-teh-panas'),
              name: 'Teh Manis Panas',
              stock: const Value(10.0),
            ),
          );

      // Verify pre-seeded state
      expect((await db.select(db.productItems).get()).length, 1);
      expect((await db.select(db.productItemVariantGroupOptions).get()).length, 1);
      expect((await db.select(db.productPrices).get()).length, 1);
      expect((await db.select(db.inventories).get()).length, 1);

      // 2. Prepare Delta response:
      // - Upsert item-teh-panas (change barcode, price)
      // - Insert new item-teh-es
      // - Delete nothing yet
      final deltaPayload = {
        'synced_at': '2026-10-22T12:05:00Z',
        'updated_product_items': [
          {
            'id': 'item-teh-panas',
            'product_id': 'prod-teh',
            'name': 'Teh Manis Panas (Updated)',
            'variant_combination': 'Panas',
            'sku': 'SKU-TP-UPD',
            'barcode': 'BC-TP-NEW',
            'track_inventory': 1,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Gelas',
          },
          {
            'id': 'item-teh-es',
            'product_id': 'prod-teh',
            'name': 'Teh Manis Es',
            'variant_combination': 'Es',
            'sku': 'SKU-TE',
            'barcode': 'BC-TE',
            'track_inventory': 0,
            'is_active': 1,
            'sellable': 1,
            'unit': 'Gelas',
          },
        ],
        'updated_prices': [
          {
            'id': 'price-teh-panas',
            'product_id': 'prod-teh',
            'product_item_id': 'item-teh-panas',
            'amount': 6000.0,
          },
          {
            'id': 'price-teh-es',
            'product_id': 'prod-teh',
            'product_item_id': 'item-teh-es',
            'amount': 7000.0,
          },
        ],
      };

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.syncDelta) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true, 'data': deltaPayload},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final deltaSyncService = DeltaSyncService(
        dioClient,
        db,
        prefs,
      );

      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T12:00:00Z'));

      // Check updated item
      final updatedItem = await (db.select(db.productItems)..where((t) => t.id.equals('item-teh-panas'))).getSingle();
      expect(updatedItem.name, 'Teh Manis Panas (Updated)');
      expect(updatedItem.sku, 'SKU-TP-UPD');
      expect(updatedItem.barcode, 'BC-TP-NEW');

      // Check new item
      final newItem = await (db.select(db.productItems)..where((t) => t.id.equals('item-teh-es'))).getSingle();
      expect(newItem.name, 'Teh Manis Es');
      expect(newItem.trackInventory, false);

      // Check prices
      final updatedPrice = await (db.select(db.productPrices)..where((t) => t.id.equals('price-teh-panas'))).getSingle();
      expect(updatedPrice.amount, 6000.0);

      // 3. Now test deleted_product_item_ids cascade
      dioClient.dio.interceptors.clear();
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.syncDelta) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': {
                      'synced_at': '2026-10-22T12:10:00Z',
                      'deleted_product_item_ids': ['item-teh-panas'],
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T12:05:00Z'));

      // Check item-teh-panas is deleted from productItems, pivot, prices, and inventories
      expect(
        await (db.select(db.productItems)..where((t) => t.id.equals('item-teh-panas'))).getSingleOrNull(),
        isNull,
      );
      expect(
        await (db.select(db.productItemVariantGroupOptions)..where((t) => t.productItemId.equals('item-teh-panas'))).getSingleOrNull(),
        isNull,
      );
      expect(
        await (db.select(db.productPrices)..where((t) => t.productItemId.equals('item-teh-panas'))).getSingleOrNull(),
        isNull,
      );
      expect(
        await (db.select(db.inventories)..where((t) => t.productItemId.equals('item-teh-panas'))).getSingleOrNull(),
        isNull,
      );

      // item-teh-es should remain
      expect(
        await (db.select(db.productItems)..where((t) => t.id.equals('item-teh-es'))).getSingleOrNull(),
        isNotNull,
      );
    });

    test('Delta sync handles deleted_product_ids cascade cleanly', () async {
      // Pre-seed a product with items and pivots
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-to-del',
              name: 'Produk Hapus',
              price: const Value(1000.0),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-del-1',
              productId: 'prod-to-del',
              name: 'Item Hapus 1',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'vg-del-1',
              productId: 'prod-to-del',
              name: 'Varian Hapus',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'vgo-del-1',
              variantGroupId: 'vg-del-1',
              name: 'Opsi Hapus',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-del-1',
              variantGroupOptionId: 'vgo-del-1',
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'price-del-1',
              productId: 'prod-to-del',
              productItemId: const Value('item-del-1'),
              amount: const Value(1000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-del-1',
              productId: 'prod-to-del',
              productItemId: const Value('item-del-1'),
              name: 'Inv Hapus 1',
            ),
          );

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.syncDelta) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': {
                      'synced_at': '2026-10-22T12:15:00Z',
                      'deleted_product_ids': ['prod-to-del'],
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final deltaSyncService = DeltaSyncService(
        dioClient,
        db,
        prefs,
      );

      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T12:10:00Z'));

      expect(
        await (db.select(db.products)..where((t) => t.id.equals('prod-to-del'))).getSingleOrNull(),
        isNull,
      );
      expect(
        await (db.select(db.productItems)..where((t) => t.productId.equals('prod-to-del'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(db.productPrices)..where((t) => t.productId.equals('prod-to-del'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(db.inventories)..where((t) => t.productId.equals('prod-to-del'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(db.productItemVariantGroupOptions)..where((t) => t.productItemId.equals('item-del-1'))).get(),
        isEmpty,
      );
    });
  });

  group('Drift Migration v9 to v11 Schema Integrity Test', () {
    test('Migration adds ProductItems, ProductItemVariantGroupOptions and new columns', () async {
      // Verify schema version is 12 (incremented for payment methods refactor)
      expect(db.schemaVersion, 12);

      // Verify we can insert into product_items table
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-migrated',
              name: 'Migrated Coffee',
              price: const Value(12000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              hasModifiers: const Value(true),
              hasRecipe: const Value(false),
              trackInventory: const Value(true),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-migrated-1',
              productId: 'prod-migrated',
              name: 'Migrated Coffee Item',
              variantCombination: const Value('Hot'),
              sku: const Value('SKU-MIG-1'),
              barcode: const Value('BC-MIG-1'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
              unit: const Value('Cup'),
            ),
          );

      final product = await (db.select(db.products)..where((t) => t.id.equals('prod-migrated'))).getSingle();
      expect(product.hasVariants, true);
      expect(product.hasModifiers, true);
      expect(product.hasRecipe, false);
      expect(product.trackInventory, true);

      final item = await (db.select(db.productItems)..where((t) => t.id.equals('item-migrated-1'))).getSingle();
      expect(item.id, 'item-migrated-1');
      expect(item.productId, 'prod-migrated');
      expect(item.variantCombination, 'Hot');
      expect(item.unit, 'Cup');
    });

    test('Simulated v9 to v11 onUpgrade creates missing tables, alters columns, and builds indexes', () async {
      final raw = raw_sqlite.sqlite3.openInMemory();
      raw.execute('PRAGMA user_version = 9;');
      raw.execute('''
        CREATE TABLE products (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          category_id TEXT,
          sku TEXT,
          barcode TEXT,
          price REAL NOT NULL DEFAULT 0.0,
          is_available INTEGER NOT NULL DEFAULT 1,
          product_type TEXT NOT NULL DEFAULT 'basic',
          unit TEXT NOT NULL DEFAULT 'Pcs'
        );
      ''');
      raw.execute('''
        CREATE TABLE inventories (
          id TEXT NOT NULL PRIMARY KEY,
          product_id TEXT NOT NULL,
          name TEXT NOT NULL,
          sku TEXT,
          barcode TEXT,
          track_inventory INTEGER NOT NULL DEFAULT 1,
          is_active INTEGER NOT NULL DEFAULT 1,
          stock REAL NOT NULL DEFAULT 0.0,
          unit TEXT NOT NULL DEFAULT 'Pcs'
        );
      ''');
      raw.execute('''
        CREATE TABLE product_prices (
          id TEXT NOT NULL PRIMARY KEY,
          product_id TEXT NOT NULL,
          inventory_item_id TEXT,
          amount REAL NOT NULL DEFAULT 0.0
        );
      ''');
      raw.execute('''
        CREATE TABLE transaction_items (
          id TEXT NOT NULL PRIMARY KEY,
          transaction_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          inventory_item_id TEXT,
          name TEXT NOT NULL,
          quantity REAL NOT NULL DEFAULT 1.0,
          price REAL NOT NULL DEFAULT 0.0,
          subtotal REAL NOT NULL DEFAULT 0.0
        );
      ''');
      raw.execute('''
        CREATE TABLE variant_groups (
          id TEXT NOT NULL PRIMARY KEY,
          product_id TEXT NOT NULL,
          name TEXT NOT NULL
        );
      ''');
      raw.execute('''
        CREATE TABLE variant_group_options (
          id TEXT NOT NULL PRIMARY KEY,
          variant_group_id TEXT NOT NULL,
          name TEXT NOT NULL
        );
      ''');
      raw.execute('''
        CREATE TABLE product_modifier_groups (
          id TEXT NOT NULL PRIMARY KEY,
          product_id TEXT NOT NULL,
          modifier_group_id TEXT NOT NULL
        );
      ''');
      raw.execute("INSERT INTO products (id, name, price) VALUES ('p-old', 'Old Product', 5000.0);");

      final appDb = AppDatabase.forTesting(NativeDatabase.opened(raw));

      // Trigger database open & migration by selecting
      final oldProduct = await (appDb.select(appDb.products)..where((t) => t.id.equals('p-old'))).getSingle();
      expect(oldProduct.name, 'Old Product');
      expect(oldProduct.hasVariants, false);

      // Verify product_items table was created by onUpgrade
      await appDb.into(appDb.productItems).insert(
        ProductItemsCompanion.insert(
          id: 'pi-new',
          productId: 'p-old',
          name: 'Old Product Default Item',
        ),
      );
      final newItem = await (appDb.select(appDb.productItems)..where((t) => t.id.equals('pi-new'))).getSingle();
      expect(newItem.name, 'Old Product Default Item');

      // Verify user_version is now 12 (latest database schemaVersion)
      final versionResult = await appDb.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.read<int>('user_version'), 12);

      await appDb.close();
    });
  });
}
