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

@DataClassName('Variant')
class Variants extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  RealColumn get priceAdjustment => real().withDefault(const Constant(0.0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Inventory')
class Inventories extends Table {
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get stock => real().withDefault(const Constant(0.0))(); // REAL untuk mendukung pecahan jika perlu
  
  @override
  Set<Column> get primaryKey => {productId};
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
