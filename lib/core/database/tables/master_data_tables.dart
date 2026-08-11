import 'package:drift/drift.dart';

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductCategory')
class ProductCategories extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VariantGroup')
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
  TextColumn get variantGroupOptionId => text().references(VariantGroupOptions, #id)();
  
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
class ProductPrices extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get inventoryItemId => text().nullable().references(Inventories, #id)();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Inventory')
class Inventories extends Table {
  TextColumn get id => text()(); // UUID dari inventory_item_id
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get stock => real().withDefault(const Constant(0.0))(); // Saldo dari inventory_balances
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentMethod')
class PaymentMethods extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get type => text()(); // cash, qris, edc, transfer
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutletSetting')
class OutletSettings extends Table {
  TextColumn get id => text()();
  RealColumn get taxPercentage => real().withDefault(const Constant(0.0))();
  RealColumn get serviceChargePercentage => real().withDefault(const Constant(0.0))();
  TextColumn get printerMacAddress => text().nullable()();
  
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
  
  @override
  Set<Column> get primaryKey => {id};
}
