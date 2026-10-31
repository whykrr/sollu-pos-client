import 'package:drift/drift.dart';

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get productType => text().withDefault(const Constant('basic'))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();
  BoolColumn get hasVariants => boolean().withDefault(const Constant(false))();
  BoolColumn get hasModifiers => boolean().withDefault(const Constant(false))();
  BoolColumn get hasRecipe => boolean().withDefault(const Constant(false))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductItem')
class ProductItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  TextColumn get variantCombination => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get sellable => boolean().withDefault(const Constant(true))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductItemVariantGroupOption')
class ProductItemVariantGroupOptions extends Table {
  TextColumn get productItemId => text().references(ProductItems, #id)();
  TextColumn get variantGroupOptionId =>
      text().references(VariantGroupOptions, #id)();

  @override
  Set<Column> get primaryKey => {productItemId, variantGroupOptionId};
}

@DataClassName('ProductCategory')
class ProductCategories extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VariantGroup')
@TableIndex(name: 'idx_variant_groups_product_id', columns: {#productId})
class VariantGroups extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VariantGroupOption')
class VariantGroupOptions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get variantGroupId => text().references(VariantGroups, #id)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InventoryItemVariantGroupOption')
class InventoryItemVariantGroupOptions extends Table {
  TextColumn get inventoryItemId => text().references(Inventories, #id)();
  TextColumn get variantGroupOptionId =>
      text().references(VariantGroupOptions, #id)();

  @override
  Set<Column> get primaryKey => {inventoryItemId, variantGroupOptionId};
}

@DataClassName('ModifierGroup')
class ModifierGroups extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get type => text().nullable()(); // radio/checkbox dll
  IntColumn get minSelected => integer().withDefault(const Constant(0))();
  IntColumn get maxSelected => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductModifierGroup')
@TableIndex(
  name: 'idx_product_modifier_groups_product_id',
  columns: {#productId},
)
class ProductModifierGroups extends Table {
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get modifierGroupId => text().references(ModifierGroups, #id)();

  @override
  Set<Column> get primaryKey => {productId, modifierGroupId};
}

@DataClassName('ModifierOption')
class ModifierOptions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get modifierGroupId => text().references(ModifierGroups, #id)();
  TextColumn get name => text()();
  RealColumn get price => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductPrice')
@TableIndex(name: 'idx_product_prices_product_id', columns: {#productId})
@TableIndex(name: 'idx_product_prices_product_item_id', columns: {#productItemId})
@TableIndex(
  name: 'idx_product_prices_inventory_item_id',
  columns: {#inventoryItemId},
)
class ProductPrices extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productItemId =>
      text().nullable().references(ProductItems, #id)();
  TextColumn get inventoryItemId =>
      text().nullable().references(Inventories, #id)();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Inventory')
@TableIndex(name: 'idx_inventories_product_id', columns: {#productId})
@TableIndex(name: 'idx_inventories_product_item_id', columns: {#productItemId})
class Inventories extends Table {
  TextColumn get id => text()(); // UUID dari inventory_item_id
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productItemId =>
      text().nullable().references(ProductItems, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get trackInventory =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get stock => real().withDefault(
    const Constant(0.0),
  )(); // Saldo dari inventory_balances
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentMethod')
class PaymentMethods extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash, qris, edc, ewallet, bank_transfer, custom
  TextColumn get provider => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get accountName => text().nullable()();
  TextColumn get referencePolicy =>
      text().withDefault(const Constant('optional'))(); // optional, mandatory, hidden
  BoolColumn get openCashDrawer =>
      boolean().withDefault(const Constant(false))();
  TextColumn get instructions => text().nullable()();
  TextColumn get qrImageUrl => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Employee')
class Employees extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get pin => text().nullable()();
  TextColumn get photo => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get permissions => text().nullable()();
  BoolColumn get isRootUser => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Promo')
class Promos extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get promoType => text()(); // 'percentage', 'fixed'
  TextColumn get targetType => text()(); // 'product', 'bill'
  RealColumn get discountValue => real()();
  RealColumn get maxDiscount => real().nullable()();
  BoolColumn get appliesToAllOutlets =>
      boolean().withDefault(const Constant(true))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get code => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
