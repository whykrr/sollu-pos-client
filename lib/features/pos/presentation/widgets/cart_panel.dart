import 'package:flutter/material.dart';
import 'package:sollu_pos_app/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock cart data
    final List<Map<String, dynamic>> mockCart = [
      {'name': 'Produk 1', 'price': 5000, 'qty': 2},
      {'name': 'Produk 3', 'price': 15000, 'qty': 1},
    ];

    final int subtotal = mockCart.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
    final int tax = (subtotal * 0.11).round();
    final int total = subtotal + tax;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(-4, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SolluColors.neutral)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Saat Ini',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: SolluColors.secondary, size: 18),
                      const SizedBox(width: 4),
                      Text('${mockCart.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.secondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Cart Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: mockCart.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: SolluColors.neutral),
              itemBuilder: (context, index) {
                final item = mockCart[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${item['price']}',
                              style: const TextStyle(color: SolluColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Ergonomic Qty Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: SolluColors.neutral),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {},
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.remove, size: 18, color: SolluColors.textMuted),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${item['qty']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add, size: 18, color: SolluColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Order Summary & Checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, -6),
                  blurRadius: 16,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryRow(label: 'Subtotal', value: 'Rp $subtotal'),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Pajak (11%)', value: 'Rp $tax'),
                const Divider(height: 24, color: SolluColors.neutral),
                _SummaryRow(label: 'Total', value: 'Rp $total', isTotal: true),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Hold order
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: SolluColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hold (F3)', style: TextStyle(color: SolluColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          PaymentDialog.show(context, total);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Checkout (F8)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? SolluColors.textDark : SolluColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? SolluColors.primary : SolluColors.textDark,
          ),
        ),
      ],
    );
  }
}
