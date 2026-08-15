import 'package:flutter/material.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/variant_dialog.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';

import 'package:flutter/services.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

class ProductGrid extends ConsumerStatefulWidget {
  final FocusNode? searchFocusNode;
  final FocusNode? focusNode;
  final int? selectedIndex;
  final ValueChanged<int>? onSelectedIndexChanged;

  const ProductGrid({
    super.key,
    this.searchFocusNode,
    this.focusNode,
    this.selectedIndex,
    this.onSelectedIndexChanged,
  });

  @override
  ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
  int _localSelectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  int get _currentIndex => widget.selectedIndex ?? _localSelectedIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setIndex(int idx, int totalItems) {
    if (totalItems <= 0) return;
    final clamped = idx.clamp(0, totalItems - 1);
    if (widget.onSelectedIndexChanged != null) {
      widget.onSelectedIndexChanged!(clamped);
    } else {
      setState(() {
        _localSelectedIndex = clamped;
      });
    }
    _scrollToIndex(clamped);
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    
    final row = index ~/ 4;
    // Lowered the estimation slightly to ensure the targetTop triggers the scroll up earlier
    const double estimatedRowHeight = 180.0; 
    final targetTop = (row * estimatedRowHeight) - 40; // Buffer for top padding
    final targetBottom = targetTop + estimatedRowHeight + 80; // Buffer for bottom padding
    
    final currentOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    if (targetTop < currentOffset) {
       _scrollController.animateTo((targetTop < 0 ? 0 : targetTop), duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    } else if (targetBottom > currentOffset + viewportHeight) {
       _scrollController.animateTo(targetBottom - viewportHeight, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  void _handleSelectItem(PosItem product) {
    if (!product.isActive) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} sedang dinonaktifkan dari kasir.'),
          backgroundColor: SolluColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final hasVariantsOrModifiers = product.hasVariants || product.hasModifiers;

    if (hasVariantsOrModifiers) {
      VariantDialog.show(context, product);
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.isProductMode ? product.id : product.inventory!.productId,
        inventoryItemId: product.isProductMode ? '' : product.id,
        name: product.name,
        price: product.price,
        qty: 1,
      );
      ref.read(cartProvider.notifier).addItem(cartItem);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan'),
          backgroundColor: SolluColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredPosItemsProvider);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: filteredAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (filteredItems) {

          if (filteredItems.isEmpty) {
            return const Center(child: Text('Tidak ada item yang sesuai'));
          }

          final isGridFocused = widget.focusNode?.hasFocus ?? false;

          return Focus(
            focusNode: widget.focusNode,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                final key = event.logicalKey;
                const columns = 4;
                
                if (key == LogicalKeyboardKey.arrowRight) {
                  _setIndex(_currentIndex + 1, filteredItems.length);
                  return KeyEventResult.handled;
                } else if (key == LogicalKeyboardKey.arrowLeft) {
                  _setIndex(_currentIndex - 1, filteredItems.length);
                  return KeyEventResult.handled;
                } else if (key == LogicalKeyboardKey.arrowDown) {
                  _setIndex(_currentIndex + columns, filteredItems.length);
                  return KeyEventResult.handled;
                } else if (key == LogicalKeyboardKey.arrowUp) {
                  _setIndex(_currentIndex - columns, filteredItems.length);
                  return KeyEventResult.handled;
                } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
                  if (_currentIndex >= 0 && _currentIndex < filteredItems.length) {
                    _handleSelectItem(filteredItems[_currentIndex]);
                    return KeyEventResult.handled;
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: GridView.builder(
              controller: _scrollController,
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
                final isSelected = isGridFocused && (_currentIndex == index);
                return _ProductCard(
                  posItem: product,
                  isSelected: isSelected,
                  onTap: () => _handleSelectItem(product),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PosItem posItem;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductCard({
    required this.posItem,
    this.isSelected = false,
    required this.onTap,
  });

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
        border: Border.all(
          color: isSelected ? SolluColors.primary : Colors.transparent,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? SolluColors.primary.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
            blurRadius: isSelected ? 18 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
