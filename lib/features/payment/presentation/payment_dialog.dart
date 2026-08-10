import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Payment Details & Methods)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _PaymentMethodBtn('Tunai', Icons.money, isSelected: true),
                      _PaymentMethodBtn('QRIS', Icons.qr_code, isSelected: false),
                      _PaymentMethodBtn('EDC / Kartu', Icons.credit_card, isSelected: false),
                      _PaymentMethodBtn('Transfer Bank', Icons.account_balance, isSelected: false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Uang Diterima (Tunai)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Quick Cash Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickCashBtn('Uang Pas'),
                      _QuickCashBtn('Rp 20.000'),
                      _QuickCashBtn('Rp 50.000'),
                      _QuickCashBtn('Rp 100.000'),
                    ],
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 48, thickness: 1),
            // Right Column (Summary & Submit)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Total Tagihan', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          'Rp $totalAmount',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Divider(height: 32),
                        const Text('Kembalian', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text(
                          'Rp 0',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Split Payment'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Process payment
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Bayar & Cetak Struk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal (Esc)'),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
      child: Text(label),
    );
  }
}
