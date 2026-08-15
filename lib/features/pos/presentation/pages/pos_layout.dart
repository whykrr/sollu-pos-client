import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/product_grid.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/cart_panel.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/category_sidebar.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';

import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/hold_orders_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/transaction_history_dialog.dart';

import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/bootstrap_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/widgets/sync_progress_overlay.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

class PosLayout extends ConsumerStatefulWidget {
  const PosLayout({super.key});

  @override
  ConsumerState<PosLayout> createState() => _PosLayoutState();
}

class _PosLayoutState extends ConsumerState<PosLayout> {
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _productGridFocusNode = FocusNode();
  final FocusNode _cartFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  int _selectedProductIndex = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Jalankan auto-sync bootstrap data master & karyawan di background jika online
    ref.read(bootstrapProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Cek langsung ke database SQLite apakah sudah ada shift yang berstatus 'open'
      final shiftRepository = ref.read(shiftRepositoryProvider);
      final activeShift = await shiftRepository.getActiveShift();

      // Selalu munculkan dialog Buka Shift jika belum ada sesi shift aktif
      if (activeShift == null && mounted) {
        OpenShiftDialog.show(context);
      }
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _productGridFocusNode.dispose();
    _cartFocusNode.dispose();
    super.dispose();
  }

  void _handleShortcut(String key) {
    if (!mounted) return;

    switch (key) {
      case 'F1':
        _searchFocusNode.requestFocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pencarian Produk / Scan Barcode (F1)'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'F2':
        _productGridFocusNode.requestFocus();
        setState(() {
          _selectedProductIndex = 0;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fokus Daftar Produk: Item #1 Terpilih (F2)'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'F3':
        _cartFocusNode.requestFocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fokus Keranjang (F3) - Tekan Enter untuk ubah Qty'),
            duration: Duration(seconds: 1),
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
        _handleHoldOrder();
        break;
      case 'F7':
        HoldOrdersDialog.show(context);
        break;
      case 'F8':
        _handleCheckout();
        break;
      case 'F9':
        TransactionHistoryDialog.show(context);
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

  void _handleHoldOrder() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong, tidak ada pesanan untuk ditahan.'),
          backgroundColor: SolluColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final heldOrder = ref.read(holdCartProvider.notifier).holdCurrentCart(cart);
    if (heldOrder != null) {
      ref.read(cartProvider.notifier).clearCart();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan berhasil ditahan (${heldOrder.id}). Tekan F7 untuk memuat kembali.'),
          backgroundColor: SolluColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleCheckout() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      EmptyCartDialog.show(context);
      return;
    }

    final appliedDiscount = ref.read(appliedDiscountProvider);
    final taxRate = ref.read(activeTaxRateProvider);
    final serviceChargeRate = ref.read(activeServiceChargeRateProvider);

    final double subtotal = cart.fold(0.0, (sum, item) => sum + item.calculatedSubtotal);
    final double discountAmount = appliedDiscount != null ? appliedDiscount.calculateDiscount(subtotal) : 0.0;
    final double taxableAmount = (subtotal - discountAmount).clamp(0.0, double.infinity);
    final double tax = taxableAmount * (taxRate / 100.0);
    final double serviceCharge = taxableAmount * (serviceChargeRate / 100.0);
    final int total = (taxableAmount + tax + serviceCharge).toInt();
    PaymentDialog.show(context, total);
  }

  @override
  Widget build(BuildContext context) {
    final activeShiftAsync = ref.watch(activeShiftProvider);
    
    // Initialize auto-sync watcher
    ref.watch(autoSyncProvider);

    // Optimasi Riverpod: ref.listen tidak memicu rebuild UI, cukup merespons event shortcut
    ref.listen<String?>(shortcutProvider, (previous, next) {
      if (next != null) {
        _handleShortcut(next);
      }
    });

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final logicalKey = event.logicalKey;
          if (logicalKey == LogicalKeyboardKey.f1) {
            ref.read(shortcutProvider.notifier).trigger('F1');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f2) {
            ref.read(shortcutProvider.notifier).trigger('F2');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f3) {
            ref.read(shortcutProvider.notifier).trigger('F3');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f4) {
            ref.read(shortcutProvider.notifier).trigger('F4');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f5) {
            ref.read(shortcutProvider.notifier).trigger('F5');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f6) {
            ref.read(shortcutProvider.notifier).trigger('F6');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f7) {
            ref.read(shortcutProvider.notifier).trigger('F7');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f8) {
            ref.read(shortcutProvider.notifier).trigger('F8');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f9) {
            ref.read(shortcutProvider.notifier).trigger('F9');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f10) {
            ref.read(shortcutProvider.notifier).trigger('F10');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f12) {
            ref.read(shortcutProvider.notifier).trigger('F12');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.escape) {
            ref.read(shortcutProvider.notifier).trigger('Esc');
            // Allow escape to also close dialogs natively if needed, but we handle it
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
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
            child: Consumer(
              builder: (context, ref, child) {
                final isOnline = ref.watch(connectivityProvider);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline 
                        ? SolluColors.success.withValues(alpha: 0.1)
                        : SolluColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline ? SolluColors.success : SolluColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 14,
                        color: isOnline ? SolluColors.success : SolluColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? SolluColors.success : SolluColors.danger,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: activeShiftAsync.when(
              data: (shift) {
                final isShiftOpen = shift != null;
                final cashierName = isShiftOpen
                    ? ref.watch(cashierNameProvider(shift.userId)).when(
                        data: (name) => name,
                        loading: () => '...',
                        error: (_, __) => 'Kasir',
                      )
                    : '';
                final shiftText = isShiftOpen
                    ? 'Shift #${shift.shiftNumber}  •  Kasir: $cashierName'
                    : 'Shift: Belum Dibuka';

                return InkWell(
                  onTap: () {
                    if (isShiftOpen) {
                      CloseShiftDialog.show(context);
                    } else {
                      OpenShiftDialog.show(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isShiftOpen 
                          ? SolluColors.primary.withValues(alpha: 0.08) 
                          : SolluColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isShiftOpen 
                            ? SolluColors.primary.withValues(alpha: 0.3) 
                            : SolluColors.warning,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isShiftOpen ? Icons.storefront : Icons.warning_amber_rounded,
                          size: 16,
                          color: isShiftOpen ? SolluColors.primary : SolluColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          shiftText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isShiftOpen ? SolluColors.primary : SolluColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => const SizedBox.shrink(),
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
                  
                  // Simpan timestamp sinkronisasi terakhir
                  ref.read(lastSyncProvider.notifier).updateTimestamp();
                  
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
      body: Stack(
        children: [
          Row(
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
              child: ProductGrid(
                searchFocusNode: _searchFocusNode,
                focusNode: _productGridFocusNode,
                selectedIndex: _selectedProductIndex,
                onSelectedIndexChanged: (idx) {
                  setState(() {
                    _selectedProductIndex = idx;
                  });
                },
              ),
            ),
          ),
          // Right Pane: Cart Panel (3/10 of screen)
          Expanded(
            flex: 3,
            child: CartPanel(
              focusNode: _cartFocusNode,
            ),
          ),
            ],
          ),
          
          // Floating Sync Overlay
          const SyncProgressOverlay(),
        ],
      ),
      ),
    );
  }
}
