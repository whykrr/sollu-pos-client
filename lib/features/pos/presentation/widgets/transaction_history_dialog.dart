import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';

class TransactionHistoryDialog extends ConsumerWidget {
  const TransactionHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const TransactionHistoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(currentShiftTransactionsProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SolluColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, color: SolluColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Riwayat Transaksi (F9)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SolluColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SolluColors.neutral),
            ),
            child: const Text(
              'Shift Saat Ini',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SolluColors.textMuted),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        height: 440,
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: SolluColors.neutralMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('Belum ada transaksi di shift ini', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                    const SizedBox(height: 4),
                    const Text('Transaksi yang diselesaikan kasir akan muncul di sini secara real-time.', style: TextStyle(color: SolluColors.textMuted, fontSize: 12)),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final timeStr = DateFormat('HH:mm:ss').format(tx.createdAt);
                final isPaid = tx.paymentStatus == 'paid';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SolluColors.neutral),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                      fontSize: 11,
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
                                      'Offline',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SolluColors.secondaryDark),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pukul $timeStr • ${tx.promoName != null ? "Promo: ${tx.promoName} • " : ""}${tx.channel.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(tx.total.toInt()),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SolluColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Mencetak ulang struk ${tx.transactionNumber}...'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: SolluColors.secondary,
                                ),
                              );

                              final result = await printTransactionReceiptAction(
                                ref: ref,
                                transactionId: tx.id,
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
                            icon: const Icon(Icons.print_outlined, size: 14),
                            label: const Text('Cetak Struk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SolluColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Gagal memuat riwayat: $err')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup (Esc)', style: TextStyle(color: SolluColors.textMuted)),
        ),
      ],
    );
  }
}
