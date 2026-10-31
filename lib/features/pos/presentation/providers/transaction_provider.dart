import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shift/presentation/providers/shift_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final dioClient = ref.watch(dioClientProvider);
  final outletSettings = ref.watch(outletSettingsServiceProvider);
  final shiftRepository = ref.watch(shiftRepositoryProvider);
  return TransactionRepository(
    database,
    dioClient,
    outletSettings,
    shiftRepository,
  );
});

/// Stream metode pembayaran aktif dari SQLite lokal (diurutkan otomatis standar industri platform POS)
final activePaymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);

  int getPaymentTypePriority(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return 1;
      case 'qris':
        return 2;
      case 'edc':
        return 3;
      case 'ewallet':
        return 4;
      case 'bank_transfer':
      case 'transfer':
        return 5;
      default:
        return 6;
    }
  }

  return repository.watchActivePaymentMethods().map((methods) {
    final sorted = List<PaymentMethod>.from(methods);
    sorted.sort((a, b) {
      final priorityA = getPaymentTypePriority(a.type);
      final priorityB = getPaymentTypePriority(b.type);
      final comparePriority = priorityA.compareTo(priorityB);
      if (comparePriority != 0) return comparePriority;

      final compareSystem = (b.isSystem ? 1 : 0).compareTo(a.isSystem ? 1 : 0);
      if (compareSystem != 0) return compareSystem;

      return a.name.compareTo(b.name);
    });
    return sorted;
  });
});

/// Stream promo aktif yang berlaku hari ini dari SQLite lokal
final activePromosProvider = StreamProvider<List<Promo>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchActivePromos();
});

/// Stream data pelanggan dari SQLite lokal
final customersProvider = StreamProvider<List<Customer>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchCustomers();
});

// ============================================================================
// CRM Customer Selection Provider
// ============================================================================

/// Notifier untuk customer / member CRM yang sedang dipilih di kasir POS
class SelectedCustomerNotifier extends Notifier<Customer?> {
  @override
  Customer? build() => null;

  void selectCustomer(Customer? customer) {
    state = customer;
  }

  void clearCustomer() {
    state = null;
  }

  @override
  set state(Customer? value) => super.state = value;
}

final selectedCustomerProvider =
    NotifierProvider<SelectedCustomerNotifier, Customer?>(
  SelectedCustomerNotifier.new,
);

/// Stream transaksi untuk shift yang sedang aktif
final currentShiftTransactionsProvider = StreamProvider<List<Transaction>>((
  ref,
) {
  final repository = ref.watch(transactionRepositoryProvider);
  final activeShiftAsync = ref.watch(activeShiftProvider);

  return activeShiftAsync.when(
    data: (shift) {
      if (shift == null) return Stream.value([]);
      return repository.watchCurrentShiftTransactions(shift.id);
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

/// Stream jumlah transaksi yang gagal disinkronkan (Dead-Letter Queue)
final failedTransactionsCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchFailedTransactionsCount();
});

/// Filter pencarian riwayat transaksi
class TransactionFilterState {
  final String query;
  final DateTime? date;
  final String? channel;
  final String? syncStatus;

  const TransactionFilterState({
    this.query = '',
    this.date,
    this.channel,
    this.syncStatus,
  });

  TransactionFilterState copyWith({
    String? query,
    DateTime? date,
    bool clearDate = false,
    String? channel,
    bool clearChannel = false,
    String? syncStatus,
    bool clearSyncStatus = false,
  }) {
    return TransactionFilterState(
      query: query ?? this.query,
      date: clearDate ? null : (date ?? this.date),
      channel: clearChannel ? null : (channel ?? this.channel),
      syncStatus: clearSyncStatus ? null : (syncStatus ?? this.syncStatus),
    );
  }
}

class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() => const TransactionFilterState();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void clearDate() {
    state = state.copyWith(clearDate: true);
  }

  void setChannel(String? channel) {
    if (channel == null || channel.isEmpty) {
      state = state.copyWith(clearChannel: true);
    } else {
      state = state.copyWith(channel: channel);
    }
  }

  void setSyncStatus(String? syncStatus) {
    if (syncStatus == null || syncStatus.isEmpty) {
      state = state.copyWith(clearSyncStatus: true);
    } else {
      state = state.copyWith(syncStatus: syncStatus);
    }
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );

/// Stream seluruh transaksi dengan filter pencarian, tanggal, dan status sinkronisasi
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);

  return repository.watchAllTransactions(
    searchQuery: filter.query.trim().isEmpty ? null : filter.query.trim(),
    date: filter.date,
    channel: filter.channel,
    syncStatus: filter.syncStatus,
  );
});

final paymentMethodSummaryProvider = StreamProvider<List<PaymentMethodSummary>>(
  (ref) {
    final repository = ref.watch(transactionRepositoryProvider);
    final filter = ref.watch(transactionFilterProvider);

    return repository.watchPaymentMethodSummary(
      searchQuery: filter.query.trim().isEmpty ? null : filter.query.trim(),
      date: filter.date,
      channel: filter.channel,
    );
  },
);

/// Future provider untuk rincian 1 transaksi
final transactionDetailProvider =
    FutureProvider.family<TransactionDetailData?, String>((ref, transactionId) {
      final repository = ref.watch(transactionRepositoryProvider);
      return repository.getTransactionDetails(transactionId);
    });

/// Stream jumlah transaksi pending yang belum tersinkron
final unsyncedTransactionsCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchUnsyncedTransactionsCount();
});

