import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/theme/sollu_spacing.dart';

class PaymentDialog extends StatelessWidget {
  final int totalAmount;

  const PaymentDialog({super.key, required this.totalAmount});

  static Future<void> show(BuildContext context, int totalAmount) {
    return showDialog(
      context: context,
      builder: (context) => PaymentDialog(totalAmount: totalAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 840,
        height: 620,
        padding: SolluSpacing.containerPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Payment Details & Methods)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                  const SizedBox(height: SolluSpacing.xxl),
                  const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                  const SizedBox(height: SolluSpacing.lg),
                  Wrap(
                    spacing: SolluSpacing.md,
                    runSpacing: SolluSpacing.md,
                    children: const [
                      _PaymentMethodBtn('Tunai', Icons.money, isSelected: true),
                      _PaymentMethodBtn('QRIS', Icons.qr_code, isSelected: false),
                      _PaymentMethodBtn('EDC / Kartu', Icons.credit_card, isSelected: false),
                      _PaymentMethodBtn('Transfer Bank', Icons.account_balance, isSelected: false),
                    ],
                  ),
                  const SizedBox(height: SolluSpacing.xxxl),
                  const Text('Uang Diterima (Tunai)', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                  const SizedBox(height: SolluSpacing.lg),
                  TextField(
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.primary),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      contentPadding: SolluSpacing.inputPadding,
                      border: OutlineInputBorder(borderRadius: SolluSpacing.radiusMd),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: SolluSpacing.lg),
                  // Quick Cash Buttons
                  Wrap(
                    spacing: SolluSpacing.sm,
                    runSpacing: SolluSpacing.sm,
                    children: const [
                      _QuickCashBtn('Uang Pas'),
                      _QuickCashBtn('Rp 20.000'),
                      _QuickCashBtn('Rp 50.000'),
                      _QuickCashBtn('Rp 100.000'),
                    ],
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 48, thickness: 1, color: SolluColors.neutral),
            // Right Column (Summary & Submit)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: SolluSpacing.containerPadding,
                    decoration: BoxDecoration(
                      color: SolluColors.background,
                      borderRadius: SolluSpacing.radiusMd,
                      border: Border.all(color: SolluColors.neutral),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Total Tagihan', style: TextStyle(color: SolluColors.textMuted)),
                        const SizedBox(height: SolluSpacing.sm),
                        Text(
                          'Rp $totalAmount',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: SolluColors.primary,
                          ),
                        ),
                        const Divider(height: 32, color: SolluColors.neutral),
                        const Text('Kembalian', style: TextStyle(color: SolluColors.textMuted)),
                        const SizedBox(height: SolluSpacing.sm),
                        const Text(
                          'Rp 0',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Pembayaran Terpisah'),
                    style: OutlinedButton.styleFrom(padding: SolluSpacing.buttonPadding),
                  ),
                  const SizedBox(height: SolluSpacing.lg),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: SolluColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Bayar & Cetak Struk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: SolluSpacing.md),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal (Esc)', style: TextStyle(color: SolluColors.textMuted)),
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

class _PaymentMethodBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _PaymentMethodBtn(this.label, this.icon, {required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: SolluSpacing.radiusMd,
      child: Container(
        width: 120,
        height: 100,
        padding: SolluSpacing.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? SolluColors.primary : SolluColors.neutral,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: SolluSpacing.radiusMd,
          color: isSelected ? SolluColors.primaryLighter.withValues(alpha: 0.2) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isSelected ? SolluColors.primary : SolluColors.neutralMuted),
            const SizedBox(height: SolluSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? SolluColors.primary : SolluColors.textDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCashBtn extends StatelessWidget {
  final String label;

  const _QuickCashBtn(this.label);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
