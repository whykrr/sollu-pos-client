import 'package:flutter/material.dart';
import 'package:sollu_pos_app/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_app/core/utils/currency_formatter.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock cart data
    final List<Map<String, dynamic>> mockCart = [
      {'name': 'Bakmi Komplit Special', 'price': 31818, 'qty': 2, 'notes': 'Notes'},
      {'name': 'Bakmi Ayam Teriyaki', 'price': 29091, 'qty': 1, 'notes': 'Jangan terlalu banyak kuah'},
      {'name': 'French Fries Original', 'price': 17273, 'qty': 3, 'notes': 'Ditambah bumbu keju'},
      {'name': 'Hot Coffee Large', 'price': 16364, 'qty': 2, 'notes': 'Notes'},
    ];

    final int subtotal = mockCart.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
    final int tax = (subtotal * 0.1).round(); // 10% tax in image
    final int total = subtotal + tax;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.list, color: SolluColors.textDark),
                Text(
                  'Cart (${mockCart.fold(0, (sum, item) => sum + (item['qty'] as int))})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
                ),
                const Icon(Icons.add, color: SolluColors.textDark),
              ],
            ),
          ),
          
          // Sub-header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order List #1', style: TextStyle(color: SolluColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('Kamis, 7 Sept 2017 | 17:20:01', style: TextStyle(color: SolluColors.textMuted.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: SolluColors.neutral),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: mockCart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final item = mockCart[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(item['price'] as int),
                            style: const TextStyle(color: SolluColors.textMuted, fontSize: 13),
                          ),
                          if (item['notes'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.edit_note, size: 14, color: SolluColors.textMuted.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['notes'],
                                    style: TextStyle(color: SolluColors.textMuted.withValues(alpha: 0.6), fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Square Qty Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQtyButton(Icons.remove, () {}),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                            '${item['qty']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SolluColors.textDark),
                          ),
                        ),
                        _buildQtyButton(Icons.add, () {}),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Order Summary & Checkout
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, -5),
                  blurRadius: 15,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(subtotal)),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Discount (0%)', value: CurrencyFormatter.format(0)),
                const SizedBox(height: 8),
                _SummaryRow(label: '10% Pajak', value: CurrencyFormatter.format(tax)),
                const SizedBox(height: 16),
                const Divider(color: SolluColors.neutral),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark)),
                    Text(CurrencyFormatter.format(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: SolluColors.textDark)),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons Row
                Row(
                  children: [
                    _buildActionButton(Icons.save_outlined, 'Save'),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.percent_outlined, 'Discount'),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.receipt_long_outlined, 'Split Bill'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          PaymentDialog.show(context, total);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('BAYAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: SolluColors.textMuted),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: SolluColors.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 8, color: SolluColors.textMuted.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: SolluColors.textDark,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SolluColors.textDark,
          ),
        ),
      ],
    );
  }
}
