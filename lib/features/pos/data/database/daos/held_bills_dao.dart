import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';

class HeldBillsDao {
  final AppDatabase _db;

  HeldBillsDao(this._db);

  Stream<List<HeldTransaction>> watchHeldTransactions(String outletId) {
    return (_db.select(_db.heldTransactions)
          ..where((tbl) => tbl.outletId.equals(outletId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.heldAt)]))
        .watch();
  }

  Future<List<HeldTransaction>> getHeldTransactions(String outletId) {
    return (_db.select(_db.heldTransactions)
          ..where((tbl) => tbl.outletId.equals(outletId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.heldAt)]))
        .get();
  }

  Future<HeldTransaction?> getHeldTransactionById(String id) {
    return (_db.select(_db.heldTransactions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertHeldTransaction(HeldTransactionsCompanion entry) {
    return _db.into(_db.heldTransactions).insert(
          entry,
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int> deleteHeldTransaction(String id) {
    return (_db.delete(_db.heldTransactions)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}

final heldBillsDaoProvider = Provider<HeldBillsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return HeldBillsDao(db);
});
