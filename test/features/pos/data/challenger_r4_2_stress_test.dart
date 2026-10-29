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
    posRepository = PosRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Challenger Empirical Tests: Sync Pipeline & PosRepository', () {
    test('Empirical Test 1: DeltaSync deleted_product_ids must cascade delete product_item_variant_group_options', () async {
      // 1. Seed product with variant groups, options, items, and pivot
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-to-delete',
              name: 'Produk Hapus Uji',
              isAvailable: const Value(true),
            ),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'vg-test-1',
              productId: 'prod-to-delete',
              name: 'Ukuran',
            ),
          );

      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'vgo-test-1',
              variantGroupId: 'vg-test-1',
              name: 'Besar',
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-test-1',
              productId: 'prod-to-delete',
              name: 'Produk Hapus Uji - Besar',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-test-1',
              variantGroupOptionId: 'vgo-test-1',
            ),
          );

      // Verify row exists before delta sync
      final prePivots = await (db.select(db.productItemVariantGroupOptions)
            ..where((t) => t.productItemId.equals('item-test-1')))
          .get();
      expect(prePivots.length, 1);

      // 2. Perform Delta Sync with deleted_product_ids containing prod-to-delete
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
                      'synced_at': '2026-10-22T13:00:00Z',
                      'deleted_product_ids': ['prod-to-delete'],
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

      // 3. Verify that product and productItem are deleted
      final prodAfter = await (db.select(db.products)..where((t) => t.id.equals('prod-to-delete'))).getSingleOrNull();
      expect(prodAfter, isNull);

      final itemAfter = await (db.select(db.productItems)..where((t) => t.id.equals('item-test-1'))).getSingleOrNull();
      expect(itemAfter, isNull);

      // 4. Verify pivot table is NOT left with orphan rows
      final orphanPivots = await (db.select(db.productItemVariantGroupOptions)
            ..where((t) => t.productItemId.equals('item-test-1')))
          .get();
      expect(orphanPivots, isEmpty, reason: 'product_item_variant_group_options pivot rows must be cascade deleted when a product is deleted');
    });

    test('Empirical Test 2: findProductItemIdForVariants partial selection must NOT false-positive match multi-variant item', () async {
      // Setup product with ONLY a 2-variant option item (e.g. Size=Large AND Temp=Ice)
      // No 1-variant item exists.
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-coffee-combo',
              name: 'Kopi Kombo',
              isAvailable: const Value(true),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-combo-large-ice',
              productId: 'prod-coffee-combo',
              name: 'Kopi Kombo - Large Ice',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-combo-large-ice',
              variantGroupOptionId: 'opt-large',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-combo-large-ice',
              variantGroupOptionId: 'opt-ice',
            ),
          );

      // If user/dialog only selected ['opt-large'] (partial selection without Temp),
      // it MUST NOT resolve to item-combo-large-ice because opt-ice is NOT selected!
      final partialResult = await posRepository.findProductItemIdForVariants(
        'prod-coffee-combo',
        ['opt-large'],
      );

      expect(
        partialResult,
        isNull,
        reason: 'findProductItemIdForVariants should return null when only a subset of options is provided, but item requires all options',
      );
    });

    test('Empirical Test 3: findProductItemIdForVariants exact matching when single-option and multi-option items coexist', () async {
      // Coexistence: Item A has ['opt-large'], Item B has ['opt-large', 'opt-ice']
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-coexist',
              name: 'Produk Koeksistensi',
              isAvailable: const Value(true),
            ),
          );

      // Item B (2 options) inserted first
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-b-two-options',
              productId: 'prod-coexist',
              name: 'Item B (2 opts)',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-b-two-options',
              variantGroupOptionId: 'opt-large',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-b-two-options',
              variantGroupOptionId: 'opt-ice',
            ),
          );

      // Item A (1 option) inserted second
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-a-one-option',
              productId: 'prod-coexist',
              name: 'Item A (1 opt)',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-a-one-option',
              variantGroupOptionId: 'opt-large',
            ),
          );

      // When searching for ['opt-large'], it MUST resolve to 'item-a-one-option' and NEVER 'item-b-two-options'
      final resolved = await posRepository.findProductItemIdForVariants('prod-coexist', ['opt-large']);
      expect(
        resolved,
        'item-a-one-option',
        reason: 'Exact option count matching should return the 1-option item, not the 2-option item',
      );
    });
  });
}
