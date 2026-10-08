import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/sollu_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';
import '../providers/promo_provider.dart';
import '../../../settings/presentation/providers/outlet_settings_provider.dart';

class CheckoutCartPane extends ConsumerWidget {
  const CheckoutCartPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final appliedDiscount = ref.watch(appliedDiscountProvider);
    final taxRate = ref.watch(activeTaxRateProvider);
    final serviceChargeRate = ref.watch(activeServiceChargeRateProvider);

    final double subtotal = cart.fold(
      0.0,
      (sum, item) => sum + item.calculatedSubtotal,
    );
    final double discountAmount = appliedDiscount != null
        ? appliedDiscount.calculateDiscount(subtotal)
        : 0.0;
    final double taxableAmount = (subtotal - discountAmount).clamp(
      0.0,
      double.infinity,
    );

    final double taxAmount =
        taxRate > 0 ? (taxableAmount * (taxRate / 100.0)) : 0.0;
    final double serviceChargeAmount = serviceChargeRate > 0
        ? (taxableAmount * (serviceChargeRate / 100.0))
        : 0.0;
    final double grandTotal = taxableAmount + taxAmount + serviceChargeAmount;

    return Container(
      decoration: BoxDecoration(
        color: SolluColors.surface,
        border: Border(
          right: BorderSide(
            color: SolluColors.neutral,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Pane
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: SolluColors.background,
              border: Border(
                bottom: BorderSide(
                  color: SolluColors.neutral,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SolluColors.textDark,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SolluColors.neutral, width: 1.0),
                  ),
                  child: Text(
                    '${cart.length} Item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SolluColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List Items
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'Keranjang belanja kosong',
                      style: TextStyle(
                        fontSize: 14,
                        color: SolluColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const Divider(
                      color: SolluColors.background,
                      height: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Qty badge
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: SolluColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: SolluColors.neutral,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '${item.qty}x',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: SolluColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and notes
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SolluColors.textDark,
                                  ),
                                ),
                                if (item.notes != null &&
                                    item.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: SolluColors.textMuted,
                                    ),
                                  ),
                                ],
                                Text(
                                  '@ ${CurrencyFormatter.format(item.price.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: SolluColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Subtotal item
                          Text(
                            CurrencyFormatter.format(
                              item.calculatedSubtotal.toInt(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SolluColors.textDark,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Cost Breakdown Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SolluColors.surface,
              border: Border(
                top: BorderSide(
                  color: SolluColors.neutral,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtotal
                _buildSummaryRow(
                  label: 'Subtotal',
                  value: CurrencyFormatter.format(subtotal.toInt()),
                ),

                // Diskon jika ada
                if (discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    label: 'Diskon (${appliedDiscount?.name ?? 'Promo'})',
                    value:
                        '- ${CurrencyFormatter.format(discountAmount.toInt())}',
                    valueColor: SolluColors.danger,
                  ),
                ],

                // Pajak HANYA MUNCUL jika taxRate > 0 dan taxAmount > 0
                if (taxRate > 0 && taxAmount > 0) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    label:
                        'Pajak (${taxRate.toStringAsFixed(taxRate.truncateToDouble() == taxRate ? 0 : 1)}%)',
                    value: CurrencyFormatter.format(taxAmount.toInt()),
                  ),
                ],

                // Service Charge HANYA MUNCUL jika serviceChargeRate > 0 dan serviceChargeAmount > 0
                if (serviceChargeRate > 0 && serviceChargeAmount > 0) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    label:
                        'Biaya Layanan (${serviceChargeRate.toStringAsFixed(serviceChargeRate.truncateToDouble() == serviceChargeRate ? 0 : 1)}%)',
                    value: CurrencyFormatter.format(serviceChargeAmount.toInt()),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(color: SolluColors.neutral, height: 1),
                const SizedBox(height: 12),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SolluColors.textDark,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(grandTotal.toInt()),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: SolluColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color valueColor = SolluColors.textDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: SolluColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
