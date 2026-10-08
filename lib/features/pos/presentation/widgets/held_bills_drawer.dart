import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/sollu_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';
import '../providers/hold_cart_provider.dart';

class HeldBillsDrawer extends ConsumerWidget {
  const HeldBillsDrawer({super.key});

  static Future<void> showAsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 580,
          height: 600,
          decoration: BoxDecoration(
            color: SolluColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SolluColors.neutral, width: 1.0),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: HeldBillsDrawer(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBillsAsync = ref.watch(heldTransactionsStreamProvider);
    final service = ref.watch(heldBillsServiceProvider);
    final currentCart = ref.watch(cartProvider);

    return Container(
      color: SolluColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Drawer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: SolluColors.background,
              border: Border(
                bottom: BorderSide(color: SolluColors.neutral, width: 1.0),
              ),
            ),
            child: Row(
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
                      child: const Icon(
                        Icons.pause_circle_outline,
                        color: SolluColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Transaksi Ditahan (Hold)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SolluColors.textDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: SolluColors.textDark),
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: heldBillsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Gagal memuat transaksi: $err'),
              ),
              data: (bills) {
                if (bills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: SolluColors.neutralDark.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada transaksi yang sedang ditahan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: SolluColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bills.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return _buildBillCard(
                      context: context,
                      bill: bill,
                      currentCart: currentCart,
                      service: service,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard({
    required BuildContext context,
    required HeldTransaction bill,
    required List<CartItem> currentCart,
    required HeldBillsService service,
  }) {
    int itemCount = 0;
    try {
      final decoded = jsonDecode(bill.cartPayload) as List;
      itemCount = decoded.length;
    } catch (_) {}

    final timeFormatted = DateFormat('HH:mm').format(bill.heldAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SolluColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SolluColors.neutral, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Label & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.holdLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SolluColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  timeFormatted,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SolluColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Customer and table info if available
          if ((bill.customerName != null && bill.customerName!.isNotEmpty) ||
              (bill.tableNumber != null && bill.tableNumber!.isNotEmpty)) ...[
            Row(
              children: [
                if (bill.customerName != null &&
                    bill.customerName!.isNotEmpty) ...[
                  const Icon(Icons.person, size: 14, color: SolluColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    bill.customerName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SolluColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (bill.tableNumber != null &&
                    bill.tableNumber!.isNotEmpty) ...[
                  const Icon(Icons.table_restaurant,
                      size: 14, color: SolluColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Meja ${bill.tableNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: SolluColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Total and items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount Item',
                style: const TextStyle(
                  fontSize: 13,
                  color: SolluColors.textMuted,
                ),
              ),
              Text(
                CurrencyFormatter.format(bill.total.toInt()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: SolluColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: SolluColors.background, height: 1),
          const SizedBox(height: 12),

          // Action Buttons: Resume & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: SolluColors.danger, width: 1.0),
                  foregroundColor: SolluColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => _confirmDelete(context, bill, service),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolluColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => _handleResume(
                  context,
                  bill,
                  currentCart,
                  service,
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Lanjutkan (Resume)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleResume(
    BuildContext context,
    HeldTransaction bill,
    List<CartItem> currentCart,
    HeldBillsService service,
  ) async {
    if (currentCart.isNotEmpty) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: SolluColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: SolluColors.neutral, width: 1.0),
          ),
          title: const Text('Keranjang Sedang Berisi'),
          content: const Text(
            'Keranjang saat ini tidak kosong. Apakah Anda ingin menimpa keranjang saat ini untuk melanjutkan transaksi yang ditahan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        ),
      );

      if (shouldProceed != true) return;
    }

    final success = await service.resumeHeldBill(bill);
    if (context.mounted) {
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Transaksi '${bill.holdLabel}' berhasil dimuat kembali ke keranjang.",
            ),
            backgroundColor: SolluColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HeldTransaction bill,
    HeldBillsService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SolluColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: SolluColors.neutral, width: 1.0),
        ),
        title: const Text('Hapus Transaksi Ditahan?'),
        content: Text(
          "Apakah Anda yakin ingin menghapus transaksi '${bill.holdLabel}'? Data tidak dapat dipulihkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.deleteHeldBill(bill.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Transaksi '${bill.holdLabel}' telah dihapus."),
            backgroundColor: SolluColors.textMuted,
          ),
        );
      }
    }
  }
}
