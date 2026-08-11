import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:sollu_pos_app/core/database/tables/master_data_tables.dart';
import 'package:sollu_pos_app/core/database/tables/transaction_tables.dart';

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
  Employees,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Cetak path database
    String databasesPath = await getDatabasesPath();
    print("LOKASI DATABASE: $databasesPath");
    
    final file = File(p.join(databasesPath, 'sollu_pos.sqlite'));
    
    // Gunakan logStatements: true jika perlu debug query di terminal
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
