import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'fast_retail_keyboard_guide_dialog.dart';

/// Fast Retail Cockpit Standar Industri (Panel Kanan Kasir Cepat)
/// Memuat konfirmasi visual instan, ringkasan finansial, total raksasa 36sp, dan action deck.
class FastRetailCockpit extends ConsumerWidget {
  final VoidCallback? onPay;
  final VoidCallback? onHold;
  final VoidCallback? onRecall;
  final VoidCallback? onDiscount;
  final VoidCallback? onDeleteRow;
  final VoidCallback? onCancelCart;
  final VoidCallback? onOpenGuide;
  final VoidCallback? onChangeCustomer;

  const FastRetailCockpit({
    super.key,
    this.onPay,
    this.onHold,
    this.onRecall,
    this.onDiscount,
    this.onDeleteRow,
    this.onCancelCart,
    this.onOpenGuide,
    this.onChangeCustomer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final lastScannedItem = ref.watch(lastScannedCartItemProvider) ?? cart.lastOrNull;
    final appliedDiscount = ref.watch(appliedDiscountProvider);
    final activeEmployee = ref.watch(activeEmployeeProvider);
    final activeShift = ref.watch(activeShiftProvider).asData?.value;
    final featureGating = ref.watch(featureGatingProvider);
    final taxRate = ref.watch(activeTaxRateProvider);
    final serviceChargeRate = ref.watch(activeServiceChargeRateProvider);
    final taxIncluded = ref.watch(taxIncludedInPriceProvider);
    final heldBillsAsync = ref.watch(heldTransactionsStreamProvider);
    final heldCount = heldBillsAsync.asData?.value.length ?? 0;

    // Financial calculations
    final double subtotal = cart.fold(0.0, (sum, it) => sum + it.calculatedSubtotal);
    final double discountAmount = appliedDiscount != null
        ? appliedDiscount.calculateDiscount(subtotal)
        : 0.0;
    final double taxableAmount = (subtotal - discountAmount).clamp(0.0, double.infinity);
    final double tax = calculateTaxAmount(
      taxableAmount: taxableAmount,
      taxRate: taxRate,
      taxIncludedInPrice: taxIncluded,
    );
    final double serviceCharge = taxableAmount * (serviceChargeRate / 100.0);
    final double grandTotal = calculateGrandTotal(
      taxableAmount: taxableAmount,
      taxAmount: tax,
      serviceChargeAmount: serviceCharge,
      taxIncludedInPrice: taxIncluded,
    );

    final int totalPcs = cart.fold(0, (sum, it) => sum + it.qty);

    final String cashierName = activeEmployee?['name']?.toString() ?? 'Kasir';
    final String timeNow = DateFormat('HH:mm:ss').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: SolluColors.neutral, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Session & Cashier Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: SolluColors.neutral, width: 1.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeShift != null
                          ? 'Shift #${activeShift.shiftNumber} • $cashierName'
                          : cashierName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SolluColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pukul $timeNow WIB',
                      style: const TextStyle(fontSize: 11, color: SolluColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SolluColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'KASIR AKTIF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SolluColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Middle Cockpit Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. HERO CARD: Last Scanned Item (Instant Visual Confirmation)
                  _buildLastScannedHeroCard(lastScannedItem),

                  const SizedBox(height: 16),

                  // 3. Customer / CRM Card
                  _buildCustomerCrmCard(context, featureGating.canUseCrm()),

                  const SizedBox(height: 16),

                  // 4. Financial Breakdown
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SolluColors.neutral, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryLine(
                          'Total Item (Kuantitas)',
                          '${cart.length} Item ($totalPcs Pcs)',
                          isMuted: true,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryLine(
                          'Subtotal',
                          CurrencyFormatter.format(subtotal.toInt()),
                        ),
                        if (discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryLine(
                            appliedDiscount?.name ?? 'Diskon Nota',
                            '- ${CurrencyFormatter.format(discountAmount.toInt())}',
                            valueColor: SolluColors.danger,
                          ),
                        ],
                        if (tax > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryLine(
                            taxIncluded ? 'PPN (${taxRate.toInt()}%) Termasuk' : 'PPN (${taxRate.toInt()}%)',
                            CurrencyFormatter.format(tax.toInt()),
                            isMuted: taxIncluded,
                          ),
                        ],
                        if (serviceCharge > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryLine(
                            'Service Charge (${serviceChargeRate.toInt()}%)',
                            CurrencyFormatter.format(serviceCharge.toInt()),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. GIANT RUNNING GRAND TOTAL (36-40sp bold)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: SolluColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SolluColors.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL TAGIHAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: SolluColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            CurrencyFormatter.format(grandTotal.toInt()),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: SolluColors.primary,
                              letterSpacing: -0.5,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Operational Action Deck
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: SolluColors.neutral, width: 1.0),
              ),
            ),
            child: Column(
              children: [
                // Secondary Action Buttons Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryButton(
                        label: '[Hold] Tahan',
                        icon: Icons.pause_circle_outline,
                        onTap: onHold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSecondaryButton(
                        label: heldCount > 0 ? '[Recall] ($heldCount)' : '[Recall] Tagihan',
                        icon: Icons.receipt_long_outlined,
                        badgeCount: heldCount,
                        onTap: onRecall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSecondaryButton(
                        label: appliedDiscount != null ? 'Promo Aktif' : '[Diskon] Nota',
                        icon: Icons.discount_outlined,
                        isActive: appliedDiscount != null,
                        onTap: onDiscount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryButton(
                        label: '[Del] Hapus Baris',
                        icon: Icons.delete_outline,
                        textColor: SolluColors.danger,
                        onTap: onDeleteRow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSecondaryButton(
                        label: '[Esc] Batal',
                        icon: Icons.cancel_outlined,
                        onTap: onCancelCart,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSecondaryButton(
                        label: '[?] Panduan',
                        icon: Icons.help_outline,
                        onTap: onOpenGuide ?? () => FastRetailKeyboardGuideDialog.show(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // GIANT PRIMARY CTA: [Enter] BAYAR (Rp ...) (56dp height)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty ? null : onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolluColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: SolluColors.neutral,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Enter',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'BAYAR (${CurrencyFormatter.format(grandTotal.toInt())})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastScannedHeroCard(dynamic item) {
    if (item == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SolluColors.neutral, width: 1.0),
        ),
        child: const Column(
          children: [
            Icon(Icons.barcode_reader, size: 28, color: SolluColors.textMuted),
            SizedBox(height: 8),
            Text(
              'Item Terakhir Terpindai',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SolluColors.textMuted),
            ),
            SizedBox(height: 2),
            Text(
              'Pindai barcode hardware atau ketik nama/SKU di atas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: SolluColors.textMuted),
            ),
          ],
        ),
      );
    }

    final double lineTotal = (item.price * item.qty).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SolluColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SolluColors.success, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SolluColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'BERHASIL TERPINDAI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (item.barcode != null || item.sku != null)
                Text(
                  item.barcode ?? item.sku,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: SolluColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SolluColors.textDark,
            ),
          ),
          if (item.variantCombination != null && item.variantCombination.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.variantCombination,
              style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${CurrencyFormatter.format(item.price.toInt())} × ${item.qty}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(lineTotal.toInt()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCrmCard(BuildContext context, bool isCrmActive) {
    return InkWell(
      onTap: isCrmActive
          ? onChangeCustomer
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur CRM / Pelanggan tidak aktif pada paket langganan ini.'),
                  backgroundColor: SolluColors.warning,
                ),
              );
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SolluColors.neutral, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: SolluColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.person_outline, size: 18, color: SolluColors.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pelanggan',
                    style: TextStyle(fontSize: 11, color: SolluColors.textMuted),
                  ),
                  Text(
                    'Pelanggan Umum (Walk-in)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SolluColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isCrmActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: const Text(
                  'Ubah',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SolluColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isMuted = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isMuted ? SolluColors.textMuted : SolluColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isMuted ? SolluColors.textMuted : SolluColors.textDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    int? badgeCount,
    bool isActive = false,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? SolluColors.primary.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? SolluColors.primary : SolluColors.neutral,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: textColor ?? (isActive ? SolluColors.primary : SolluColors.textDark),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? (isActive ? SolluColors.primary : SolluColors.textDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
