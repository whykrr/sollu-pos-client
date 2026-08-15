import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';

class HoldOrdersDialog extends ConsumerWidget {
  const HoldOrdersDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const HoldOrdersDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdOrders = ref.watch(holdCartProvider);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SolluColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pause_circle_outline, color: SolluColors.warning, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Transaksi Ditahan (F7)',
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
            child: Text(
              '${holdOrders.length} Pesanan',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SolluColors.textMuted),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 380,
        child: holdOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: SolluColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada transaksi yang sedang ditahan',
                      style: TextStyle(color: SolluColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: holdOrders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = holdOrders[index];
                  final totalQty = order.items.fold(0, (sum, i) => sum + i.qty);
                  final timeStr = "${order.heldAt.hour.toString().padLeft(2, '0')}:${order.heldAt.minute.toString().padLeft(2, '0')}";

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SolluColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SolluColors.neutral),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.customerName ?? order.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: SolluColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: SolluColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      timeStr,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SolluColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$totalQty item • ${CurrencyFormatter.format(order.subtotal.toInt())}',
                                style: const TextStyle(fontSize: 13, color: SolluColors.textMuted, fontWeight: FontWeight.w500),
                              ),
                              if (order.note != null && order.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Catatan: ${order.note}',
                                  style: TextStyle(fontSize: 12, color: SolluColors.textDark.withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: SolluColors.danger, size: 20),
                              tooltip: 'Hapus Pesanan Ditahan',
                              onPressed: () {
                                ref.read(holdCartProvider.notifier).removeHoldOrder(order.id);
                              },
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () {
                                // Restore items to cart
                                final currentCart = ref.read(cartProvider);
                                if (currentCart.isNotEmpty) {
                                  // Ask or auto hold current cart / merge
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mengganti keranjang saat ini dengan transaksi tertahan...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                ref.read(cartProvider.notifier).clearCart();
                                for (final item in order.items) {
                                  ref.read(cartProvider.notifier).addItem(item);
                                }
                                ref.read(holdCartProvider.notifier).removeHoldOrder(order.id);
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Transaksi ${order.id} berhasil dimuat kembali!'),
                                    backgroundColor: SolluColors.success,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SolluColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Muat Transaksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
