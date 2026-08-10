import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/product_grid.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/cart_panel.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_app/features/shift/presentation/widgets/shift_dialogs.dart';

class PosLayout extends ConsumerStatefulWidget {
  const PosLayout({super.key});

  @override
  ConsumerState<PosLayout> createState() => _PosLayoutState();
}

class _PosLayoutState extends ConsumerState<PosLayout> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OpenShiftDialog.show(context);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleShortcut(String key) {
    if (!mounted) return;

    switch (key) {
      case 'F1':
        _searchFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fokusan kursor dipindah ke Pencarian Produk (F1)'), duration: Duration(seconds: 1)),
        );
        break;
      case 'F2':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Panel Keranjang Terpilih (F2)'), duration: Duration(seconds: 1)),
        );
        break;
      case 'F3':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan Berhasil Ditahan / Hold Order (F3)'), duration: Duration(seconds: 2)),
        );
        break;
      case 'F4':
        DiscountDialog.show(context);
        break;
      case 'F5':
        CustomerDialog.show(context);
        break;
      case 'F8':
        PaymentDialog.show(context, 27750);
        break;
      case 'F10':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mencetak ulang struk transaksi terakhir... (F10)'), duration: Duration(seconds: 2)),
        );
        break;
      case 'F12':
        CloseShiftDialog.show(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optimasi Riverpod: ref.listen tidak memicu rebuild UI, cukup merespons event shortcut
    ref.listen<String?>(shortcutProvider, (previous, next) {
      if (next != null) {
        _handleShortcut(next);
      }
    });

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('img/logo-colored.png', height: 32),
            const SizedBox(width: 12),
            const Text('Kasir POS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: SolluColors.textDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_alt_outlined, color: SolluColors.textDark),
            tooltip: 'Panduan Shortcut (F1-F12)',
            onPressed: () => ShortcutHelpDialog.show(context),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: const Text(
                  'Shift: Siang  •  Kasir: Budi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyingkronkan Master Data ke SQLite...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync Data'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Pane: Product Grid (2/3 of the screen)
          Expanded(
            flex: 2,
            child: Container(
              color: SolluColors.background, // Sedikit abu-abu agar kontras dengan keranjang yang putih
              child: ProductGrid(searchFocusNode: _searchFocusNode),
            ),
          ),
          // Right Pane: Cart Panel (1/3 of the screen)
          // Menghapus VerticalDivider dan menggunakan BoxShadow dari CartPanel
          const Expanded(
            flex: 1,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }
}
