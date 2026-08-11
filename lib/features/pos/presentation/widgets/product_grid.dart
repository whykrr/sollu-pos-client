import 'package:flutter/material.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/variant_dialog.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_app/features/pos/data/pos_repository.dart';

class ProductGrid extends ConsumerStatefulWidget {
  final FocusNode? searchFocusNode;

  const ProductGrid({super.key, this.searchFocusNode});

  @override
  ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
  @override
  Widget build(BuildContext context) {
    final posItemsAsync = ref.watch(posItemsProvider);
    final searchQuery = ref.watch(posSearchQueryProvider).toLowerCase();
    final selectedCategory = ref.watch(posSelectedCategoryProvider);

    return Container(
      color: const Color(0xFFF8FAFC), // Light grey background like in image
      child: posItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) {
          final filteredItems = items.where((item) {
            final matchesCategory = selectedCategory == null || item.categoryId == selectedCategory;
            final matchesSearch = item.name.toLowerCase().contains(searchQuery) ||
                   (item.product?.barcode?.toLowerCase().contains(searchQuery) ?? false) ||
                   (item.inventory?.barcode?.toLowerCase().contains(searchQuery) ?? false);
            
            return matchesCategory && matchesSearch;
          }).toList();

          if (filteredItems.isEmpty) {
            return const Center(child: Text('Tidak ada item yang sesuai'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final product = filteredItems[index];
              return _ProductCard(posItem: product);
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PosItem posItem;

  const _ProductCard({required this.posItem});

  @override
  Widget build(BuildContext context) {
    final bool isActive = posItem.isActive;
    final String itemName = posItem.name;
    final double itemPrice = posItem.price;
    final bool hasVariantsOrModifiers = posItem.hasVariants || posItem.hasModifiers;

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
            if (!isActive) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$itemName sedang dinonaktifkan dari kasir.'),
                  backgroundColor: SolluColors.danger,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            // Temporarily pass posItem ID to dialog
            VariantDialog.show(context, posItem);
          },
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Opacity(
                opacity: isActive ? 1.0 : 0.4,
                child: Padding(
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
                        itemName,
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
                        CurrencyFormatter.format(itemPrice.toInt()),
                        style: const TextStyle(
                          color: SolluColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SolluColors.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Nonaktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasVariantsOrModifiers && isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107), // Yellow badge
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '+ Opsi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
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
