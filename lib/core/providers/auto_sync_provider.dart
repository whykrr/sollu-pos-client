import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

enum AutoSyncStatus { idle, syncing, success, error }

class AutoSyncState {
  final AutoSyncStatus status;
  final String? message;

  const AutoSyncState({this.status = AutoSyncStatus.idle, this.message});

  AutoSyncState copyWith({AutoSyncStatus? status, String? message}) {
    return AutoSyncState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class AutoSyncNotifier extends Notifier<AutoSyncState> {
  Timer? _timer;

  @override
  AutoSyncState build() {
    // Schedule initial check
    Future.microtask(() => _checkAndSync());

    // Listen to network connectivity changes for Strict Reconnection Pipeline
    ref.listen<bool>(connectivityProvider, (previous, current) {
      if (previous == false && current == true) {
        debugPrint('[AutoSync] Network reconnected. Executing Strict Reconnection Pipeline...');
        _onReconnected();
      }
    });

    // Setup heartbeat periodic delta check every 10 minutes
    _timer = Timer.periodic(const Duration(minutes: 10), (_) {
      _checkAndSync();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return const AutoSyncState();
  }

  /// Strict Reconnection Pipeline:
  /// (1) Eksekusi Delta Sync terlebih dahulu untuk menyegarkan katalog & stok
  /// (2) Sinkronisasi antrean shift & cash log
  /// (3) Eksekusi pengiriman antrean transaksi lokal pending FIFO
  Future<void> _onReconnected() async {
    if (state.status == AutoSyncStatus.syncing) return;

    try {
      final lastSync = ref.read(lastSyncProvider);
      if (lastSync == null) {
        await forceSync();
      } else {
        // Step 1: Delta Sync
        final deltaService = ref.read(deltaSyncServiceProvider);
        final syncedAt = await deltaService.syncDeltaCatalog();
        await ref.read(lastSyncProvider.notifier).updateWithTimestamp(syncedAt);
        ref.invalidate(employeeListProvider);
      }

      // Step 2: Push pending shifts & cash logs
      final shiftRepo = ref.read(shiftRepositoryProvider);
      await shiftRepo.syncPendingShifts();
      await shiftRepo.syncPendingCashLogs();

      // Step 3: Push pending transactions FIFO
      final txRepo = ref.read(transactionRepositoryProvider);
      await txRepo.syncPendingTransactions();
    } catch (e) {
      debugPrint('[AutoSync] Error during reconnection pipeline: $e');
    }
  }

  Future<void> _checkAndSync() async {
    // Don't start sync if already syncing
    if (state.status == AutoSyncStatus.syncing) return;

    final isOnline = ref.read(connectivityProvider);
    if (!isOnline) return;

    final lastSync = ref.read(lastSyncProvider);

    if (lastSync == null) {
      // First time installation or after device unpair -> Initial full sync
      await forceSync();
      return;
    }

    try {
      // Step 1: Incremental Heartbeat Delta Sync
      final deltaService = ref.read(deltaSyncServiceProvider);
      final syncedAt = await deltaService.syncDeltaCatalog();
      await ref.read(lastSyncProvider.notifier).updateWithTimestamp(syncedAt);

      // Step 2: Push unsynced local data
      final shiftRepo = ref.read(shiftRepositoryProvider);
      await shiftRepo.syncPendingShifts();
      await shiftRepo.syncPendingCashLogs();

      final txRepo = ref.read(transactionRepositoryProvider);
      final unsyncedCount = await txRepo.getUnsyncedTransactionsCount();
      if (unsyncedCount > 0) {
        await txRepo.syncPendingTransactions();
      }
    } catch (e) {
      debugPrint('[AutoSync] Heartbeat delta check error: $e');
    }
  }

  /// Memaksa Initial Sync Snapshot (misal saat bootstrapping atau manual refresh di UI)
  Future<void> forceSync() async {
    if (state.status == AutoSyncStatus.syncing) return;

    state = state.copyWith(
      status: AutoSyncStatus.syncing,
      message: 'Menyinkronkan data...',
    );

    try {
      final syncRepository = ref.read(syncRepositoryProvider);
      await syncRepository.syncMasterData();

      // Update the timestamp
      await ref.read(lastSyncProvider.notifier).updateTimestamp();

      // Invalidate employee list so UI reflects newly synced employees
      ref.invalidate(employeeListProvider);

      state = state.copyWith(
        status: AutoSyncStatus.success,
        message: 'Sinkronisasi selesai.',
      );

      // Auto dismiss success state after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (state.status == AutoSyncStatus.success) {
          state = state.copyWith(status: AutoSyncStatus.idle);
        }
      });
    } catch (e) {
      state = state.copyWith(
        status: AutoSyncStatus.error,
        message: 'Sinkronisasi gagal: $e',
      );

      // Auto dismiss error state after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (state.status == AutoSyncStatus.error) {
          state = state.copyWith(status: AutoSyncStatus.idle);
        }
      });
    }
  }

  /// Trigger delta sync secara langsung (misal saat sinyal WebSocket Reverb diterima)
  Future<void> triggerDeltaSync({List<String>? entities}) async {
    if (state.status == AutoSyncStatus.syncing) return;

    try {
      final lastSync = ref.read(lastSyncProvider);
      if (lastSync == null) {
        await forceSync();
        return;
      }

      final deltaService = ref.read(deltaSyncServiceProvider);
      final syncedAt = await deltaService.syncDeltaCatalog(entities: entities);
      await ref.read(lastSyncProvider.notifier).updateWithTimestamp(syncedAt);
    } catch (e) {
      debugPrint('[AutoSync] Error triggering delta sync: $e');
    }
  }

  void dismiss() {
    state = state.copyWith(status: AutoSyncStatus.idle);
  }
}

final autoSyncProvider = NotifierProvider<AutoSyncNotifier, AutoSyncState>(
  AutoSyncNotifier.new,
);
