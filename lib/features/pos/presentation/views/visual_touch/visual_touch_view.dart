import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'visual_touch_cart_pane.dart';
import 'visual_touch_catalog_pane.dart';
import 'visual_touch_header.dart';

/// Ekosistem Tampilan Visual Touch (Visual Touch View)
/// Dirancang untuk restoran, kafe, bakery, dan retail visual dengan interaksi murni layar sentuh tanpa hotkey keyboard.
class VisualTouchView extends ConsumerStatefulWidget {
  const VisualTouchView({super.key});

  @override
  ConsumerState<VisualTouchView> createState() => _VisualTouchViewState();
}

class _VisualTouchViewState extends ConsumerState<VisualTouchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _productGridFocusNode = FocusNode();
  final FocusNode _cartFocusNode = FocusNode();
  int _selectedProductIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _productGridFocusNode.dispose();
    _cartFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleBackToDashboard() async {
    final cart = ref.read(cartProvider);
    if (cart.isNotEmpty) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: SolluColors.warning),
              SizedBox(width: 10),
              Text(
                'Tinggalkan Layar Kasir?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Terdapat ${cart.length} jenis item di keranjang belanja. Pesanan akan tetap tersimpan sementara.',
            style: const TextStyle(fontSize: 14, color: SolluColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal', style: TextStyle(color: SolluColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, ke Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (shouldLeave != true) return;
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep search field in sync with posSearchQueryProvider if reset externally
    ref.listen<String>(posSearchQueryProvider, (prev, next) {
      if (next.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: VisualTouchHeader(
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onBackToDashboard: _handleBackToDashboard,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Catalog Pane: Categories & Product Grid (Flex 7)
          Expanded(
            flex: 7,
            child: VisualTouchCatalogPane(
              searchFocusNode: _searchFocusNode,
              productGridFocusNode: _productGridFocusNode,
              selectedIndex: _selectedProductIndex,
              onSelectedIndexChanged: (idx) {
                setState(() {
                  _selectedProductIndex = idx;
                });
              },
            ),
          ),

          // Right Pane: Touch Cart Panel (Flex 3)
          Expanded(
            flex: 3,
            child: VisualTouchCartPane(focusNode: _cartFocusNode),
          ),
        ],
      ),
    );
  }
}
