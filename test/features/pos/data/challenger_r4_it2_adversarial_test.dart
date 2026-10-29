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
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/data/sync/delta_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DioClient dioClient;
  late SharedPreferences prefs;
  late PosRepository repository;

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
    repository = PosRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Empirical Challenger 2 Adversarial Stress Suite', () {
    test('Adversarial 1: Multi-product batch deletion in DeltaSync cleanly purges pivots without affecting survivor products', () async {
      // Setup 3 products:
      // prod-1: Single item (no variant pivot)
      // prod-2: 2 items with 4 pivot entries (TO BE DELETED)
      // prod-3: 3 items with 6 pivot entries (TO BE DELETED)
      // prod-4: 2 items with 4 pivot entries (SURVIVOR CONTROL)

      // prod-1
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-1', name: 'Product 1', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-1', productId: 'prod-1', name: 'Product 1 Item', isActive: const Value(true), sellable: const Value(true)));

      // prod-2
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-2', name: 'Product 2', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-2a', productId: 'prod-2', name: 'Product 2 A', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-2b', productId: 'prod-2', name: 'Product 2 B', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2a', variantGroupOptionId: 'vgo-1'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2a', variantGroupOptionId: 'vgo-2'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2b', variantGroupOptionId: 'vgo-1'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2b', variantGroupOptionId: 'vgo-3'));

      // prod-3
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-3', name: 'Product 3', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-3a', productId: 'prod-3', name: 'Product 3 A', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-3b', productId: 'prod-3', name: 'Product 3 B', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-3c', productId: 'prod-3', name: 'Product 3 C', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3a', variantGroupOptionId: 'vgo-4'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3a', variantGroupOptionId: 'vgo-5'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3b', variantGroupOptionId: 'vgo-4'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3b', variantGroupOptionId: 'vgo-6'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3c', variantGroupOptionId: 'vgo-7'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3c', variantGroupOptionId: 'vgo-8'));

      // prod-4 (SURVIVOR)
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-4', name: 'Product 4 Survivor', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-4a', productId: 'prod-4', name: 'Product 4 A', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-4b', productId: 'prod-4', name: 'Product 4 B', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-4a', variantGroupOptionId: 'vgo-survivor-1'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-4a', variantGroupOptionId: 'vgo-survivor-2'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-4b', variantGroupOptionId: 'vgo-survivor-1'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-4b', variantGroupOptionId: 'vgo-survivor-3'));

      // Pre-deletion checks:
      final totalPivotsBefore = await db.select(db.productItemVariantGroupOptions).get();
      expect(totalPivotsBefore.length, 14); // 4 + 6 + 4

      // Mock delta sync response with deleted_product_ids: ['prod-2', 'prod-3']
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
                      'synced_at': '2026-10-22T14:00:00Z',
                      'deleted_product_ids': ['prod-2', 'prod-3'],
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final deltaSyncService = DeltaSyncService(dioClient, db, prefs);
      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T12:00:00Z'));

      // Verify prod-2 and prod-3 products deleted
      final prod2 = await (db.select(db.products)..where((t) => t.id.equals('prod-2'))).getSingleOrNull();
      final prod3 = await (db.select(db.products)..where((t) => t.id.equals('prod-3'))).getSingleOrNull();
      expect(prod2, isNull);
      expect(prod3, isNull);

      // Verify prod-2 and prod-3 items deleted
      final deletedItems = await (db.select(db.productItems)..where((t) => t.id.isIn(['item-2a', 'item-2b', 'item-3a', 'item-3b', 'item-3c']))).get();
      expect(deletedItems, isEmpty);

      // Verify associated pivots are completely removed
      final orphanPivots = await (db.select(db.productItemVariantGroupOptions)
            ..where((t) => t.productItemId.isIn(['item-2a', 'item-2b', 'item-3a', 'item-3b', 'item-3c'])))
          .get();
      expect(orphanPivots, isEmpty, reason: 'All pivot records of deleted products must be completely purged');

      // Verify SURVIVOR prod-1 and prod-4 remain completely intact
      final prod1 = await (db.select(db.products)..where((t) => t.id.equals('prod-1'))).getSingleOrNull();
      final prod4 = await (db.select(db.products)..where((t) => t.id.equals('prod-4'))).getSingleOrNull();
      expect(prod1, isNotNull);
      expect(prod4, isNotNull);

      final survivorItems = await (db.select(db.productItems)..where((t) => t.productId.equals('prod-4'))).get();
      expect(survivorItems.length, 2);

      final survivorPivots = await (db.select(db.productItemVariantGroupOptions)
            ..where((t) => t.productItemId.isIn(['item-4a', 'item-4b'])))
          .get();
      expect(survivorPivots.length, 4, reason: 'Survivor pivots must not be touched');
    });

    test('Adversarial 2: Granular item-level deletion via deleted_product_item_ids purges only targeted item pivot', () async {
      // Setup product with 2 items
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-multi', name: 'Product Multi', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-keep', productId: 'prod-multi', name: 'Keep Item', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-drop', productId: 'prod-multi', name: 'Drop Item', isActive: const Value(true), sellable: const Value(true)));

      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-keep', variantGroupOptionId: 'vgo-keep'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-drop', variantGroupOptionId: 'vgo-drop'));

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
                      'synced_at': '2026-10-22T14:00:00Z',
                      'deleted_product_item_ids': ['item-drop'],
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final deltaSyncService = DeltaSyncService(dioClient, db, prefs);
      await deltaSyncService.syncDeltaCatalog(since: DateTime.parse('2026-10-22T12:00:00Z'));

      // Product still exists
      final prod = await (db.select(db.products)..where((t) => t.id.equals('prod-multi'))).getSingleOrNull();
      expect(prod, isNotNull);

      // item-drop is gone, item-keep survives
      final itemDrop = await (db.select(db.productItems)..where((t) => t.id.equals('item-drop'))).getSingleOrNull();
      final itemKeep = await (db.select(db.productItems)..where((t) => t.id.equals('item-keep'))).getSingleOrNull();
      expect(itemDrop, isNull);
      expect(itemKeep, isNotNull);

      // Pivot for item-drop is gone, pivot for item-keep survives
      final dropPivot = await (db.select(db.productItemVariantGroupOptions)..where((t) => t.productItemId.equals('item-drop'))).get();
      final keepPivot = await (db.select(db.productItemVariantGroupOptions)..where((t) => t.productItemId.equals('item-keep'))).get();
      expect(dropPivot, isEmpty);
      expect(keepPivot.length, 1);
    });

    test('Adversarial 3: findProductItemIdForVariants complex multi-attribute resolution and strict boundary assertions', () async {
      // Setup product with 1-option, 2-option, and 3-option items
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-matrix', name: 'Product Matrix', isAvailable: const Value(true)));

      // Item 1 (1 option: Size=Large)
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-1opt', productId: 'prod-matrix', name: '1-Opt Large', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-1opt', variantGroupOptionId: 'opt-large'));

      // Item 2 (2 options: Size=Large, Temp=Hot)
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-2opt-hot', productId: 'prod-matrix', name: '2-Opt Large Hot', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2opt-hot', variantGroupOptionId: 'opt-large'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-2opt-hot', variantGroupOptionId: 'opt-hot'));

      // Item 3 (3 options: Size=Large, Temp=Ice, Sugar=Less)
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-3opt', productId: 'prod-matrix', name: '3-Opt Large Ice Less', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3opt', variantGroupOptionId: 'opt-large'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3opt', variantGroupOptionId: 'opt-ice'));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-3opt', variantGroupOptionId: 'opt-less'));

      // Item 4 from a DIFFERENT product sharing option IDs
      await db.into(db.products).insert(ProductsCompanion.insert(id: 'prod-foreign', name: 'Foreign Product', isAvailable: const Value(true)));
      await db.into(db.productItems).insert(ProductItemsCompanion.insert(id: 'item-foreign', productId: 'prod-foreign', name: 'Foreign Item', isActive: const Value(true), sellable: const Value(true)));
      await db.into(db.productItemVariantGroupOptions).insert(ProductItemVariantGroupOptionsCompanion.insert(productItemId: 'item-foreign', variantGroupOptionId: 'opt-large'));

      // Assertions:
      // a. Empty options -> null
      expect(await repository.findProductItemIdForVariants('prod-matrix', []), isNull);

      // b. Query ['opt-large'] -> must return item-1opt (NOT item-2opt-hot, NOT item-3opt, NOT item-foreign)
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-large']), 'item-1opt');

      // c. Query ['opt-large', 'opt-hot'] -> must return item-2opt-hot
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-large', 'opt-hot']), 'item-2opt-hot');

      // d. Query ['opt-large', 'opt-ice'] -> partial match for item-3opt (missing opt-less) -> must return null!
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-large', 'opt-ice']), isNull);

      // e. Query ['opt-large', 'opt-ice', 'opt-less'] -> exact match for item-3opt
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-large', 'opt-ice', 'opt-less']), 'item-3opt');

      // f. Query with non-existent option
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-non-existent']), isNull);

      // g. Query with superset (e.g. 4 options on a 3-option item) -> must return null
      expect(await repository.findProductItemIdForVariants('prod-matrix', ['opt-large', 'opt-ice', 'opt-less', 'opt-extra']), isNull);

      // h. Product scoping check: querying prod-foreign with ['opt-large'] returns item-foreign, not item-1opt
      expect(await repository.findProductItemIdForVariants('prod-foreign', ['opt-large']), 'item-foreign');
    });
  });
}
