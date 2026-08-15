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
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get localSortOrder => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutletSetting')
class OutletSettings extends Table {
  TextColumn get id => text()();
  RealColumn get taxPercentage => real().withDefault(const Constant(0.0))();
  RealColumn get serviceChargePercentage => real().withDefault(const Constant(0.0))();
  BoolColumn get taxIncludedInPrice => boolean().withDefault(const Constant(false))();
  BoolColumn get roundingEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get roundingMode => text().withDefault(const Constant('nearest'))();
  TextColumn get printerMacAddress => text().nullable()();

  // Receipt Layout Settings
  TextColumn get paperSize => text().withDefault(const Constant('58mm'))();
  BoolColumn get autoPrint => boolean().withDefault(const Constant(true))();
  BoolColumn get printKitchenCopy => boolean().withDefault(const Constant(false))();
  BoolColumn get printCheckerCopy => boolean().withDefault(const Constant(false))();
  BoolColumn get showLogo => boolean().withDefault(const Constant(true))();
  TextColumn get customHeaderTitle => text().nullable()();
  TextColumn get headerNotes => text().nullable()();
  BoolColumn get showAddress => boolean().withDefault(const Constant(true))();
  BoolColumn get showPhone => boolean().withDefault(const Constant(true))();
  BoolColumn get showEmail => boolean().withDefault(const Constant(false))();
  BoolColumn get showCashierName => boolean().withDefault(const Constant(true))();
  BoolColumn get showCustomerName => boolean().withDefault(const Constant(true))();
  BoolColumn get showOrderType => boolean().withDefault(const Constant(true))();
  BoolColumn get showModifiers => boolean().withDefault(const Constant(true))();
  BoolColumn get showItemNotes => boolean().withDefault(const Constant(true))();
  BoolColumn get showTaxDetail => boolean().withDefault(const Constant(true))();
  BoolColumn get showServiceCharge => boolean().withDefault(const Constant(false))();
  TextColumn get footerNotes => text().nullable()();
  TextColumn get socialMediaInfo => text().nullable()();
  TextColumn get wifiInfo => text().nullable()();
  BoolColumn get showQrCode => boolean().withDefault(const Constant(false))();
  TextColumn get qrType => text().withDefault(const Constant('invoice'))();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get localLogoPath => text().nullable()();
  
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

@DataClassName('Promo')
class Promos extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get promoType => text()(); // 'percentage', 'fixed'
  TextColumn get targetType => text()(); // 'product', 'bill'
  RealColumn get discountValue => real()();
  RealColumn get maxDiscount => real().nullable()();
  BoolColumn get appliesToAllOutlets => boolean().withDefault(const Constant(true))();
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
