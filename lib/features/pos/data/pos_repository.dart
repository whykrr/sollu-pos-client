import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class PosItem {
  final String id; // productId or productItemId
  final String name;
  final String? categoryId;
  final double price;
  final double stock;
  final String unit;
  final String productType;
  final bool isActive;
  final bool hasVariants;
  final bool hasModifiers;
  final bool isProductMode;
  final String? productItemId;
  final String? variantCombination;
  final String? sku;
  final String? barcode;
  final bool trackInventory;

  final Product? product;
  final Inventory? inventory;

  PosItem({
    required this.id,
    required this.name,
    this.categoryId,
    required this.price,
    required this.stock,
    this.unit = 'Pcs',
    this.productType = 'basic',
    required this.isActive,
    this.hasVariants = false,
    this.hasModifiers = false,
    required this.isProductMode,
    this.productItemId,
    this.variantCombination,
    this.sku,
    this.barcode,
    this.trackInventory = false,
    this.product,
    this.inventory,
  });

  bool get isService => productType == 'service';
}

class PosRepository {
  final AppDatabase _database;

  PosRepository(this._database);

  Stream<List<PosItem>> watchVariantModeItems() {
    return _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        p.has_variants as product_has_variants,
        p.has_modifiers as product_has_modifiers,
        p.has_recipe as product_has_recipe,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE p.is_available = 1 AND pi.is_active = 1 AND pi.sellable = 1
      ORDER BY pi.name COLLATE NOCASE ASC
      ''',
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.variantGroups,
            _database.productModifierGroups,
            _database.productPrices,
          },
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            final id = row.read<String>('id');
            final productId = row.read<String>('product_id');
            final name = row.read<String>('name');
            final variantCombination = row.read<String?>('variant_combination');
            final sku = row.read<String?>('sku');
            final barcode = row.read<String?>('barcode');
            final trackInventory = row.read<bool>('track_inventory');
            final isItemActive = row.read<bool>('item_is_active');
            final isProductAvailable = row.read<bool>('product_is_available');
            final stock = row.read<double>('stock');
            final unit = row.read<String>('unit');
            final categoryId = row.read<String?>('category_id');
            final productType = row.read<String>('product_type');
            final variantCount = row.read<int>('variant_count');
            final modifierCount = row.read<int>('modifier_count');
            final itemPrice = row.read<double>('item_price');
            final inventoryId = row.read<String?>('inventory_id');
            final hasVariants = row.read<bool?>('product_has_variants') ?? (variantCount > 0);
            final hasModifiers = row.read<bool?>('product_has_modifiers') ?? (modifierCount > 0);
            final hasRecipe = row.read<bool?>('product_has_recipe') ?? false;

            final effectiveActive = isItemActive && isProductAvailable;

            return PosItem(
              id: id,
              name: name,
              categoryId: categoryId,
              price: itemPrice,
              stock: stock,
              unit: unit,
              productType: productType,
              isActive: effectiveActive,
              hasVariants: hasVariants,
              hasModifiers: hasModifiers,
              isProductMode: false,
              productItemId: id,
              variantCombination: variantCombination,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              inventory: inventoryId != null
                  ? Inventory(
                      id: inventoryId,
                      productId: productId,
                      productItemId: id,
                      name: name,
                      sku: sku,
                      barcode: barcode,
                      trackInventory: trackInventory,
                      isActive: effectiveActive,
                      stock: stock,
                      unit: unit,
                    )
                  : null,
              product: Product(
                id: productId,
                name: name,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                price: itemPrice,
                isAvailable: isProductAvailable,
                productType: productType,
                unit: unit,
                hasVariants: hasVariants,
                hasModifiers: hasModifiers,
                hasRecipe: hasRecipe,
                trackInventory: trackInventory,
              ),
            );
          }).toList();
        });
  }

  Stream<List<PosItem>> watchProductModeItems() {
    return _database
        .customSelect(
          '''
      SELECT 
        p.*,
        (SELECT id FROM product_items WHERE product_id = p.id AND (variant_combination IS NULL OR variant_combination = '') LIMIT 1) as default_product_item_id,
        COALESCE((SELECT SUM(stock) FROM inventories WHERE product_id = p.id), 0.0) as total_stock,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_id = p.id AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as base_price
      FROM products p
      ORDER BY p.name COLLATE NOCASE ASC
      ''',
          readsFrom: {
            _database.products,
            _database.productItems,
            _database.inventories,
            _database.variantGroups,
            _database.productModifierGroups,
            _database.productPrices,
          },
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            final productId = row.read<String>('id');
            final defaultProductItemId =
                row.read<String?>('default_product_item_id');
            final name = row.read<String>('name');
            final categoryId = row.read<String?>('category_id');
            final sku = row.read<String?>('sku');
            final barcode = row.read<String?>('barcode');
            final fallbackPrice = row.read<double>('price');
            final isActive = row.read<bool>('is_available');
            final productType = row.read<String>('product_type');
            final unit = row.read<String>('unit');

            final totalStock = row.read<double?>('total_stock') ?? 0.0;
            final variantCount = row.read<int>('variant_count');
            final modifierCount = row.read<int>('modifier_count');
            final basePrice = row.read<double>('base_price');
            final hasVariants =
                row.read<bool?>('has_variants') ?? (variantCount > 0);
            final hasModifiers =
                row.read<bool?>('has_modifiers') ?? (modifierCount > 0);
            final hasRecipe = row.read<bool?>('has_recipe') ?? false;
            final trackInventory =
                row.read<bool?>('track_inventory') ?? false;

            return PosItem(
              id: productId,
              name: name,
              categoryId: categoryId,
              price: basePrice,
              stock: totalStock,
              unit: unit,
              productType: productType,
              isActive: isActive,
              hasVariants: hasVariants,
              hasModifiers: hasModifiers,
              isProductMode: true,
              productItemId: defaultProductItemId,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              product: Product(
                id: productId,
                name: name,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                price: fallbackPrice,
                isAvailable: isActive,
                productType: productType,
                unit: unit,
                hasVariants: hasVariants,
                hasModifiers: hasModifiers,
                hasRecipe: hasRecipe,
                trackInventory: trackInventory,
              ),
              inventory: null,
            );
          }).toList();
        });
  }

  Future<void> toggleInventoryActiveStatus(
    String id,
    bool isActive,
    bool isProductMode,
  ) async {
    if (isProductMode) {
      await (_database.update(_database.products)
            ..where((t) => t.id.equals(id)))
          .write(ProductsCompanion(isAvailable: Value(isActive)));
    } else {
      await (_database.update(_database.productItems)
            ..where((t) => t.id.equals(id)))
          .write(ProductItemsCompanion(isActive: Value(isActive)));
      await (_database.update(_database.inventories)
            ..where((t) => t.id.equals(id) | t.productItemId.equals(id)))
          .write(InventoriesCompanion(isActive: Value(isActive)));
    }
  }

  Stream<List<ProductCategory>> watchCategories() {
    return (_database.select(_database.productCategories)..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  /// Aggregative Category Filter: Memilih kategori induk otomatis memunculkan
  /// produk induk dan seluruh sub-kategorinya.
  Stream<List<PosItem>> watchItemsByCategory({String? categoryId}) {
    if (categoryId == null || categoryId.isEmpty) {
      return watchVariantModeItems();
    }

    return _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        p.has_variants as product_has_variants,
        p.has_modifiers as product_has_modifiers,
        p.has_recipe as product_has_recipe,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE p.category_id IN (
        SELECT id FROM product_categories WHERE id = ? OR parent_id = ?
      ) AND p.is_available = 1 AND pi.is_active = 1 AND pi.sellable = 1
      ORDER BY pi.name COLLATE NOCASE ASC
      ''',
          variables: [
            Variable.withString(categoryId),
            Variable.withString(categoryId),
          ],
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.productCategories,
            _database.variantGroups,
            _database.productModifierGroups,
            _database.productPrices,
          },
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            final id = row.read<String>('id');
            final productId = row.read<String>('product_id');
            final name = row.read<String>('name');
            final variantCombination = row.read<String?>('variant_combination');
            final sku = row.read<String?>('sku');
            final barcode = row.read<String?>('barcode');
            final trackInventory = row.read<bool>('track_inventory');
            final isItemActive = row.read<bool>('item_is_active');
            final isProductAvailable = row.read<bool>('product_is_available');
            final stock = row.read<double>('stock');
            final unit = row.read<String>('unit');
            final catId = row.read<String?>('category_id');
            final productType = row.read<String>('product_type');
            final variantCount = row.read<int>('variant_count');
            final modifierCount = row.read<int>('modifier_count');
            final itemPrice = row.read<double>('item_price');
            final inventoryId = row.read<String?>('inventory_id');
            final hasVariants =
                row.read<bool?>('product_has_variants') ?? (variantCount > 0);
            final hasModifiers =
                row.read<bool?>('product_has_modifiers') ?? (modifierCount > 0);
            final hasRecipe = row.read<bool?>('product_has_recipe') ?? false;

            final effectiveActive = isItemActive && isProductAvailable;

            return PosItem(
              id: id,
              name: name,
              categoryId: catId,
              price: itemPrice,
              stock: stock,
              unit: unit,
              productType: productType,
              isActive: effectiveActive,
              hasVariants: hasVariants,
              hasModifiers: hasModifiers,
              isProductMode: false,
              productItemId: id,
              variantCombination: variantCombination,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              inventory: inventoryId != null
                  ? Inventory(
                      id: inventoryId,
                      productId: productId,
                      productItemId: id,
                      name: name,
                      sku: sku,
                      barcode: barcode,
                      trackInventory: trackInventory,
                      isActive: effectiveActive,
                      stock: stock,
                      unit: unit,
                    )
                  : null,
              product: Product(
                id: productId,
                name: name,
                categoryId: catId,
                sku: sku,
                barcode: barcode,
                price: itemPrice,
                isAvailable: isProductAvailable,
                productType: productType,
                unit: unit,
                hasVariants: hasVariants,
                hasModifiers: hasModifiers,
                hasRecipe: hasRecipe,
                trackInventory: trackInventory,
              ),
            );
          }).toList();
        });
  }

  /// Instant Multi-Key Omni-Search: Mencocokkan barcode, sku, name, dan variant_combination.
  Future<PosItem?> findItemByBarcodeOrSku(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final rows = await _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        p.has_variants as product_has_variants,
        p.has_modifiers as product_has_modifiers,
        p.has_recipe as product_has_recipe,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id,
        p.name as product_name,
        p.barcode as product_barcode,
        p.sku as product_sku
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE (
        pi.barcode = ? OR 
        pi.sku = ? OR 
        p.barcode = ? OR 
        p.sku = ? OR
        pi.name LIKE ? OR
        pi.variant_combination LIKE ?
      ) AND pi.is_active = 1 AND pi.sellable = 1 AND p.is_available = 1
      ORDER BY 
        CASE 
          WHEN pi.barcode = ? THEN 1
          WHEN pi.sku = ? THEN 2
          WHEN p.barcode = ? THEN 3
          WHEN p.sku = ? THEN 4
          WHEN pi.name = ? THEN 5
          ELSE 6
        END
      LIMIT 1
      ''',
          variables: [
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString('%$trimmed%'),
            Variable.withString('%$trimmed%'),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
            Variable.withString(trimmed),
          ],
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.productPrices,
            _database.variantGroups,
            _database.productModifierGroups,
          },
        )
        .get();

    if (rows.isNotEmpty) {
      final row = rows.first;
      final id = row.read<String>('id');
      final productId = row.read<String>('product_id');
      final name = row.read<String>('name');
      final variantCombination = row.read<String?>('variant_combination');
      final sku = row.read<String?>('sku');
      final barcode = row.read<String?>('barcode');
      final trackInventory = row.read<bool>('track_inventory');
      final isItemActive = row.read<bool>('item_is_active');
      final isProductAvailable = row.read<bool>('product_is_available');
      final stock = row.read<double>('stock');
      final unit = row.read<String>('unit');
      final categoryId = row.read<String?>('category_id');
      final productType = row.read<String>('product_type');
      final variantCount = row.read<int>('variant_count');
      final modifierCount = row.read<int>('modifier_count');
      final itemPrice = row.read<double>('item_price');
      final inventoryId = row.read<String?>('inventory_id');
      final productName = row.read<String>('product_name');
      final productBarcode = row.read<String?>('product_barcode');
      final productSku = row.read<String?>('product_sku');
      final hasVariants =
          row.read<bool?>('product_has_variants') ?? (variantCount > 0);
      final hasModifiers =
          row.read<bool?>('product_has_modifiers') ?? (modifierCount > 0);
      final hasRecipe = row.read<bool?>('product_has_recipe') ?? false;

      final effectiveActive = isItemActive && isProductAvailable;

      return PosItem(
        id: id,
        name: name,
        categoryId: categoryId,
        price: itemPrice,
        stock: stock,
        unit: unit,
        productType: productType,
        isActive: effectiveActive,
        hasVariants: hasVariants,
        hasModifiers: hasModifiers,
        isProductMode: false,
        productItemId: id,
        variantCombination: variantCombination,
        sku: sku,
        barcode: barcode,
        trackInventory: trackInventory,
        inventory: inventoryId != null
            ? Inventory(
                id: inventoryId,
                productId: productId,
                productItemId: id,
                name: name,
                sku: sku,
                barcode: barcode,
                trackInventory: trackInventory,
                isActive: effectiveActive,
                stock: stock,
                unit: unit,
              )
            : null,
        product: Product(
          id: productId,
          name: productName,
          categoryId: categoryId,
          sku: productSku,
          barcode: productBarcode,
          price: itemPrice,
          isAvailable: isProductAvailable,
          productType: productType,
          unit: unit,
          hasVariants: hasVariants,
          hasModifiers: hasModifiers,
          hasRecipe: hasRecipe,
          trackInventory: trackInventory,
        ),
      );
    }

    return null;
  }

  /// Resolves the product_item_id for a given product and list of variant group option IDs
  Future<String?> findProductItemIdForVariants(
    String productId,
    List<String> variantGroupOptionIds,
  ) async {
    if (variantGroupOptionIds.isEmpty) return null;

    final inClause = List.filled(variantGroupOptionIds.length, '?').join(',');
    final query = '''
      SELECT piv.product_item_id
      FROM product_item_variant_group_options piv
      INNER JOIN product_items pi ON pi.id = piv.product_item_id
      WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
      GROUP BY piv.product_item_id
      HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
        AND (SELECT COUNT(*) FROM product_item_variant_group_options WHERE product_item_id = piv.product_item_id) = ?
      LIMIT 1
    ''';

    final variables = <Variable>[
      Variable.withString(productId),
      ...variantGroupOptionIds.map((id) => Variable.withString(id)),
      Variable.withInt(variantGroupOptionIds.length),
      Variable.withInt(variantGroupOptionIds.length),
    ];

    final row = await _database
        .customSelect(query, variables: variables)
        .getSingleOrNull();

    return row?.read<String>('product_item_id');
  }

  /// Fetches a PosItem directly by its product_item_id
  Future<PosItem?> getPosItemByProductItemId(String productItemId) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        p.has_variants as product_has_variants,
        p.has_modifiers as product_has_modifiers,
        p.has_recipe as product_has_recipe,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id,
        p.name as product_name,
        p.barcode as product_barcode,
        p.sku as product_sku
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE pi.id = ?
      LIMIT 1
      ''',
          variables: [Variable.withString(productItemId)],
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.productPrices,
            _database.variantGroups,
            _database.productModifierGroups,
          },
        )
        .get();

    if (rows.isEmpty) return null;

    final row = rows.first;
    final id = row.read<String>('id');
    final productId = row.read<String>('product_id');
    final name = row.read<String>('name');
    final variantCombination = row.read<String?>('variant_combination');
    final sku = row.read<String?>('sku');
    final barcode = row.read<String?>('barcode');
    final trackInventory = row.read<bool>('track_inventory');
    final isItemActive = row.read<bool>('item_is_active');
    final isProductAvailable = row.read<bool>('product_is_available');
    final stock = row.read<double>('stock');
    final unit = row.read<String>('unit');
    final categoryId = row.read<String?>('category_id');
    final productType = row.read<String>('product_type');
    final variantCount = row.read<int>('variant_count');
    final modifierCount = row.read<int>('modifier_count');
    final itemPrice = row.read<double>('item_price');
    final inventoryId = row.read<String?>('inventory_id');
    final productName = row.read<String>('product_name');
    final productBarcode = row.read<String?>('product_barcode');
    final productSku = row.read<String?>('product_sku');
    final hasVariants =
        row.read<bool?>('product_has_variants') ?? (variantCount > 0);
    final hasModifiers =
        row.read<bool?>('product_has_modifiers') ?? (modifierCount > 0);
    final hasRecipe = row.read<bool?>('product_has_recipe') ?? false;

    final effectiveActive = isItemActive && isProductAvailable;

    return PosItem(
      id: id,
      name: name,
      categoryId: categoryId,
      price: itemPrice,
      stock: stock,
      unit: unit,
      productType: productType,
      isActive: effectiveActive,
      hasVariants: hasVariants,
      hasModifiers: hasModifiers,
      isProductMode: false,
      productItemId: id,
      variantCombination: variantCombination,
      sku: sku,
      barcode: barcode,
      trackInventory: trackInventory,
      inventory: inventoryId != null
          ? Inventory(
              id: inventoryId,
              productId: productId,
              productItemId: id,
              name: name,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              isActive: effectiveActive,
              stock: stock,
              unit: unit,
            )
          : null,
      product: Product(
        id: productId,
        name: productName,
        categoryId: categoryId,
        sku: productSku,
        barcode: productBarcode,
        price: itemPrice,
        isAvailable: isProductAvailable,
        productType: productType,
        unit: unit,
        hasVariants: hasVariants,
        hasModifiers: hasModifiers,
        hasRecipe: hasRecipe,
        trackInventory: trackInventory,
      ),
    );
  }

  /// Resolves the default product_item_id for a single product without variants
  Future<String?> findDefaultProductItemId(String productId) async {
    final row = await _database.customSelect(
      '''
      SELECT id FROM product_items
      WHERE product_id = ?
      ORDER BY (variant_combination IS NULL) DESC, id ASC
      LIMIT 1
      ''',
      variables: [Variable.withString(productId)],
    ).getSingleOrNull();

    return row?.read<String>('id');
  }

  /// Resolves the inventory_item_id for a given product and variant option
  Future<String?> findInventoryItemIdForVariant(
    String productId,
    String variantGroupOptionId,
  ) async {
    final pItemId =
        await findProductItemIdForVariants(productId, [variantGroupOptionId]);
    if (pItemId != null) {
      final inv = await (_database.select(_database.inventories)
            ..where((i) => i.productItemId.equals(pItemId)))
          .getSingleOrNull();
      if (inv != null) return inv.id;
    }

    final row = await _database
        .customSelect(
          '''
      SELECT i.id FROM inventories i
      INNER JOIN inventory_item_variant_group_options piv ON piv.inventory_item_id = i.id
      WHERE i.product_id = ? AND piv.variant_group_option_id = ?
      LIMIT 1
      ''',
          variables: [
            Variable.withString(productId),
            Variable.withString(variantGroupOptionId),
          ],
        )
        .getSingleOrNull();

    return row?.read<String>('id');
  }

  /// Resolves the standalone inventory_item_id for a product without variants
  Future<String?> findStandaloneInventoryItemId(String productId) async {
    final inv = await (_database.select(
      _database.inventories,
    )..where((i) => i.productId.equals(productId))).getSingleOrNull();
    return inv?.id;
  }

  /// Memeriksa ketersediaan stok untuk item-item di keranjang belanja.
  /// Mengembalikan daftar nama item yang stoknya kurang dari kuantitas belanja (jika trackInventory aktif).
  Future<List<String>> checkCartStockAvailability(List<dynamic> items) async {
    final List<String> insufficientItems = [];

    // Kelompokkan total kuantitas per inventory_item_id
    final Map<String, double> requiredQtyByInvId = {};
    final Map<String, String> itemNamesByInvId = {};

    for (final item in items) {
      // Lewati pengecekan stok jika item tidak melacak stok (trackInventory = false)
      try {
        if (item.trackInventory == false) {
          continue;
        }
      } catch (_) {}

      // Lewati pengecekan stok jika item adalah tipe jasa / service
      if (item.productId != null && item.productId.toString().isNotEmpty) {
        final prod = await (_database.select(_database.products)
              ..where((p) => p.id.equals(item.productId.toString())))
            .getSingleOrNull();
        if (prod != null && prod.productType == 'service') {
          continue;
        }
      }

      String? resolvedInvId = (item.inventoryItemId != null &&
              item.inventoryItemId.toString().isNotEmpty)
          ? item.inventoryItemId.toString()
          : null;

      if (resolvedInvId == null) {
        try {
          if (item.productItemId != null &&
              item.productItemId.toString().isNotEmpty) {
            final inv = await (_database.select(_database.inventories)
                  ..where(
                    (i) => i.productItemId.equals(item.productItemId.toString()),
                  ))
                .getSingleOrNull();
            resolvedInvId = inv?.id;
          }
        } catch (_) {}
      }

      if (resolvedInvId == null &&
          item.productId != null &&
          item.productId.toString().isNotEmpty) {
        final prodId = item.productId.toString();
        final String? varOptId = item.variantGroupOptionId ??
            (item.selectedVariants is Map
                ? item.selectedVariants.values.firstOrNull?.toString()
                : null);

        if (varOptId != null) {
          resolvedInvId = await findInventoryItemIdForVariant(prodId, varOptId);
        }
        resolvedInvId ??= await findStandaloneInventoryItemId(prodId);
      }

      if (resolvedInvId != null) {
        final double qty = (item.qty as num).toDouble();
        requiredQtyByInvId[resolvedInvId] =
            (requiredQtyByInvId[resolvedInvId] ?? 0.0) + qty;
        itemNamesByInvId[resolvedInvId] = item.name.toString();
      }
    }

    for (final entry in requiredQtyByInvId.entries) {
      final invId = entry.key;
      final requiredQty = entry.value;

      final inventory = await (_database.select(_database.inventories)
            ..where((i) => i.id.equals(invId)))
          .getSingleOrNull();

      if (inventory != null && inventory.trackInventory) {
        if (inventory.stock < requiredQty) {
          insufficientItems.add(itemNamesByInvId[invId] ?? inventory.name);
        }
      }
    }

    return insufficientItems;
  }
}
