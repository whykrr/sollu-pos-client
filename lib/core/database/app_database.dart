import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Gunakan path_provider yang kompatibel untuk cross-platform (termasuk Windows)
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sollu_pos.sqlite'));
    
    // Cetak path database
    print("LOKASI DATABASE: ${file.path}");
    
    // Gunakan logStatements: true jika perlu debug query di terminal
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
