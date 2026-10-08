import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sollu_pos_client/core/database/tables/master_data_tables.dart';
import 'package:sollu_pos_client/core/database/tables/transaction_tables.dart';

import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
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
    HeldTransactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

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
        if (from < 3) {
          await customStatement('DROP TABLE IF EXISTS outlet_settings;');
        }
        if (from < 4) {
          await m.addColumn(employees, employees.permissions);
        }
        if (from < 5) {
          await m.addColumn(products, products.productType);
          await m.addColumn(products, products.unit);
          await m.addColumn(inventories, inventories.unit);
        }
        if (from < 6) {
          await m.addColumn(employees, employees.isRootUser);
        }
        if (from < 7) {
          await m.createTable(heldTransactions);
        }
      },
    );
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Gunakan path_provider yang kompatibel untuk cross-platform (termasuk Windows)
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sollu_pos.sqlite'));

    // Cetak path database
    debugPrint("LOKASI DATABASE: ${file.path}");

    // Gunakan logStatements: true jika perlu debug query di terminal
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
