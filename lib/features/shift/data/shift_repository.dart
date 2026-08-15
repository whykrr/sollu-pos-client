import 'package:drift/drift.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/database/app_database.dart';

class ShiftSummary {
  final double openingCash;
  final double cashSales;
  final double nonCashSales;
  final double totalSales;
  final double cashIn;
  final double cashOut;
  final double expectedCash;

  ShiftSummary({
    required this.openingCash,
    required this.cashSales,
    required this.nonCashSales,
    required this.totalSales,
    required this.cashIn,
    required this.cashOut,
    required this.expectedCash,
  });
}

class ShiftRepository {
  final DioClient _dioClient;
  final AppDatabase _database;

  ShiftRepository(this._dioClient, this._database);

  /// Memantau shift yang sedang aktif secara real-time
  Stream<Shift?> watchActiveShift() {
    return (_database.select(_database.shifts)
          ..where((tbl) => tbl.status.equals('open'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.openedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Mendapatkan shift aktif saat ini (offline first)
  Future<Shift?> getActiveShift() async {
    return await (_database.select(_database.shifts)
          ..where((tbl) => tbl.status.equals('open'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.openedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Membuka shift baru secara offline-first dan sinkron ke backend jika online
  Future<Shift> openShift({
    required double openingCash,
    required String userId,
    String outletId = 'default-outlet',
    int shiftNumber = 1,
  }) async {
    final shiftId = 'SHIFT-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final companion = ShiftsCompanion.insert(
      id: shiftId,
      outletId: outletId,
      userId: userId,
      shiftNumber: shiftNumber,
      openingCash: openingCash,
      status: 'open',
      openedAt: Value(now),
    );

    await _database.into(_database.shifts).insert(companion);

    // Kirim event buka shift ke backend di background jika online
    try {
      await _dioClient.dio.post('/shifts/open', data: {
        'shift_id': shiftId,
        'user_id': userId,
        'opening_cash': openingCash,
        'opened_at': now.toIso8601String(),
      });
    } catch (_) {
      // Abaikan error jaringan agar shift offline tetap berjalan mulus
    }

    return (await getActiveShift())!;
  }

  /// Menghitung ringkasan kalkulasi shift dari SQLite lokal
  Future<ShiftSummary> calculateShiftSummary(String shiftId) async {
    final shift = await (_database.select(_database.shifts)..where((t) => t.id.equals(shiftId))).getSingleOrNull();
    final openingCash = shift?.openingCash ?? 0.0;

    // Ambil transaksi pada shift ini yang completed
    final transactions = await (_database.select(_database.transactions)
          ..where((t) => t.shiftId.equals(shiftId) & t.status.equals('completed')))
        .get();

    double totalSales = 0.0;
    double cashSales = 0.0;
    double nonCashSales = 0.0;

    for (final tx in transactions) {
      totalSales += tx.total;

      // Cek pembayaran transaksi
      final payments = await (_database.select(_database.transactionPayments)
            ..where((p) => p.transactionId.equals(tx.id)))
          .get();

      if (payments.isEmpty) {
        // Default jika tanpa payment detail
        cashSales += tx.total;
      } else {
        for (final p in payments) {
          // Ambil tipe payment method
          if (p.paymentMethodId != null) {
            final pm = await (_database.select(_database.paymentMethods)..where((m) => m.id.equals(p.paymentMethodId!))).getSingleOrNull();
            if (pm?.type == 'cash' || pm?.name.toLowerCase().contains('tunai') == true) {
              cashSales += p.amount;
            } else {
              nonCashSales += p.amount;
            }
          } else {
            cashSales += p.amount;
          }
        }
      }
    }

    // Ambil kas masuk / keluar
    final cashLogs = await (_database.select(_database.shiftCashLogs)..where((l) => l.shiftId.equals(shiftId))).get();
    double cashIn = 0.0;
    double cashOut = 0.0;

    for (final log in cashLogs) {
      if (log.type == 'cash_in') {
        cashIn += log.amount;
      } else if (log.type == 'cash_out') {
        cashOut += log.amount;
      }
    }

    final expectedCash = openingCash + cashSales + (cashIn - cashOut);

    return ShiftSummary(
      openingCash: openingCash,
      cashSales: cashSales,
      nonCashSales: nonCashSales,
      totalSales: totalSales,
      cashIn: cashIn,
      cashOut: cashOut,
      expectedCash: expectedCash,
    );
  }

  /// Menutup shift kasir secara offline-first
  Future<void> closeShift({
    required String shiftId,
    required double closingCash,
    required double expectedCash,
    required double totalSales,
  }) async {
    final now = DateTime.now();

    await (_database.update(_database.shifts)..where((t) => t.id.equals(shiftId))).write(
      ShiftsCompanion(
        status: const Value('closed'),
        closingCash: Value(closingCash),
        expectedCash: Value(expectedCash),
        totalSales: Value(totalSales),
        closedAt: Value(now),
      ),
    );

    // Kirim penutupan shift ke backend jika online
    try {
      await _dioClient.dio.post('/shifts/close', data: {
        'shift_id': shiftId,
        'closing_cash': closingCash,
        'expected_cash': expectedCash,
        'total_sales': totalSales,
        'closed_at': now.toIso8601String(),
      });
    } catch (_) {
      // Offline fallback
    }
  }

  /// Menambahkan log kas masuk/keluar ke database lokal
  Future<void> addCashLog({
    required String shiftId,
    required String type,
    required double amount,
    String? note,
  }) async {
    final logId = 'LOG-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    await _database.into(_database.shiftCashLogs).insert(
      ShiftCashLogsCompanion.insert(
        id: logId,
        shiftId: shiftId,
        type: type,
        amount: amount,
        note: Value(note),
        createdAt: Value(now),
      ),
    );

    try {
      await _dioClient.dio.post('/shifts/cash-log', data: {
        'id': logId,
        'shift_id': shiftId,
        'type': type,
        'amount': amount,
        'note': note,
        'created_at': now.toIso8601String(),
      });
    } catch (_) {
      // Offline fallback
    }
  }
}
