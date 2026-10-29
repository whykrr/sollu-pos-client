import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';

class TestCartItem {
  final String? productId;
  final String? productItemId;
  final String? inventoryItemId;
  final String name;
  final int qty;
  final bool? trackInventory;

  TestCartItem({
    this.productId,
    this.productItemId,
    this.inventoryItemId,
    required this.name,
    this.qty = 1,
    this.trackInventory,
  });
}

void main() {

  late AppDatabase db;
  late PosRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PosRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Empirical Challenge: Omni-Search Barcode Exact Match & Precedence', () {
    setUp(() async {
      // Product A with product-level barcode 'BAR-1000' and specific item barcode 'BAR-1001'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-a',
              name: 'Kemeja Katun',
              barcode: const Value('BAR-1000'),
              sku: const Value('SKU-PRD-A'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-a-red',
              productId: 'prod-a',
              name: 'Kemeja Katun - Merah',
              barcode: const Value('BAR-1001'),
              sku: const Value('SKU-A-RED'),
              variantCombination: const Value('Merah'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product B with product-level barcode 'BAR-1001' (identical to Item A barcode to test priority)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-b',
              name: 'Celana Chino',
              barcode: const Value('BAR-1001'),
              sku: const Value('SKU-PRD-B'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-b-default',
              productId: 'prod-b',
              name: 'Celana Chino Standar',
              barcode: const Value('BAR-2001'),
              sku: const Value('SKU-B-DEF'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product C (Inactive) with barcode 'BAR-INACTIVE'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-inactive',
              name: 'Produk Nonaktif',
              barcode: const Value('BAR-INACTIVE'),
              isAvailable: const Value(false),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-inactive',
              productId: 'prod-inactive',
              name: 'Produk Nonaktif',
              barcode: const Value('BAR-INACTIVE'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product D with inactive item
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-d',
              name: 'Produk Item Nonaktif',
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-d-nonactive',
              productId: 'prod-d',
              name: 'Item Nonaktif',
              barcode: const Value('BAR-ITEM-OFF'),
              isActive: const Value(false),
              sellable: const Value(true),
            ),
          );
    });

    test('Exact match on item barcode resolves to the item', () async {
      final item = await repository.findItemByBarcodeOrSku('BAR-1001');
      expect(item, isNotNull);
      // Item barcode has priority 1 over Product barcode priority 3
      expect(item!.id, 'item-a-red');
    });

    test('Exact match on product barcode resolves when item has distinct barcode', () async {
      final item = await repository.findItemByBarcodeOrSku('BAR-1000');
      expect(item, isNotNull);
      expect(item!.id, 'item-a-red');
    });

    test('Inactive product or item is NOT returned by barcode search', () async {
      final inactiveProductItem = await repository.findItemByBarcodeOrSku('BAR-INACTIVE');
      expect(inactiveProductItem, isNull);

      final inactiveItem = await repository.findItemByBarcodeOrSku('BAR-ITEM-OFF');
      expect(inactiveItem, isNull);
    });
  });

  group('Empirical Challenge: Omni-Search SKU Exact Match & Precedence', () {
    setUp(() async {
      // Product X with product SKU 'SKU-CONFLICT' and item X with 'SKU-ITEM-X'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-x',
              name: 'Kopi Robusta',
              sku: const Value('SKU-CONFLICT'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-x',
              productId: 'prod-x',
              name: 'Kopi Robusta 250g',
              sku: const Value('SKU-ITEM-X'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product Y where Item Y has sku 'SKU-CONFLICT'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-y',
              name: 'Kopi Arabika',
              sku: const Value('SKU-OTHER-Y'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-y',
              productId: 'prod-y',
              name: 'Kopi Arabika 250g',
              sku: const Value('SKU-CONFLICT'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
    });

    test('Exact match on item SKU resolves directly', () async {
      final item = await repository.findItemByBarcodeOrSku('SKU-ITEM-X');
      expect(item, isNotNull);
      expect(item!.id, 'item-x');
    });

    test('Exact match on item SKU has higher precedence than product SKU in collision', () async {
      // 'SKU-CONFLICT' matches item-y (item SKU, priority 2) and prod-x (product SKU, priority 4)
      final item = await repository.findItemByBarcodeOrSku('SKU-CONFLICT');
      expect(item, isNotNull);
      expect(item!.id, 'item-y');
    });

    test('Exact match on product SKU works when no item SKU collides', () async {
      final item = await repository.findItemByBarcodeOrSku('SKU-OTHER-Y');
      expect(item, isNotNull);
      expect(item!.id, 'item-y');
    });
  });

  group('Empirical Challenge: Variant Combination Partial Match (e.g. "Merah")', () {
    setUp(() async {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-shirt',
              name: 'Kaos Polos Cotton Combed',
              isAvailable: const Value(true),
            ),
          );

      // Item 1: Merah Cabe - XL
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-shirt-red-xl',
              productId: 'prod-shirt',
              name: 'Kaos Polos Cotton Combed - Merah Cabe - XL',
              variantCombination: const Value('Merah Cabe - XL'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Item 2: Biru Navy - L
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-shirt-blue-l',
              productId: 'prod-shirt',
              name: 'Kaos Polos Cotton Combed - Biru Navy - L',
              variantCombination: const Value('Biru Navy - L'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
    });

    test('Partial variant combination match for "Merah" returns the Merah item', () async {
      final item = await repository.findItemByBarcodeOrSku('Merah');
      expect(item, isNotNull);
      expect(item!.id, 'item-shirt-red-xl');
      expect(item.variantCombination, contains('Merah'));
    });

    test('Case-insensitive variant combination match for "merah" works in SQLite', () async {
      final item = await repository.findItemByBarcodeOrSku('merah');
      expect(item, isNotNull);
      expect(item!.id, 'item-shirt-red-xl');
    });

    test('Partial variant combination match for size "Navy" returns the Navy item', () async {
      final item = await repository.findItemByBarcodeOrSku('Navy');
      expect(item, isNotNull);
      expect(item!.id, 'item-shirt-blue-l');
    });
  });

  group('Empirical Challenge: Product Name Search & Whitespace Handling', () {
    setUp(() async {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-matcha',
              name: 'Matcha Latte Premium',
              isAvailable: const Value(true),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-matcha-reg',
              productId: 'prod-matcha',
              name: 'Matcha Latte Premium - Regular',
              variantCombination: const Value('Regular'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
    });

    test('Product name search matches through item name', () async {
      final item = await repository.findItemByBarcodeOrSku('Matcha Latte');
      expect(item, isNotNull);
      expect(item!.id, 'item-matcha-reg');
    });

    test('Query with leading and trailing whitespaces is trimmed and matches', () async {
      final item = await repository.findItemByBarcodeOrSku('   Matcha   ');
      expect(item, isNotNull);
      expect(item!.id, 'item-matcha-reg');
    });

    test('All-whitespace query returns null safely without throwing', () async {
      final item = await repository.findItemByBarcodeOrSku('    ');
      expect(item, isNull);
    });
  });

  group('Empirical Challenge: Aggregative Category Filter with Root and Sub-Categories', () {
    setUp(() async {
      // Hierarchy:
      // cat-root (Minuman & Kopi)
      //  ├── cat-child-coffee (Kopi Susu)
      //  └── cat-child-non-coffee (Non Kopi)
      // cat-other (Makanan Berat)

      await db.into(db.productCategories).insert(
            ProductCategoriesCompanion.insert(
              id: 'cat-root',
              name: 'Minuman & Kopi',
              sortOrder: const Value(1),
            ),
          );
      await db.into(db.productCategories).insert(
            ProductCategoriesCompanion.insert(
              id: 'cat-child-coffee',
              name: 'Kopi Susu',
              parentId: const Value('cat-root'),
              sortOrder: const Value(2),
            ),
          );
      await db.into(db.productCategories).insert(
            ProductCategoriesCompanion.insert(
              id: 'cat-child-non-coffee',
              name: 'Non Kopi',
              parentId: const Value('cat-root'),
              sortOrder: const Value(3),
            ),
          );
      await db.into(db.productCategories).insert(
            ProductCategoriesCompanion.insert(
              id: 'cat-other',
              name: 'Makanan Berat',
              sortOrder: const Value(4),
            ),
          );

      // Product 1: Directly under Root Category
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-root-water',
              name: 'Air Mineral Prima',
              categoryId: const Value('cat-root'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-water',
              productId: 'prod-root-water',
              name: 'Air Mineral Prima 600ml',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product 2: Under Child Category 1 (Kopi Susu)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-es-kopi',
              name: 'Es Kopi Kenangan Mantan',
              categoryId: const Value('cat-child-coffee'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-es-kopi',
              productId: 'prod-es-kopi',
              name: 'Es Kopi Kenangan Mantan - Regular',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product 3: Under Child Category 2 (Non Kopi)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-taro',
              name: 'Taro Milk Tea',
              categoryId: const Value('cat-child-non-coffee'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-taro',
              productId: 'prod-taro',
              name: 'Taro Milk Tea - Large',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product 4: Under Other Category (Makanan Berat)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-ayam',
              name: 'Ayam Geprek Sambal Korek',
              categoryId: const Value('cat-other'),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-ayam',
              productId: 'prod-ayam',
              name: 'Ayam Geprek Sambal Korek - Pedas',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
    });

    test('Selecting Root Category returns products of root AND all its sub-categories', () async {
      final items = await repository.watchItemsByCategory(categoryId: 'cat-root').first;
      final ids = items.map((e) => e.id).toSet();

      expect(ids.length, 3);
      expect(ids.contains('item-water'), isTrue, reason: 'Root product should be included');
      expect(ids.contains('item-es-kopi'), isTrue, reason: 'Child 1 product should be included');
      expect(ids.contains('item-taro'), isTrue, reason: 'Child 2 product should be included');
      expect(ids.contains('item-ayam'), isFalse, reason: 'Unrelated category product MUST NOT be included');
    });

    test('Selecting Child Category 1 returns ONLY its direct products', () async {
      final items = await repository.watchItemsByCategory(categoryId: 'cat-child-coffee').first;
      final ids = items.map((e) => e.id).toSet();

      expect(ids.length, 1);
      expect(ids.contains('item-es-kopi'), isTrue);
      expect(ids.contains('item-water'), isFalse);
      expect(ids.contains('item-taro'), isFalse);
      expect(ids.contains('item-ayam'), isFalse);
    });

    test('Selecting Child Category 2 returns ONLY its direct products', () async {
      final items = await repository.watchItemsByCategory(categoryId: 'cat-child-non-coffee').first;
      final ids = items.map((e) => e.id).toSet();

      expect(ids.length, 1);
      expect(ids.contains('item-taro'), isTrue);
      expect(ids.contains('item-es-kopi'), isFalse);
    });

    test('Selecting categoryId: null returns all active sellable items across all categories', () async {
      final items = await repository.watchItemsByCategory(categoryId: null).first;
      final ids = items.map((e) => e.id).toSet();

      expect(ids.length, 4);
      expect(ids, containsAll(['item-water', 'item-es-kopi', 'item-taro', 'item-ayam']));
    });

    test('findProductItemIdForVariants with exact option count matching', () async {
      // Setup product with 1-option item and 2-option item
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-tiered-var',
              name: 'Produk Varian Uji',
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-1opt',
              productId: 'prod-tiered-var',
              name: 'Produk 1 Option',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-2opt',
              productId: 'prod-tiered-var',
              name: 'Produk 2 Option',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-1opt',
              variantGroupOptionId: 'opt-x',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-2opt',
              variantGroupOptionId: 'opt-x',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-2opt',
              variantGroupOptionId: 'opt-y',
            ),
          );

      // If searching for ['opt-x', 'opt-y'], it MUST return item-2opt
      final twoOptResult = await repository.findProductItemIdForVariants('prod-tiered-var', ['opt-x', 'opt-y']);
      expect(twoOptResult, 'item-2opt');
    });

    test('Category with no products returns empty list gracefully', () async {
      await db.into(db.productCategories).insert(
            ProductCategoriesCompanion.insert(
              id: 'cat-empty',
              name: 'Kategori Kosong',
              sortOrder: const Value(99),
            ),
          );

      final items = await repository.watchItemsByCategory(categoryId: 'cat-empty').first;
      expect(items, isEmpty);
    });
  });

  group('Empirical Challenge: Decoupled Stock & Cart Stock Availability Check', () {
    test('checkCartStockAvailability never blocks items with trackInventory == false', () async {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-service',
              name: 'Jasa Pijat Relaksasi',
              isAvailable: const Value(true),
              trackInventory: const Value(false),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-service',
              productId: 'prod-service',
              name: 'Jasa Pijat Relaksasi - 1 Jam',
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Verify checking stock for 1000 items with trackInventory: false does NOT throw and returns no issues
      final issues = await repository.checkCartStockAvailability([
        TestCartItem(
          productId: 'prod-service',
          productItemId: 'item-service',
          qty: 1000,
          name: 'Jasa Pijat Relaksasi - 1 Jam',
          trackInventory: false,
        ),
      ]);

      expect(issues, isEmpty);
    });

    test('checkCartStockAvailability flags insufficient stock for items with trackInventory == true', () async {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-tracked',
              name: 'Snack Keripik',
              isAvailable: const Value(true),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-tracked',
              productId: 'prod-tracked',
              name: 'Snack Keripik Asin',
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-tracked',
              productId: 'prod-tracked',
              productItemId: const Value('item-tracked'),
              name: 'Snack Keripik Asin',
              trackInventory: const Value(true),
              isActive: const Value(true),
              stock: const Value(3.0),
            ),
          );

      // Check stock with quantity 10 exceeding stock 3.0
      final issues = await repository.checkCartStockAvailability([
        TestCartItem(
          productId: 'prod-tracked',
          productItemId: 'item-tracked',
          qty: 10,
          name: 'Snack Keripik Asin',
          trackInventory: true,
        ),
      ]);

      expect(issues.length, 1);
      expect(issues.first, 'Snack Keripik Asin');
    });
  });
}

