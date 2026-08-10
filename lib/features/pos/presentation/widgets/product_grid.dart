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
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Semua',
    'Makanan',
    'Minuman',
    'Cemilan',
    'Paket Hemat',
  ];

  @override
  Widget build(BuildContext context) {
    // Mock data for UI testing
    final List<Map<String, dynamic>> mockProducts = List.generate(
      12,
      (index) => {
        'name': 'Produk ${index + 1}',
        'price': (index + 1) * 5000,
        'stock': 10 + index,
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar (F1 Focus Target)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: TextField(
            focusNode: widget.searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Cari produk atau scan barcode... (F1)',
              prefixIcon: const Icon(
                Icons.search,
                color: SolluColors.neutralMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SolluColors.neutral),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SolluColors.neutral),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: SolluColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Categories Chips
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return ChoiceChip(
                avatar: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
                label: Text(_categories[index]),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  }
                },
                selectedColor: SolluColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : SolluColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? SolluColors.primary
                        : SolluColors.neutral,
                  ),
                ),
              );
            },
          ),
        ),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Disesuaikan agar muat tombol tambah
            ),
            itemCount: mockProducts.length,
            itemBuilder: (context, index) {
              final product = mockProducts[index];
              return _ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolluColors.neutral.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            VariantDialog.show(context, product);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Placeholder Area
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: SolluColors.secondary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 48,
                      color: SolluColors.secondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              // Product Info Area
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
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
                            'Stok: ${product['stock']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolluColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rp ${product['price']}',
                            style: const TextStyle(
                              color: SolluColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: SolluColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
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
