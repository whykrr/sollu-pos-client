import 'package:drift/drift.dart';
import 'package:sollu_pos_client/core/database/tables/master_data_tables.dart';

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
  TextColumn get channel => text().withDefault(const Constant('pos'))(); // 'pos', 'direct', 'invoice'
  TextColumn get transactionNumber => text()();
  
  // Financials
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get discountType => text().nullable()(); // 'percentage', 'fixed'
  RealColumn get discountValue => real().nullable()();
  TextColumn get promoName => text().nullable()();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get serviceChargeAmount => real().withDefault(const Constant(0.0))();
  RealColumn get shippingFee => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  
  // Statuses
  TextColumn get paymentStatus => text()(); // 'unpaid', 'paid', 'partial', 'draft'
  TextColumn get status => text()(); // 'completed', 'hold', 'void', 'paid', 'cancel'
  TextColumn get notes => text().nullable()();
  
  // Offline Sync
  BoolColumn get isOffline => boolean().withDefault(const Constant(true))();
  TextColumn get offlineId => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionItem')
class TransactionItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get productId => text().nullable()();
  TextColumn get inventoryItemId => text().nullable()();
  TextColumn get variantGroupOptionId => text().nullable()();
  TextColumn get productName => text()(); // Denormalized
  RealColumn get price => real()();
  RealColumn get qty => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get promoName => text().nullable()();
  RealColumn get subtotal => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionItemModifier')
class TransactionItemModifiers extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionItemId => text().references(TransactionItems, #id)();
  TextColumn get modifierOptionId => text().nullable()();
  TextColumn get modifierName => text()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get qty => real().withDefault(const Constant(1.0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionPayment')
class TransactionPayments extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get paymentMethodId => text().nullable().references(PaymentMethods, #id)();
  RealColumn get amount => real()();
  RealColumn get changeAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentReference => text().nullable()();
  DateTimeColumn get paidAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionPromo')
class TransactionPromos extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get promoId => text().nullable().references(Promos, #id)();
  TextColumn get promoName => text()();
  TextColumn get promoCode => text().nullable()();
  TextColumn get discountType => text()(); // 'percentage', 'fixed'
  RealColumn get discountValue => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}
