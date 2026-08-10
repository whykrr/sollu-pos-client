import 'package:drift/drift.dart';
import 'package:sollu_pos_app/core/database/tables/master_data_tables.dart';

@DataClassName('Shift')
class Shifts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get outletId => text()();
  TextColumn get userId => text()();
  IntColumn get shiftNumber => integer()();
  RealColumn get openingCash => real()();
  RealColumn get closingCash => real().nullable()();
  RealColumn get expectedCash => real().nullable()();
  RealColumn get totalSales => real().nullable()();
  TextColumn get status => text()(); // 'open', 'closed'
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShiftCashLog')
class ShiftCashLogs extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get shiftId => text().references(Shifts, #id)();
  TextColumn get type => text()(); // 'cash_in', 'cash_out'
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get outletId => text()();
  TextColumn get shiftId => text().nullable().references(Shifts, #id)();
  TextColumn get customerId => text().nullable()();
  TextColumn get channel => text()(); // 'pos', 'invoice'
  
  // Financials
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get serviceChargeAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  
  // Statuses
  TextColumn get paymentStatus => text()(); // 'unpaid', 'paid', 'partial'
  TextColumn get status => text()(); // 'hold', 'completed', 'void'
  
  // Offline Sync
  BoolColumn get isOffline => boolean().withDefault(const Constant(true))();
  TextColumn get offlineId => text().unique()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionItem')
class TransactionItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get productId => text()(); // Referensi longgar, produk bisa dihapus
  TextColumn get productName => text()(); // Denormalized
  RealColumn get price => real()();
  RealColumn get qty => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get subtotal => real()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionItemModifier')
class TransactionItemModifiers extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionItemId => text().references(TransactionItems, #id)();
  TextColumn get modifierName => text()(); // Denormalized variant name
  RealColumn get priceAdjustment => real()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionPayment')
class TransactionPayments extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get paymentMethodId => text().references(PaymentMethods, #id)();
  RealColumn get amount => real()();
  RealColumn get changeAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get paidAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}
