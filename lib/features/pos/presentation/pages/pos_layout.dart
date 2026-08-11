import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/product_grid.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/cart_panel.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_app/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_app/features/pos/presentation/widgets/category_sidebar.dart';
import 'package:sollu_pos_app/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_app/features/settings/presentation/providers/sync_provider.dart';

class PosLayout extends ConsumerStatefulWidget {
  const PosLayout({super.key});

  @override
  ConsumerState<PosLayout> createState() => _PosLayoutState();
}

class _PosLayoutState extends ConsumerState<PosLayout> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OpenShiftDialog.show(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleShortcut(String key) {
    if (!mounted) return;

    switch (key) {
      case 'F1':
        _searchFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fokusan kursor dipindah ke Pencarian Produk (F1)'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'F2':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panel Keranjang Terpilih (F2)'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'F3':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan Berhasil Ditahan (F3)'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'F4':
        DiscountDialog.show(context);
        break;
      case 'F5':
        CustomerDialog.show(context);
        break;
      case 'F6':
        _handleChangeQuantity();
        break;
      case 'F8':
        PaymentDialog.show(context, 27750);
        break;
      case 'F10':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mencetak ulang struk transaksi terakhir... (F10)'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'F12':
        CloseShiftDialog.show(context);
        break;
    }
  }

  void _handleChangeQuantity() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong')),
      );
      return;
    }
    
    // In a real app, this would show a dialog to enter quantity for the last/selected item
    final lastItem = cart.last;
    
    showDialog(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController(text: lastItem.qty.toString());
        ctrl.selection = TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
        
        return AlertDialog(
          title: Text('Ubah Qty: ${lastItem.name}'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onSubmitted: (val) {
              final newQty = int.tryParse(val);
              if (newQty != null && newQty > 0) {
                ref.read(cartProvider.notifier).updateQty(lastItem.id, newQty - lastItem.qty);
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final newQty = int.tryParse(ctrl.text);
                if (newQty != null && newQty > 0) {
                  ref.read(cartProvider.notifier).updateQty(lastItem.id, newQty - lastItem.qty);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('img/logo-colored.png', height: 32),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    ref.read(posSearchQueryProvider.notifier).setQuery(val);
                  },
                  onSubmitted: (val) async {
                    final query = val.trim();
                    if (query.isEmpty) return;
                    
                    final repository = ref.read(posRepositoryProvider);
                    final matchedItem = await repository.findItemByBarcodeOrSku(query);
                    
                    if (matchedItem != null) {
                      final cartItem = CartItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        productId: matchedItem.isProductMode ? matchedItem.id : matchedItem.inventory!.productId,
                        inventoryItemId: matchedItem.isProductMode ? '' : matchedItem.id,
                        name: matchedItem.name,
                        price: matchedItem.price,
                        qty: 1,
                      );
                      ref.read(cartProvider.notifier).addItem(cartItem);
                      
                      _searchController.clear();
                      ref.read(posSearchQueryProvider.notifier).setQuery('');
                      _searchFocusNode.requestFocus();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Barcode/SKU "$query" tidak ditemukan'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: SolluColors.danger,
                        ),
                      );
                      // Tetap kosongkan dan fokus kembali agar bisa scan ulang
                      _searchController.clear();
                      ref.read(posSearchQueryProvider.notifier).setQuery('');
                      _searchFocusNode.requestFocus();
                    }
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari produk atau scan barcode... (F1)',
                    hintStyle: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: SolluColors.neutralMuted,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: SolluColors.neutral),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: SolluColors.neutral),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: SolluColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: SolluColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_alt_outlined,
                color: SolluColors.textDark,
              ),
              tooltip: 'Panduan Shortcut (F1-F12)',
              onPressed: () => ShortcutHelpDialog.show(context),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: SolluColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SolluColors.neutral),
              ),
              child: const Text(
                'Shift: Siang  •  Kasir: Budi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: SolluColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isSyncing ? null : () async {
                setState(() {
                  _isSyncing = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menyingkronkan Master Data...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  final employeeRepository = ref.read(employeeRepositoryProvider);
                  await employeeRepository.syncEmployees();
                  
                  final syncRepository = ref.read(syncRepositoryProvider);
                  await syncRepository.syncMasterData();
                  
                  ref.invalidate(employeeListProvider);
                  ref.invalidate(posItemsProvider);
                  ref.invalidate(posCategoriesProvider);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sinkronisasi selesai!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal sinkronisasi: $e'),
                        backgroundColor: SolluColors.danger,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSyncing = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isSyncing 
                  ? const SizedBox(
                      width: 18, 
                      height: 18, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.sync, size: 18),
              label: Text(_isSyncing ? 'Sinkronisasi...' : 'Sinkronisasi Data'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Pane: Category Sidebar (2/10 of screen)
          const Expanded(
            flex: 2,
            child: CategorySidebar(),
          ),
          // Middle Pane: Product Grid (5/10 of screen)
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: ProductGrid(searchFocusNode: _searchFocusNode),
            ),
          ),
          // Right Pane: Cart Panel (3/10 of screen)
          const Expanded(flex: 3, child: CartPanel()),
        ],
      ),
    );
  }
}
