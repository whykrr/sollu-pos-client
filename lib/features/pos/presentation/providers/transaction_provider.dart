import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shift/presentation/providers/shift_provider.dart';
import '../../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final dioClient = ref.watch(dioClientProvider);
  return TransactionRepository(database, dioClient);
});

/// Stream metode pembayaran aktif dari SQLite lokal
final activePaymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchActivePaymentMethods();
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

/// Stream transaksi untuk shift yang sedang aktif
final currentShiftTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
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

/// Filter pencarian riwayat transaksi
class TransactionFilterState {
  final String query;
  final DateTime? date;
  final String? channel;

  const TransactionFilterState({this.query = '', this.date, this.channel});

  TransactionFilterState copyWith({
    String? query,
    DateTime? date,
    bool clearDate = false,
    String? channel,
    bool clearChannel = false,
  }) {
    return TransactionFilterState(
      query: query ?? this.query,
      date: clearDate ? null : (date ?? this.date),
      channel: clearChannel ? null : (channel ?? this.channel),
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
}

final transactionFilterProvider = NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(TransactionFilterNotifier.new);

/// Stream seluruh transaksi dengan filter pencarian dan tanggal
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);

  return repository.watchAllTransactions(
    searchQuery: filter.query.trim().isEmpty ? null : filter.query.trim(),
    date: filter.date,
    channel: filter.channel,
  );
});

final paymentMethodSummaryProvider = StreamProvider<List<PaymentMethodSummary>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);
  
  return repository.watchPaymentMethodSummary(
    searchQuery: filter.query.trim().isEmpty ? null : filter.query.trim(),
    date: filter.date,
    channel: filter.channel,
  );
});

/// Future provider untuk rincian 1 transaksi
final transactionDetailProvider = FutureProvider.family<TransactionDetailData?, String>((ref, transactionId) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactionDetails(transactionId);
});
