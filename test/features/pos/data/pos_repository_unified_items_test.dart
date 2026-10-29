import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';

void main() {
  late AppDatabase db;
  late PosRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PosRepository(db);

    // Setup basic categories (Parent and Child)
    await db.into(db.productCategories).insert(
          ProductCategoriesCompanion.insert(
            id: 'cat-beverages',
            name: 'Minuman',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.productCategories).insert(
          ProductCategoriesCompanion.insert(
            id: 'cat-coffee',
            name: 'Kopi',
            parentId: const Value('cat-beverages'),
            sortOrder: const Value(2),
          ),
        );
    await db.into(db.productCategories).insert(
          ProductCategoriesCompanion.insert(
            id: 'cat-food',
            name: 'Makanan',
            sortOrder: const Value(3),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('PosRepository Unified Item Pattern & watchVariantModeItems Tests', () {
    test('Queries single product and variant products from ProductItems cleanly', () async {
      // 1. Single Product with 1 default ProductItem and no inventory (track_inventory = false)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-single-1',
              name: 'Jasa Desain',
              categoryId: const Value('cat-beverages'),
              price: const Value(50000.0),
              isAvailable: const Value(true),
              productType: const Value('service'),
              unit: const Value('Sesi'),
              hasVariants: const Value(false),
              trackInventory: const Value(false),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-single-1',
              productId: 'prod-single-1',
              name: 'Jasa Desain',
              variantCombination: const Value(null),
              sku: const Value('SKU-SRV-01'),
              barcode: const Value('8880001'),
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
              unit: const Value('Sesi'),
            ),
          );

      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'price-1',
              productId: 'prod-single-1',
              productItemId: const Value('item-single-1'),
              amount: const Value(50000.0),
            ),
          );

      // 2. Variant Product with 2 ProductItems and inventory tracking
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-variant-1',
              name: 'Kopi Susu Gula Aren',
              categoryId: const Value('cat-coffee'),
              price: const Value(18000.0),
              isAvailable: const Value(true),
              productType: const Value('basic'),
              unit: const Value('Cup'),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      // Variant Item Regular
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-var-reg',
              productId: 'prod-variant-1',
              name: 'Kopi Susu Gula Aren - Regular',
              variantCombination: const Value('Regular'),
              sku: const Value('SKU-KOP-REG'),
              barcode: const Value('8880002'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
              unit: const Value('Cup'),
            ),
          );

      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-item-reg',
              productId: 'prod-variant-1',
              productItemId: const Value('item-var-reg'),
              name: 'Kopi Susu Gula Aren - Regular',
              sku: const Value('SKU-KOP-REG'),
              barcode: const Value('8880002'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              stock: const Value(25.0),
              unit: const Value('Cup'),
            ),
          );

      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'price-var-reg',
              productId: 'prod-variant-1',
              productItemId: const Value('item-var-reg'),
              amount: const Value(18000.0),
            ),
          );

      // Variant Item Large
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-var-lrg',
              productId: 'prod-variant-1',
              name: 'Kopi Susu Gula Aren - Large',
              variantCombination: const Value('Large'),
              sku: const Value('SKU-KOP-LRG'),
              barcode: const Value('8880003'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
              unit: const Value('Cup'),
            ),
          );

      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-item-lrg',
              productId: 'prod-variant-1',
              productItemId: const Value('item-var-lrg'),
              name: 'Kopi Susu Gula Aren - Large',
              sku: const Value('SKU-KOP-LRG'),
              barcode: const Value('8880003'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              stock: const Value(12.0),
              unit: const Value('Cup'),
            ),
          );

      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'price-var-lrg',
              productId: 'prod-variant-1',
              productItemId: const Value('item-var-lrg'),
              amount: const Value(23000.0),
            ),
          );

      // Stream watchVariantModeItems
      final items = await repository.watchVariantModeItems().first;

      expect(items.length, 3);

      // Check single product item without inventory
      final singleItem = items.firstWhere((i) => i.id == 'item-single-1');
      expect(singleItem.name, 'Jasa Desain');
      expect(singleItem.price, 50000.0);
      expect(singleItem.stock, 0.0);
      expect(singleItem.trackInventory, false);
      expect(singleItem.isService, true);

      // Check variant items with decoupled inventories
      final regItem = items.firstWhere((i) => i.id == 'item-var-reg');
      expect(regItem.name, 'Kopi Susu Gula Aren - Regular');
      expect(regItem.price, 18000.0);
      expect(regItem.stock, 25.0);
      expect(regItem.trackInventory, true);
      expect(regItem.variantCombination, 'Regular');

      final lrgItem = items.firstWhere((i) => i.id == 'item-var-lrg');
      expect(lrgItem.name, 'Kopi Susu Gula Aren - Large');
      expect(lrgItem.price, 23000.0);
      expect(lrgItem.stock, 12.0);
      expect(lrgItem.trackInventory, true);
      expect(lrgItem.variantCombination, 'Large');
    });
  });

  group('PosRepository Instant Multi-Key Omni-Search Tests', () {
    setUp(() async {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-snack',
              name: 'Keripik Tempe Renyah',
              categoryId: const Value('cat-food'),
              sku: const Value('PRD-TEMPE'),
              barcode: const Value('999111000'),
              price: const Value(15000.0),
              isAvailable: const Value(true),
              productType: const Value('basic'),
              unit: const Value('Bks'),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-tempe-pedas',
              productId: 'prod-snack',
              name: 'Keripik Tempe Renyah - Pedas Daun Jeruk',
              variantCombination: const Value('Pedas Daun Jeruk'),
              sku: const Value('SKU-TMP-PDS'),
              barcode: const Value('999111001'),
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
              unit: const Value('Bks'),
            ),
          );
    });

    test('findItemByBarcodeOrSku matches by item barcode', () async {
      final item = await repository.findItemByBarcodeOrSku('999111001');
      expect(item, isNotNull);
      expect(item!.id, 'item-tempe-pedas');
      expect(item.name, contains('Pedas Daun Jeruk'));
    });

    test('findItemByBarcodeOrSku matches by item SKU', () async {
      final item = await repository.findItemByBarcodeOrSku('SKU-TMP-PDS');
      expect(item, isNotNull);
      expect(item!.id, 'item-tempe-pedas');
    });

    test('findItemByBarcodeOrSku matches by product barcode', () async {
      final item = await repository.findItemByBarcodeOrSku('999111000');
      expect(item, isNotNull);
      expect(item!.id, 'item-tempe-pedas');
    });

    test('findItemByBarcodeOrSku matches by product SKU', () async {
      final item = await repository.findItemByBarcodeOrSku('PRD-TEMPE');
      expect(item, isNotNull);
      expect(item!.id, 'item-tempe-pedas');
    });

    test('findItemByBarcodeOrSku matches by partial name or variant combination', () async {
      final itemByName = await repository.findItemByBarcodeOrSku('Keripik Tempe');
      expect(itemByName, isNotNull);
      expect(itemByName!.id, 'item-tempe-pedas');

      final itemByVariant = await repository.findItemByBarcodeOrSku('Daun Jeruk');
      expect(itemByVariant, isNotNull);
      expect(itemByVariant!.id, 'item-tempe-pedas');
    });

    test('findItemByBarcodeOrSku returns null for nonexistent search', () async {
      final item = await repository.findItemByBarcodeOrSku('NON-EXISTENT-SKU');
      expect(item, isNull);
    });
  });

  group('PosRepository Multi-Attribute Variant Matcher Tests', () {
    setUp(() async {
      // Setup product with 2 variant groups: Ukuran (Reg, Lrg) & Suhu (Hot, Ice)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-latte',
              name: 'Caffe Latte',
              categoryId: const Value('cat-coffee'),
              price: const Value(20000.0),
              isAvailable: const Value(true),
              productType: const Value('basic'),
              hasVariants: const Value(true),
            ),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-size',
              productId: 'prod-latte',
              name: 'Ukuran',
            ),
          );
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-temp',
              productId: 'prod-latte',
              name: 'Suhu',
            ),
          );

      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-reg',
              variantGroupId: 'grp-size',
              name: 'Regular',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-lrg',
              variantGroupId: 'grp-size',
              name: 'Large',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-hot',
              variantGroupId: 'grp-temp',
              name: 'Hot',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-ice',
              variantGroupId: 'grp-temp',
              name: 'Ice',
            ),
          );

      // ProductItem: Regular Hot
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-latte-reg-hot',
              productId: 'prod-latte',
              name: 'Caffe Latte - Regular - Hot',
              variantCombination: const Value('Regular - Hot'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-latte-reg-hot',
              variantGroupOptionId: 'opt-reg',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-latte-reg-hot',
              variantGroupOptionId: 'opt-hot',
            ),
          );

      // ProductItem: Large Ice
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-latte-lrg-ice',
              productId: 'prod-latte',
              name: 'Caffe Latte - Large - Ice',
              variantCombination: const Value('Large - Ice'),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-latte-lrg-ice',
              variantGroupOptionId: 'opt-lrg',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'item-latte-lrg-ice',
              variantGroupOptionId: 'opt-ice',
            ),
          );
    });

    test('findProductItemIdForVariants matches exact combination of 2 options', () async {
      final regHotId = await repository.findProductItemIdForVariants(
        'prod-latte',
        ['opt-reg', 'opt-hot'],
      );
      expect(regHotId, 'item-latte-reg-hot');

      final lrgIceId = await repository.findProductItemIdForVariants(
        'prod-latte',
        ['opt-lrg', 'opt-ice'],
      );
      expect(lrgIceId, 'item-latte-lrg-ice');
    });

    test('findProductItemIdForVariants returns null for unmatched combination', () async {
      // Large + Hot was not registered
      final lrgHotId = await repository.findProductItemIdForVariants(
        'prod-latte',
        ['opt-lrg', 'opt-hot'],
      );
      expect(lrgHotId, isNull);
    });
  });

  group('PosRepository Aggregative Category Filter Tests', () {
    setUp(() async {
      // Product under parent category 'cat-beverages'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-tea',
              name: 'Teh Manis Hangat',
              categoryId: const Value('cat-beverages'),
              price: const Value(5000.0),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-tea',
              productId: 'prod-tea',
              name: 'Teh Manis Hangat',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product under child category 'cat-coffee' (parent: 'cat-beverages')
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-espresso',
              name: 'Single Espresso',
              categoryId: const Value('cat-coffee'),
              price: const Value(12000.0),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-espresso',
              productId: 'prod-espresso',
              name: 'Single Espresso',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      // Product under unrelated category 'cat-food'
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-rice',
              name: 'Nasi Goreng Spesial',
              categoryId: const Value('cat-food'),
              price: const Value(25000.0),
              isAvailable: const Value(true),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'item-rice',
              productId: 'prod-rice',
              name: 'Nasi Goreng Spesial',
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
    });

    test('watchItemsByCategory with parent category returns parent AND child products', () async {
      // Selecting 'cat-beverages' should return both Teh Manis Hangat and Single Espresso
      final items = await repository.watchItemsByCategory(categoryId: 'cat-beverages').first;
      final itemIds = items.map((i) => i.id).toList();

      expect(itemIds, contains('item-tea'));
      expect(itemIds, contains('item-espresso'));
      expect(itemIds.contains('item-rice'), isFalse);
    });

    test('watchItemsByCategory with child category returns only child products', () async {
      // Selecting 'cat-coffee' should return ONLY Single Espresso
      final items = await repository.watchItemsByCategory(categoryId: 'cat-coffee').first;
      final itemIds = items.map((i) => i.id).toList();

      expect(itemIds, contains('item-espresso'));
      expect(itemIds.contains('item-tea'), isFalse);
      expect(itemIds.contains('item-rice'), isFalse);
    });

    test('watchItemsByCategory with null returns all available items', () async {
      final items = await repository.watchItemsByCategory(categoryId: null).first;
      expect(items.length, 3);
    });
  });
}
