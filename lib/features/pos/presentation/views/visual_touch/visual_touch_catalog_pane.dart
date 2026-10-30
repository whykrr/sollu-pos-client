import 'package:flutter/material.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/category_sidebar.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/product_grid.dart';

/// Panel Katalog Visual Touch (VisualTouchCatalogPane)
/// Menggabungkan navigasi kategori (CategorySidebar) dan grid menu (ProductGrid)
/// untuk interaksi sentuh visual tanpa shortcut keyboard.
class VisualTouchCatalogPane extends StatelessWidget {
  final FocusNode? searchFocusNode;
  final FocusNode? productGridFocusNode;
  final int selectedIndex;
  final ValueChanged<int>? onSelectedIndexChanged;

  const VisualTouchCatalogPane({
    super.key,
    this.searchFocusNode,
    this.productGridFocusNode,
    this.selectedIndex = 0,
    this.onSelectedIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category Sidebar (Flex 2)
        const Expanded(
          flex: 2,
          child: CategorySidebar(),
        ),

        // Product Grid (Flex 5)
        Expanded(
          flex: 5,
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: ProductGrid(
              searchFocusNode: searchFocusNode,
              focusNode: productGridFocusNode,
              selectedIndex: selectedIndex,
              onSelectedIndexChanged: onSelectedIndexChanged,
            ),
          ),
        ),
      ],
    );
  }
}
