/// Transaction Status Enums - SSOT synchronized with Laravel backend
enum TransactionStatus {
  draft('draft', 'Draf'),
  hold('hold', 'Ditahan'),
  completed('completed', 'Selesai'),
  voided('void', 'Dibatalkan (Void)'),
  cancelled('cancel', 'Batal');

  final String value;
  final String label;
  const TransactionStatus(this.value, this.label);

  static TransactionStatus fromValue(String? value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}

/// Financial Settlement Status - SSOT synchronized with Laravel backend
enum TransactionPaymentStatus {
  draft('draft', 'Draf'),
  unpaid('unpaid', 'Belum Dibayar'),
  partial('partial', 'Dibayar Sebagian'),
  paid('paid', 'Lunas');

  final String value;
  final String label;
  const TransactionPaymentStatus(this.value, this.label);

  static TransactionPaymentStatus fromValue(String? value) {
    return TransactionPaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionPaymentStatus.paid,
    );
  }
}

/// Offline Sync Lifecycle Status for Transactions Queue
enum SyncStatus {
  pending('pending', 'Menunggu'),
  syncing('syncing', 'Menyinkronkan'),
  synced('synced', 'Tersinkron'),
  failed('failed', 'Gagal');

  final String value;
  final String label;
  const SyncStatus(this.value, this.label);

  static SyncStatus fromValue(String? value) {
    return SyncStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncStatus.pending,
    );
  }
}
