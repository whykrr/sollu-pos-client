import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/product_grid.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/variant_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PosRepository posRepo;
  late DioClient dioClient;
  late TransactionRepository txRepo;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({'pos_display_mode': 'product'});
    sharedPreferences = await SharedPreferences.getInstance();

    db = AppDatabase.forTesting(NativeDatabase.memory());
    posRepo = PosRepository(db);
    dioClient = DioClient(SecureStorageService());
    txRepo = TransactionRepository(db, dioClient);
  });

  tearDown(() async {
    await db.close();
  });

  group('Decoupled Stock UI Empirical Tests (Stok: ∞)', () {
    testWidgets('ProductGrid displays Stok: ∞ and infinity glyph for untracked product with 0 stock', (tester) async {
      final untrackedItem = PosItem(
        id: 'prod-digital-card',
        name: 'Voucher E-Book Belajar',
        price: 75000.0,
        stock: 0.0, // Stock is 0, but untracked!
        unit: 'Pcs',
        isActive: true,
        isProductMode: true,
        trackInventory: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            filteredPosItemsProvider.overrideWithValue(AsyncValue.data([untrackedItem])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProductGrid(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Stok: ∞ badge text is rendered in the grid card
      expect(find.text('Stok: ∞'), findsOneWidget);
      // Verify infinity glyph icon is rendered
      expect(find.byIcon(Icons.all_inclusive_rounded), findsOneWidget);
    });

    testWidgets('VariantDialog dynamic stock badge switches to Stok: ∞ when selecting untracked variant', (tester) async {
      // Setup product with 2 variants: Small (tracked, stock 5) vs Large (untracked, stock 0)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-matcha',
              name: 'Matcha Latte',
              price: const Value(22000.0),
              unit: const Value('Cup'),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-size-m',
              productId: 'prod-matcha',
              name: 'Ukuran',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-small',
              variantGroupId: 'grp-size-m',
              name: 'Small',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-large',
              variantGroupId: 'grp-size-m',
              name: 'Large',
            ),
          );

      // Small: Tracked, stock = 5
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-matcha-sml',
              productId: 'prod-matcha',
              name: 'Matcha Latte - Small',
              variantCombination: const Value('Small'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-m-1',
              productId: 'prod-matcha',
              productItemId: const Value('pi-matcha-sml'),
              amount: const Value(22000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-m-1',
              productId: 'prod-matcha',
              productItemId: const Value('pi-matcha-sml'),
              name: 'Matcha Latte - Small',
              stock: const Value(5.0),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-matcha-sml',
              variantGroupOptionId: 'opt-small',
            ),
          );

      // Large: Untracked (trackInventory: false), no inventory row
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-matcha-lrg',
              productId: 'prod-matcha',
              name: 'Matcha Latte - Large',
              variantCombination: const Value('Large'),
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-m-2',
              productId: 'prod-matcha',
              productItemId: const Value('pi-matcha-lrg'),
              amount: const Value(28000.0),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-matcha-lrg',
              variantGroupOptionId: 'opt-large',
            ),
          );

      final posItem = PosItem(
        id: 'prod-matcha',
        name: 'Matcha Latte',
        price: 22000.0,
        stock: 5.0,
        unit: 'Cup',
        isActive: true,
        hasVariants: true,
        isProductMode: true,
        trackInventory: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            databaseProvider.overrideWithValue(db),
            posRepositoryProvider.overrideWithValue(posRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => VariantDialog.show(context, posItem),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Initially Small is selected -> Tracked, stock 5
      expect(find.text('Stok: 5 Pcs'), findsOneWidget);
      expect(find.text('Stok: ∞'), findsNothing);

      // Switch to Large (Untracked)
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      // Now badge should dynamically change to Stok: ∞
      expect(find.text('Stok: ∞'), findsOneWidget);
      expect(find.text('Stok: 5 Cup'), findsNothing);

      // Tambah button must be enabled
      final tambahBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Tambah'));
      expect(tambahBtn.onPressed, isNotNull);
    });
  });

  group('Checkout Transaction Persistence & Untracked Inventory Bypass Tests', () {
    test('creates transaction with mixed items: decrements tracked items, skips untracked, writes all productItemIds', () async {
      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
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

      // 1. Single Untracked item (trackInventory: false)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-service-massage',
              name: 'Pijat Refleksi 60m',
              price: const Value(80000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(false),
              trackInventory: const Value(false),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-service-massage-def',
              productId: 'prod-service-massage',
              name: 'Pijat Refleksi 60m',
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // 2. Tracked Single item (trackInventory: true, stock: 50)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-snack-chips',
              name: 'Keripik Singkong Balado',
              price: const Value(15000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(false),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-snack-chips-def',
              productId: 'prod-snack-chips',
              name: 'Keripik Singkong Balado',
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-chips',
              productId: 'prod-snack-chips',
              productItemId: const Value('pi-snack-chips-def'),
              name: 'Keripik Singkong Balado',
              stock: const Value(50.0),
              trackInventory: const Value(true),
            ),
          );

      // 3. Variant Tracked item (trackInventory: true, stock: 20)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-tea',
              name: 'Teh Tarik',
              price: const Value(12000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-tea-iced',
              productId: 'prod-tea',
              name: 'Teh Tarik - Dingin',
              variantCombination: const Value('Dingin'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-tea-iced',
              productId: 'prod-tea',
              productItemId: const Value('pi-tea-iced'),
              name: 'Teh Tarik - Dingin',
              stock: const Value(20.0),
              trackInventory: const Value(true),
            ),
          );

      // Cart Items:
      // - 2x Untracked Massage (80k each = 160k)
      // - 5x Tracked Chips (15k each = 75k)
      // - 3x Tracked Iced Tea (12k each = 36k)
      final cartItems = [
        CartItem(
          id: 'c-1',
          productId: 'prod-service-massage',
          productItemId: 'pi-service-massage-def',
          name: 'Pijat Refleksi 60m',
          price: 80000.0,
          qty: 2,
          trackInventory: false,
        ),
        CartItem(
          id: 'c-2',
          productId: 'prod-snack-chips',
          productItemId: 'pi-snack-chips-def',
          inventoryItemId: 'inv-chips',
          name: 'Keripik Singkong Balado',
          price: 15000.0,
          qty: 5,
          trackInventory: true,
        ),
        // Item with NO productItemId upfront (testing resolution fallback)
        CartItem(
          id: 'c-3',
          productId: 'prod-tea',
          productItemId: null, // Test resolution!
          inventoryItemId: 'inv-tea-iced',
          name: 'Teh Tarik - Dingin',
          price: 12000.0,
          qty: 3,
          trackInventory: true,
        ),
      ];

      const paymentMethod = PaymentMethod(
        id: 'pm-qris',
        name: 'QRIS',
        type: 'qris',
        referencePolicy: 'optional',
        openCashDrawer: false,
        isSystem: false,
        isActive: true,
      );

      final result = await txRepo.createTransaction(
        items: cartItems,
        subtotal: 271000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 271000.0,
        paymentMethod: paymentMethod,
        cashReceived: 271000.0,
        changeAmount: 0.0,
      );

      expect(result.transaction, isNotNull);
      final txId = result.transaction.id;

      // Drain pending queue sync before closing DB
      await txRepo.syncPendingTransactions();

      // Verify SQLite transaction_items table
      final itemsInDb = await (db.select(db.transactionItems)
            ..where((t) => t.transactionId.equals(txId)))
          .get();
      expect(itemsInDb.length, 3);

      final dbUntracked = itemsInDb.firstWhere((i) => i.productId == 'prod-service-massage');
      expect(dbUntracked.productItemId, 'pi-service-massage-def');
      expect(dbUntracked.qty, 2.0);

      final dbChips = itemsInDb.firstWhere((i) => i.productId == 'prod-snack-chips');
      expect(dbChips.productItemId, 'pi-snack-chips-def');
      expect(dbChips.qty, 5.0);

      final dbTea = itemsInDb.firstWhere((i) => i.productId == 'prod-tea');
      // Resolved via fallback in transaction_repository!
      expect(dbTea.productItemId, 'pi-tea-iced');
      expect(dbTea.qty, 3.0);

      // Verify local inventories stock decrements:
      // Chips: was 50 - 5 = 45
      final chipsInv = await (db.select(db.inventories)..where((i) => i.id.equals('inv-chips'))).getSingle();
      expect(chipsInv.stock, 45.0);

      // Tea: was 20 - 3 = 17
      final teaInv = await (db.select(db.inventories)..where((i) => i.id.equals('inv-tea-iced'))).getSingle();
      expect(teaInv.stock, 17.0);

      // Massage: NO inventory row was created or touched, no throw
      final untrackedInvs = await (db.select(db.inventories)..where((i) => i.productId.equals('prod-service-massage'))).get();
      expect(untrackedInvs, isEmpty);
    });
  });

  group('Barcode Omni-Search Scanning Empirical Tests', () {
    setUp(() async {
      // Product 1: Multi-variant parent with barcode "PARENT-111"
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-bakso',
              name: 'Bakso Special',
              price: const Value(25000.0),
              barcode: const Value('PARENT-111'),
              sku: const Value('SKU-BAKSO-PARENT'),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      // Variant 1: Bakso Urat (Barcode "VAR-URAT-222")
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-bakso-urat',
              productId: 'prod-bakso',
              name: 'Bakso Special - Urat',
              variantCombination: const Value('Urat'),
              barcode: const Value('VAR-URAT-222'),
              sku: const Value('SKU-BAKSO-URAT'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-bk-1',
              productId: 'prod-bakso',
              productItemId: const Value('pi-bakso-urat'),
              amount: const Value(28000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-bk-urat',
              productId: 'prod-bakso',
              productItemId: const Value('pi-bakso-urat'),
              name: 'Bakso Special - Urat',
              stock: const Value(15.0),
              trackInventory: const Value(true),
            ),
          );

      // Variant 2: Bakso Halus (Barcode "VAR-HALUS-333")
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-bakso-halus',
              productId: 'prod-bakso',
              name: 'Bakso Special - Halus',
              variantCombination: const Value('Halus'),
              barcode: const Value('VAR-HALUS-333'),
              sku: const Value('SKU-BAKSO-HALUS'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-bk-2',
              productId: 'prod-bakso',
              productItemId: const Value('pi-bakso-halus'),
              amount: const Value(25000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-bk-halus',
              productId: 'prod-bakso',
              productItemId: const Value('pi-bakso-halus'),
              name: 'Bakso Special - Halus',
              stock: const Value(20.0),
              trackInventory: const Value(true),
            ),
          );

      // Product 2: Single product without variants (Barcode "SINGLE-444")
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-es-teh',
              name: 'Es Teh Manis',
              price: const Value(5000.0),
              barcode: const Value('SINGLE-444'),
              sku: const Value('SKU-ES-TEH'),
              isAvailable: const Value(true),
              hasVariants: const Value(false),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-es-teh-def',
              productId: 'prod-es-teh',
              name: 'Es Teh Manis',
              barcode: const Value('SINGLE-444'),
              sku: const Value('SKU-ES-TEH'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-et-1',
              productId: 'prod-es-teh',
              productItemId: const Value('pi-es-teh-def'),
              amount: const Value(5000.0),
            ),
          );
    });

    test('scanning parent product barcode returns parent product data and hasVariants=true', () async {
      final query = 'PARENT-111';
      final matchedItem = await posRepo.findItemByBarcodeOrSku(query);

      expect(matchedItem, isNotNull);
      expect(matchedItem!.hasVariants, isTrue);
      expect(matchedItem.product?.id, 'prod-bakso');
      expect(matchedItem.product?.name, 'Bakso Special');
      expect(matchedItem.product?.barcode, 'PARENT-111');

      // Check differentiation logic in pos_layout.dart:
      final isVariantBarcode = matchedItem.barcode == query || matchedItem.sku == query;
      final isParentScan = matchedItem.hasVariants && !isVariantBarcode;

      // Must evaluate to true parent scan -> triggers VariantDialog!
      expect(isVariantBarcode, isFalse);
      expect(isParentScan, isTrue);
    });

    test('scanning specific variant barcode returns exact productItemId and bypasses VariantDialog directly to cart', () async {
      final query = 'VAR-URAT-222';
      final matchedItem = await posRepo.findItemByBarcodeOrSku(query);

      expect(matchedItem, isNotNull);
      expect(matchedItem!.productItemId, 'pi-bakso-urat');
      expect(matchedItem.variantCombination, 'Urat');
      expect(matchedItem.price, 28000.0);
      expect(matchedItem.barcode, 'VAR-URAT-222');

      // Check differentiation logic in pos_layout.dart:
      final isVariantBarcode = matchedItem.barcode == query || matchedItem.sku == query;
      final isParentScan = matchedItem.hasVariants && !isVariantBarcode;

      // Must evaluate to variant scan -> directly added to cart!
      expect(isVariantBarcode, isTrue);
      expect(isParentScan, isFalse);
    });

    test('scanning single product barcode resolves directly to cart', () async {
      final query = 'SINGLE-444';
      final matchedItem = await posRepo.findItemByBarcodeOrSku(query);

      expect(matchedItem, isNotNull);
      expect(matchedItem!.hasVariants, isFalse);
      expect(matchedItem.productItemId, 'pi-es-teh-def');
      expect(matchedItem.price, 5000.0);

      final isVariantBarcode = matchedItem.barcode == query || matchedItem.sku == query;
      final isParentScan = matchedItem.hasVariants && !isVariantBarcode;

      // Single product is NOT a parent scan
      expect(isParentScan, isFalse);
    });

    test('scanning with whitespace is trimmed and still resolves correctly', () async {
      final matchedItem = await posRepo.findItemByBarcodeOrSku('  VAR-HALUS-333 \n ');
      expect(matchedItem, isNotNull);
      expect(matchedItem!.productItemId, 'pi-bakso-halus');
      expect(matchedItem.variantCombination, 'Halus');
    });

    test('scanning non-existent barcode returns null', () async {
      final matchedItem = await posRepo.findItemByBarcodeOrSku('UNKNOWN-99999');
      expect(matchedItem, isNull);
    });
  });
}
