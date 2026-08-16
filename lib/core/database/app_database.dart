import 'package:drift/drift.dart';

import 'package:sollu_pos_client/core/database/connection/connection.dart';
import 'package:sollu_pos_client/core/database/tables/master_data_tables.dart';
import 'package:sollu_pos_client/core/database/tables/transaction_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Products,
  ProductCategories,
  VariantGroups,
  VariantGroupOptions,
  InventoryItemVariantGroupOptions,
  ModifierGroups,
  ProductModifierGroups,
  ModifierOptions,
  ProductPrices,
  Inventories,
  PaymentMethods,
  OutletSettings,
  Shifts,
  ShiftCashLogs,
  Transactions,
  TransactionItems,
  TransactionItemModifiers,
  TransactionPayments,
  TransactionPromos,
  Employees,
  Promos,
  Customers,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(productCategories, productCategories.sortOrder);
        }
      },
    );
  }
}
