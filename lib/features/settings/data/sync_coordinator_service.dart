import 'package:flutter/foundation.dart';
import '../../pos/data/transaction_repository.dart';
import '../../shift/data/shift_repository.dart';
import 'sync_repository.dart';

class SyncSummaryResult {
  final int syncedTransactionsCount;
  final int failedTransactionsCount;
  final int syncedShiftsCount;
  final bool masterDataSuccess;
  final String? errorMessage;
  final DateTime syncedAt;

  const SyncSummaryResult({
    required this.syncedTransactionsCount,
    required this.failedTransactionsCount,
    required this.syncedShiftsCount,
    required this.masterDataSuccess,
    this.errorMessage,
    required this.syncedAt,
  });

  bool get hasFailures => failedTransactionsCount > 0 || !masterDataSuccess;

  /// Pesan yang ramah bagi kasir tanpa istilah teknis
  String get userFriendlyMessage {
    if (errorMessage != null && !masterDataSuccess && syncedTransactionsCount == 0) {
      return errorMessage!;
    }

    if (syncedTransactionsCount > 0 && failedTransactionsCount > 0) {
      return '$syncedTransactionsCount transaksi terkirim, $failedTransactionsCount butuh perhatian (cek Riwayat Transaksi).';
    }

    if (syncedTransactionsCount > 0) {
      return '$syncedTransactionsCount transaksi terkirim & data produk telah diperbarui.';
    }

    if (failedTransactionsCount > 0) {
      return '$failedTransactionsCount transaksi belum terkirim (cek Riwayat Transaksi).';
    }

    return 'Sinkronisasi selesai! Data transaksi dan produk telah diperbarui.';
  }
}

class SyncCoordinatorService {
  final ShiftRepository _shiftRepository;
  final TransactionRepository _transactionRepository;
  final SyncRepository _syncRepository;
  bool _isSyncing = false;

  SyncCoordinatorService(
    this._shiftRepository,
    this._transactionRepository,
    this._syncRepository,
  );

  bool get isSyncing => _isSyncing;

  /// Menjalankan Two-Phase Reconciled Sync:
  /// Fase 1: Outbound (Shift, Cash Log, Transaksi Pending FIFO)
  /// Fase 2: Inbound (Penyelarasan Stok & Data Katalog Master)
  Future<SyncSummaryResult> synchronizeAll({bool forceFullMaster = false}) async {
    if (_isSyncing) {
      throw Exception('Sinkronisasi sedang berlangsung. Mohon tunggu.');
    }

    _isSyncing = true;
    try {
      int syncedShifts = 0;
      int syncedTx = 0;
      bool masterSuccess = false;
      String? masterError;

      // 1. Fase Outbound: Kirim Shift & Cash Log terlebih dahulu
      // Agar backend mengenali shift_id saat transaksi diverifikasi
      try {
        await _shiftRepository.syncPendingShifts();
        await _shiftRepository.syncPendingCashLogs();
        syncedShifts++;
      } catch (e) {
        debugPrint('[SyncCoordinator] Error syncing shifts: $e');
      }

      // 2. Fase Outbound: Kirim antrean transaksi lokal pending (FIFO)
      try {
        syncedTx = await _transactionRepository.syncPendingTransactions();
      } catch (e) {
        debugPrint('[SyncCoordinator] Error syncing transactions: $e');
      }

      // Ambil transaksi yang berstatus gagal (Dead-Letter Queue)
      int failedCount = 0;
      try {
        final failedTxList = await _transactionRepository.getFailedTransactions();
        failedCount = failedTxList.length;
      } catch (e) {
        debugPrint('[SyncCoordinator] Error counting failed transactions: $e');
      }

      // 3. Fase Inbound: Unduh data katalog dan stok terbaru
      DateTime syncedAt = DateTime.now();
      try {
        if (forceFullMaster) {
          await _syncRepository.syncMasterData();
        } else {
          syncedAt = await _syncRepository.syncDeltaData();
        }
        masterSuccess = true;
      } catch (e) {
        masterSuccess = false;
        masterError = 'Tidak dapat terhubung ke server. Data transaksi tetap aman di perangkat kasir.';
        debugPrint('[SyncCoordinator] Error syncing master data: $e');
      }

      return SyncSummaryResult(
        syncedTransactionsCount: syncedTx,
        failedTransactionsCount: failedCount,
        syncedShiftsCount: syncedShifts,
        masterDataSuccess: masterSuccess,
        errorMessage: masterError,
        syncedAt: syncedAt,
      );
    } finally {
      _isSyncing = false;
    }
  }
}
