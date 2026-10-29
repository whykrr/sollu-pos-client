import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/outlet_settings_service.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/sync/delta_sync_service.dart';
import 'package:sollu_pos_client/features/pos/data/sync/initial_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DioClient dioClient;
  late SharedPreferences prefs;
  late OutletSettingsService outletSettingsService;

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
  });

  tearDown(() async {
    await db.close();
  });

  group('Sync Pipeline Ingestion Tests (ProductItems & Pivot)', () {
    test('InitialSyncService ingests product_items and product_item_variant_group_options', () async {
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.syncInitial) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'data': {
                      'synced_at': '2026-10-22T10:00:00Z',
                      'products': [
                        {
                          'id': 'prod-kopi',
                          'name': 'Kopi Tubruk',
                          'product_category_id': 'cat-1',
                          'sku': 'PRD-KOP',
                          'barcode': '123456',
                          'price': 10000,
                          'is_show': 1,
                          'product_type': 'basic',
                          'unit': 'Cangkir',
                          'has_variant': 1,
                          'track_inventory': 1,
                        }
                      ],
                      'variant_groups': [
                        {
                          'id': 'grp-manis',
                          'product_id': 'prod-kopi',
                          'name': 'Kemanisan',
                        }
                      ],
                      'variant_group_options': [
                        {
                          'id': 'opt-manis',
                          'variant_group_id': 'grp-manis',
                          'name': 'Manis',
                        }
                      ],
                      'product_items': [
                        {
                          'id': 'item-kopi-manis',
                          'product_id': 'prod-kopi',
                          'name': 'Kopi Tubruk - Manis',
                          'variant_combination': 'Manis',
                          'sku': 'SKU-KOP-MNS',
                          'barcode': '123456-MNS',
                          'track_inventory': 1,
                          'is_active': 1,
                          'sellable': 1,
                          'unit': 'Cangkir',
                        }
                      ],
                      'product_item_variant_group_options': [
                        {
                          'product_item_id': 'item-kopi-manis',
                          'variant_group_option_id': 'opt-manis',
                        }
                      ],
                      'inventory_items': [
                        {
                          'id': 'inv-kopi-manis',
                          'product_id': 'prod-kopi',
                          'product_item_id': 'item-kopi-manis',
                          'name': 'Kopi Tubruk - Manis',
                          'sku': 'SKU-KOP-MNS',
                          'barcode': '123456-MNS',
                          'track_inventory': 1,
                          'is_active': 1,
                          'unit': 'Cangkir',
                        }
                      ],
                      'inventory_balances': [
                        {
                          'inventory_item_id': 'inv-kopi-manis',
                          'current_stock': 50.0,
                        }
                      ],
                      'product_prices': [
                        {
                          'id': 'price-kopi-manis',
                          'product_id': 'prod-kopi',
                          'product_item_id': 'item-kopi-manis',
                          'amount': 10000.0,
                        }
                      ],
                    },
                  },
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

      final syncedAt = await initialSyncService.syncInitialSnapshot();
      expect(syncedAt, isNotNull);

      // Verify Product
      final products = await db.select(db.products).get();
      expect(products.length, 1);
      expect(products.first.hasVariants, true);
      expect(products.first.trackInventory, true);

      // Verify ProductItem
      final items = await db.select(db.productItems).get();
      expect(items.length, 1);
      expect(items.first.id, 'item-kopi-manis');
      expect(items.first.variantCombination, 'Manis');
      expect(items.first.sku, 'SKU-KOP-MNS');
      expect(items.first.barcode, '123456-MNS');
      expect(items.first.sellable, true);

      // Verify Pivot
      final pivots = await db.select(db.productItemVariantGroupOptions).get();
      expect(pivots.length, 1);
      expect(pivots.first.productItemId, 'item-kopi-manis');
      expect(pivots.first.variantGroupOptionId, 'opt-manis');

      // Verify Inventory has productItemId
      final inventories = await db.select(db.inventories).get();
      expect(inventories.length, 1);
      expect(inventories.first.productItemId, 'item-kopi-manis');
      expect(inventories.first.stock, 50.0);

      // Verify ProductPrice has productItemId
      final prices = await db.select(db.productPrices).get();
      expect(prices.length, 1);
      expect(prices.first.productItemId, 'item-kopi-manis');
      expect(prices.first.amount, 10000.0);
    });

    test('DeltaSyncService upserts updated_product_items and deletes deleted_product_item_ids', () async {
      // Pre-seed database with an item to delete and an item to update
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-delta-1',
              name: 'Teh Hijau',
              price: const Value(8000.0),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-to-delete',
              productId: 'prod-delta-1',
              name: 'Teh Hijau Panas',
              isActive: const Value(true),
              sellable: const Value(true),
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
                      'synced_at': '2026-10-22T10:15:00Z',
                      'deleted_product_item_ids': ['item-to-delete'],
                      'updated_product_items': [
                        {
                          'id': 'item-new-delta',
                          'product_id': 'prod-delta-1',
                          'name': 'Teh Hijau Dingin',
                          'variant_combination': 'Dingin',
                          'sku': 'SKU-TH-DGN',
                          'barcode': '7770001',
                          'track_inventory': 0,
                          'is_active': 1,
                          'sellable': 1,
                          'unit': 'Gelas',
                        }
                      ],
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

      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T10:00:00Z'));

      // Check item-to-delete is deleted
      final deletedItem = await (db.select(db.productItems)..where((t) => t.id.equals('item-to-delete'))).getSingleOrNull();
      expect(deletedItem, isNull);

      // Check item-new-delta was inserted
      final newItem = await (db.select(db.productItems)..where((t) => t.id.equals('item-new-delta'))).getSingleOrNull();
      expect(newItem, isNotNull);
      expect(newItem!.name, 'Teh Hijau Dingin');
      expect(newItem.variantCombination, 'Dingin');
      expect(newItem.barcode, '7770001');
    });
  });
}
