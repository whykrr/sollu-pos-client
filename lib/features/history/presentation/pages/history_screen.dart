import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetails(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final detailAsync = ref.watch(transactionDetailProvider(transactionId));

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: SizedBox(
              width: 500,
              child: detailAsync.when(
                data: (detail) {
                  if (detail == null) {
                    return const Center(child: Text('Data transaksi tidak ditemukan.'));
                  }

                  final tx = detail.transaction;
                  final timeStr = DateFormat('dd MMM yyyy, HH:mm:ss').format(tx.createdAt);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.transactionNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(timeStr, style: const TextStyle(fontSize: 12, color: SolluColors.textMuted)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: SolluColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tx.paymentStatus.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SolluColors.success),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: SolluColors.neutral),
                        const SizedBox(height: 12),
                        const Text('Daftar Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark)),
                        const SizedBox(height: 8),
                        ...detail.items.map((item) {
                          final mods = detail.modifiersByItemId[item.id] ?? [];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.qty.toInt()}x ${item.productName}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: SolluColors.textDark),
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.subtotal.toInt()),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark),
                                    ),
                                  ],
                                ),
                                if (mods.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14, top: 2),
                                    child: Text(
                                      'Modifier: ${mods.map((m) => m.modifierName).join(", ")}',
                                      style: const TextStyle(fontSize: 11, color: SolluColors.textMuted),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        const Divider(color: SolluColors.neutral),
                        const SizedBox(height: 12),
                        // Financial Summary
                        _buildDetailRow('Subtotal', CurrencyFormatter.format(tx.subtotal.toInt())),
                        if (tx.discountAmount > 0)
                          _buildDetailRow(
                            'Diskon ${tx.promoName != null ? "(${tx.promoName})" : ""}',
                            '- ${CurrencyFormatter.format(tx.discountAmount.toInt())}',
                            isGreen: true,
                          ),
                        if (tx.serviceChargeAmount > 0)
                          _buildDetailRow('Service Charge', CurrencyFormatter.format(tx.serviceChargeAmount.toInt())),
                        if (tx.taxAmount > 0)
                          _buildDetailRow('Pajak', CurrencyFormatter.format(tx.taxAmount.toInt())),
                        const SizedBox(height: 8),
                        const Divider(color: SolluColors.neutral),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SolluColors.textDark)),
                            Text(
                              CurrencyFormatter.format(tx.total.toInt()),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: SolluColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Payment details
                        if (detail.payments.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: SolluColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Metode: ${detail.paymentMethod?.name ?? "Tunai"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    if (tx.isOffline)
                                      const Text('Status: Tersimpan Lokal (Offline)', style: TextStyle(fontSize: 11, color: SolluColors.secondaryDark, fontWeight: FontWeight.bold))
                                    else
                                      const Text('Status: Tersinkronisasi', style: TextStyle(fontSize: 11, color: SolluColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (detail.payments.first.changeAmount > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kembalian: ${CurrencyFormatter.format(detail.payments.first.changeAmount.toInt())}',
                                    style: const TextStyle(fontSize: 12, color: SolluColors.success, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Gagal memuat detail: $err')),
              ),
            ),
            actions: [
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Mencetak ulang struk...'),
                      duration: Duration(seconds: 1),
                      backgroundColor: SolluColors.secondary,
                    ),
                  );

                  final result = await printTransactionReceiptAction(
                    ref: ref,
                    transactionId: transactionId,
                  );

                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            result.success ? Icons.check_circle : Icons.error_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(result.message)),
                        ],
                      ),
                      backgroundColor: result.success ? SolluColors.success : SolluColors.danger,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Cetak Struk'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolluColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: SolluColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isGreen ? SolluColors.success : SolluColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi Penjualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Cards
            transactionsAsync.when(
              data: (txList) {
                final double totalSales = txList.fold(0.0, (sum, tx) => sum + tx.total);
                final int totalCount = txList.length;

                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Penjualan',
                        value: CurrencyFormatter.format(totalSales.toInt()),
                        icon: Icons.monetization_on_outlined,
                        color: SolluColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Jumlah Transaksi',
                        value: '$totalCount Transaksi',
                        icon: Icons.receipt_long_outlined,
                        color: SolluColors.secondaryDark,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Payment Method Summary
            Consumer(
              builder: (context, ref, _) {
                final summaryAsync = ref.watch(paymentMethodSummaryProvider);
                return summaryAsync.when(
                  data: (summaries) {
                    if (summaries.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: summaries.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SolluColors.neutral),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s.methodName, style: const TextStyle(fontSize: 12, color: SolluColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(s.totalAmount.toInt()),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SolluColors.textDark),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Search & Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SolluColors.neutral),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(transactionFilterProvider.notifier).setQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nomor transaksi / invoice...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: filter.date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        ref.read(transactionFilterProvider.notifier).setDate(picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: filter.date != null ? SolluColors.primary : SolluColors.neutral),
                        borderRadius: BorderRadius.circular(10),
                        color: filter.date != null ? SolluColors.primary.withValues(alpha: 0.08) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: filter.date != null ? SolluColors.primary : SolluColors.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            filter.date != null ? DateFormat('dd MMM yyyy').format(filter.date!) : 'Semua Tanggal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: filter.date != null ? FontWeight.bold : FontWeight.normal,
                              color: filter.date != null ? SolluColors.primary : SolluColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: filter.channel != null ? SolluColors.primary : SolluColors.neutral),
                      borderRadius: BorderRadius.circular(10),
                      color: filter.channel != null ? SolluColors.primary.withValues(alpha: 0.08) : Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter.channel,
                        hint: const Text('Semua Metode', style: TextStyle(fontSize: 13, color: SolluColors.textDark)),
                        icon: const Icon(Icons.arrow_drop_down, color: SolluColors.textMuted),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: filter.channel != null ? FontWeight.bold : FontWeight.normal,
                          color: filter.channel != null ? SolluColors.primary : SolluColors.textDark,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Semua Metode')),
                          DropdownMenuItem(value: 'pos', child: Text('POS Kasir')),
                          DropdownMenuItem(value: 'direct', child: Text('Penjualan Langsung')),
                          DropdownMenuItem(value: 'invoice', child: Text('Invoice / PO')),
                        ],
                        onChanged: (val) {
                          ref.read(transactionFilterProvider.notifier).setChannel(val);
                        },
                      ),
                    ),
                  ),
                  if (filter.date != null || filter.query.isNotEmpty || filter.channel != null) ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(transactionFilterProvider.notifier).setQuery('');
                        ref.read(transactionFilterProvider.notifier).clearDate();
                        ref.read(transactionFilterProvider.notifier).setChannel(null);
                      },
                      icon: const Icon(Icons.clear, size: 16, color: SolluColors.danger),
                      label: const Text('Reset Filter', style: TextStyle(color: SolluColors.danger, fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Transactions Table / List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 56, color: SolluColors.neutralMuted.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            const Text('Tidak ada transaksi yang cocok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SolluColors.textDark)),
                            const SizedBox(height: 4),
                            const Text('Coba ubah kata kunci pencarian atau filter tanggal.', style: TextStyle(color: SolluColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: SolluColors.neutral),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);
                        final isPaid = tx.paymentStatus == 'paid';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: SolluColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt, color: SolluColors.primary, size: 22),
                          ),
                          title: Row(
                            children: [
                              Text(
                                tx.transactionNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SolluColors.textDark),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPaid ? SolluColors.success.withValues(alpha: 0.15) : SolluColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isPaid ? 'Lunas' : tx.paymentStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid ? SolluColors.success : SolluColors.warning,
                                  ),
                                ),
                              ),
                              if (tx.isOffline) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SolluColors.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Lokal Offline',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SolluColors.secondaryDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$dateStr • ${tx.promoName != null ? "Promo: ${tx.promoName} • " : ""}${tx.channel.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.format(tx.total.toInt()),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SolluColors.textDark),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _showTransactionDetails(context, tx.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SolluColors.primary.withValues(alpha: 0.1),
                                  foregroundColor: SolluColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Gagal memuat transaksi: $err')),
                ),
              ),
            ),
            
            // Footer Info Offline Sync
            transactionsAsync.when(
              data: (txList) {
                final offlineCount = txList.where((t) => t.isOffline).length;
                if (offlineCount == 0) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: SolluColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SolluColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: SolluColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Terdapat $offlineCount transaksi yang belum tersinkronisasi ke server (tersimpan offline).',
                          style: const TextStyle(fontSize: 13, color: SolluColors.textDark),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SolluColors.neutral),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: SolluColors.textMuted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SolluColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
