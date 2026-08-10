import 'package:flutter/material.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/variant_dialog.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class ProductGrid extends StatefulWidget {
  final FocusNode? searchFocusNode;

  const ProductGrid({super.key, this.searchFocusNode});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  @override
  Widget build(BuildContext context) {
    // Mock data based on the image
    final List<Map<String, dynamic>> mockProducts = [
      {'name': 'Bakmi Special', 'price': 25455, 'hasBadge': false},
      {'name': 'Bakmi Komplit Special', 'price': 31818, 'hasBadge': true},
      {'name': 'Bakmi Ayam Teriyaki', 'price': 29091, 'hasBadge': false},
      {'name': 'Bakmi Kuah Sapi', 'price': 27273, 'hasBadge': true},
      {'name': 'Bakmi Sapi Lada Hitam', 'price': 32727, 'hasBadge': false},
      {'name': 'Bakmi Seafood Pedas', 'price': 32727, 'hasBadge': false},
      {'name': 'Bakmi Goreng Ayam', 'price': 29091, 'hasBadge': false},
      {'name': 'Bakmi Goreng Seafood', 'price': 32727, 'hasBadge': false},
      {'name': 'Bakmi Capcay', 'price': 31818, 'hasBadge': true},
    ];

    return Container(
      color: const Color(0xFFF8FAFC), // Light grey background like in image
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.75, // Adjust for taller cards
        ),
        itemCount: mockProducts.length,
        itemBuilder: (context, index) {
          final product = mockProducts[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasBadge = product['hasBadge'] == true;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Simplified add to cart, showing variant dialog for now
            VariantDialog.show(context, product);
          },
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mock Image (Circle)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: SolluColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: SolluColors.neutral, width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.ramen_dining,
                            size: 60,
                            color: SolluColors.textMuted.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: SolluColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product['price']}',
                      style: const TextStyle(
                        color: SolluColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBadge)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107), // Yellow badge
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
