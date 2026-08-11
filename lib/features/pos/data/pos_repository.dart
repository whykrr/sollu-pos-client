import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class PosItem {
  final String id; // productId or inventoryItemId
  final String name;
  final String? categoryId;
  final double price;
  final double stock;
  final bool isActive;
  final bool hasVariants;
  final bool hasModifiers;
  final bool isProductMode;
  
  final Product? product;
  final Inventory? inventory;

  PosItem({
    required this.id,
    required this.name,
    this.categoryId,
    required this.price,
    required this.stock,
    required this.isActive,
    this.hasVariants = false,
    this.hasModifiers = false,
    required this.isProductMode,
    this.product,
    this.inventory,
  });
}

class PosRepository {
  final AppDatabase _database;

  PosRepository(this._database);

  Stream<List<PosItem>> watchVariantModeItems() {
    return _database.customSelect(
      '''
      SELECT 
        i.*,
        p.category_id,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND inventory_item_id IS NULL LIMIT 1),
          p.price
        ) as item_price
      FROM inventories i
      INNER JOIN products p ON i.product_id = p.id
      ''',
      readsFrom: {
        _database.inventories,
        _database.products,
        _database.variantGroups,
        _database.productModifierGroups,
        _database.productPrices,
      },
    ).watch().map((rows) {
      return rows.map((row) {
        final inventoryId = row.read<String>('id');
        final productId = row.read<String>('product_id');
        final name = row.read<String>('name');
        final sku = row.read<String?>('sku');
        final barcode = row.read<String?>('barcode');
        final trackInventory = row.read<bool>('track_inventory');
        final isActive = row.read<bool>('is_active');
        final stock = row.read<double>('stock');
        final categoryId = row.read<String?>('category_id');
        final variantCount = row.read<int>('variant_count');
        final modifierCount = row.read<int>('modifier_count');
        final itemPrice = row.read<double>('item_price');

        return PosItem(
          id: inventoryId,
          name: name,
          categoryId: categoryId,
          price: itemPrice,
          stock: stock,
          isActive: isActive,
          hasVariants: variantCount > 0,
          hasModifiers: modifierCount > 0,
          isProductMode: false,
          inventory: Inventory(
            id: inventoryId,
            productId: productId,
            name: name,
            sku: sku,
            barcode: barcode,
            trackInventory: trackInventory,
            isActive: isActive,
            stock: stock,
          ),
          product: null,
        );
      }).toList();
    });
  }

  Stream<List<PosItem>> watchProductModeItems() {
    return _database.customSelect(
      '''
      SELECT 
        p.*,
        (SELECT SUM(stock) FROM inventories WHERE product_id = p.id) as total_stock,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE((SELECT amount FROM product_prices WHERE product_id = p.id AND inventory_item_id IS NULL LIMIT 1), p.price) as base_price
      FROM products p
      ''',
      readsFrom: {
        _database.products,
        _database.inventories,
        _database.variantGroups,
        _database.productModifierGroups,
        _database.productPrices,
      },
    ).watch().map((rows) {
      return rows.map((row) {
        final productId = row.read<String>('id');
        final name = row.read<String>('name');
        final categoryId = row.read<String?>('category_id');
        final sku = row.read<String?>('sku');
        final barcode = row.read<String?>('barcode');
        final fallbackPrice = row.read<double>('price');
        final isActive = row.read<bool>('is_available');
        
        final totalStock = row.read<double?>('total_stock') ?? 0.0;
        final variantCount = row.read<int>('variant_count');
        final modifierCount = row.read<int>('modifier_count');
        final basePrice = row.read<double>('base_price');

        return PosItem(
          id: productId,
          name: name,
          categoryId: categoryId,
          price: basePrice,
          stock: totalStock,
          isActive: isActive,
          hasVariants: variantCount > 0,
          hasModifiers: modifierCount > 0,
          isProductMode: true,
          product: Product(
            id: productId,
            name: name,
            categoryId: categoryId,
            sku: sku,
            barcode: barcode,
            price: fallbackPrice,
            isAvailable: isActive,
          ),
          inventory: null,
        );
      }).toList();
    });
  }

  Future<void> toggleInventoryActiveStatus(String id, bool isActive, bool isProductMode) async {
    if (isProductMode) {
      await (_database.update(_database.products)
            ..where((t) => t.id.equals(id)))
          .write(ProductsCompanion(isAvailable: Value(isActive)));
    } else {
      await (_database.update(_database.inventories)
            ..where((t) => t.id.equals(id)))
          .write(InventoriesCompanion(isActive: Value(isActive)));
    }
  }

  Stream<List<ProductCategory>> watchCategories() {
    return (_database.select(_database.productCategories)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<PosItem?> findItemByBarcodeOrSku(String query) async {
    final invRows = await _database.customSelect(
      '''
      SELECT 
        i.*,
        p.category_id,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND inventory_item_id IS NULL LIMIT 1),
          p.price
        ) as item_price
      FROM inventories i
      INNER JOIN products p ON i.product_id = p.id
      WHERE i.barcode = ? OR i.sku = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(query), Variable.withString(query)],
    ).get();

    if (invRows.isNotEmpty) {
      final row = invRows.first;
      return PosItem(
        id: row.read<String>('id'),
        name: row.read<String>('name'),
        categoryId: row.read<String?>('category_id'),
        price: row.read<double>('item_price'),
        stock: row.read<double>('stock'),
        isActive: row.read<bool>('is_active'),
        hasVariants: row.read<int>('variant_count') > 0,
        hasModifiers: row.read<int>('modifier_count') > 0,
        isProductMode: false,
        inventory: Inventory(
          id: row.read<String>('id'),
          productId: row.read<String>('product_id'),
          name: row.read<String>('name'),
          sku: row.read<String?>('sku'),
          barcode: row.read<String?>('barcode'),
          trackInventory: row.read<bool>('track_inventory'),
          isActive: row.read<bool>('is_active'),
          stock: row.read<double>('stock'),
        ),
      );
    }

    return null;
  }
}
