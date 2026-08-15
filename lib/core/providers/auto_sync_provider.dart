import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';

enum AutoSyncStatus { idle, syncing, success, error }

class AutoSyncState {
  final AutoSyncStatus status;
  final String? message;

  const AutoSyncState({
    this.status = AutoSyncStatus.idle,
    this.message,
  });

  AutoSyncState copyWith({
    AutoSyncStatus? status,
    String? message,
  }) {
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

    // Setup periodic check every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkAndSync();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return const AutoSyncState();
  }

  Future<void> _checkAndSync() async {
    // Don't start sync if already syncing
    if (state.status == AutoSyncStatus.syncing) return;

    final lastSync = ref.read(lastSyncProvider);
    final now = DateTime.now();
    bool shouldSync = false;

    if (lastSync == null) {
      // Rule 1: No data at all (first time install)
      shouldSync = true;
    } else {
      // Rule 2: More than 6 hours since last sync
      final diff = now.difference(lastSync);
      if (diff.inHours >= 6) {
        shouldSync = true;
      }
    }

    if (shouldSync) {
      await forceSync();
    } else {
      // Rule 3: Unsynced transactions > 10
      try {
        final txRepo = ref.read(transactionRepositoryProvider);
        final unsyncedCount = await txRepo.getUnsyncedTransactionsCount();
        if (unsyncedCount > 10) {
          await txRepo.syncPendingTransactions();
        }
      } catch (_) {}
    }
  }

  Future<void> forceSync() async {
    if (state.status == AutoSyncStatus.syncing) return;

    state = state.copyWith(status: AutoSyncStatus.syncing, message: 'Menyinkronkan data...');

    try {
      final syncRepository = ref.read(syncRepositoryProvider);
      await syncRepository.syncMasterData();
      
      // Update the timestamp so it knows when the last sync happened
      await ref.read(lastSyncProvider.notifier).updateTimestamp();
      
      // Optionally sync employees as well
      try {
        final employeeRepository = ref.read(employeeRepositoryProvider);
        await employeeRepository.syncEmployees();
      } catch (_) {
        // Ignore employee sync error as it's secondary
      }

      state = state.copyWith(status: AutoSyncStatus.success, message: 'Sinkronisasi selesai.');
      
      // Auto dismiss success state after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (state.status == AutoSyncStatus.success) {
          state = state.copyWith(status: AutoSyncStatus.idle);
        }
      });
    } catch (e) {
      state = state.copyWith(status: AutoSyncStatus.error, message: 'Sinkronisasi gagal: $e');
      
      // Auto dismiss error state after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (state.status == AutoSyncStatus.error) {
          state = state.copyWith(status: AutoSyncStatus.idle);
        }
      });
    }
  }
  
  void dismiss() {
    state = state.copyWith(status: AutoSyncStatus.idle);
  }
}

final autoSyncProvider = NotifierProvider<AutoSyncNotifier, AutoSyncState>(AutoSyncNotifier.new);
