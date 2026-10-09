import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/hardware_scanner_listener.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/supervisor_challenge_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/product_grid.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/cart_panel.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/insufficient_stock_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/category_sidebar.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/held_bills_drawer.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/hold_orders_dialog.dart';

import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/bootstrap_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/widgets/sync_progress_overlay.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/realtime_provider.dart';

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
    // Inisialisasi Reverb WebSocket Realtime Client
    ref.read(posReverbClientProvider);

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

  Future<bool> _ensureAuthorized(
    String requiredPermission,
    String actionTitle,
  ) async {
    final activeEmployee = ref.read(activeEmployeeProvider);
    final hasPerm = activeEmployee != null &&
        (activeEmployee.hasPermission(requiredPermission) ||
            activeEmployee.isSupervisor());
    if (hasPerm) return true;

    final result = await SupervisorChallengeDialog.authorize(
      context,
      actionTitle: actionTitle,
      requiredPermission: requiredPermission,
    );
    return result.authorized;
  }


  void _handleReprintLastReceipt() {
    final repo = ref.read(transactionRepositoryProvider);
    repo.getLastTransactionId().then((txId) {
      if (txId != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Mencetak ulang struk transaksi terakhir...'),
            duration: Duration(seconds: 1),
          ),
        );
        printTransactionReceiptAction(ref: ref, transactionId: txId).then((res) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  res.success ? 'Struk berhasil dicetak' : 'Gagal: ${res.message}',
                ),
                backgroundColor:
                    res.success ? SolluColors.success : SolluColors.danger,
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada transaksi untuk dicetak.')),
        );
      }
    });
  }

  Future<void> _handleBarcodeScanned(String barcode) async {
    final query = barcode.trim();
    if (query.isEmpty) return;

    final repository = ref.read(posRepositoryProvider);
    final matchedItem = await repository.findItemByBarcodeOrSku(query);

    if (matchedItem != null && mounted) {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: matchedItem.isProductMode
            ? matchedItem.id
            : (matchedItem.inventory?.productId ?? matchedItem.product?.id ?? matchedItem.id),
        inventoryItemId: matchedItem.isProductMode ? '' : matchedItem.id,
        name: matchedItem.name,
        price: matchedItem.price,
        qty: 1,
      );
      ref.read(cartProvider.notifier).addItem(cartItem);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item ditambahkan: ${matchedItem.name}'),
          backgroundColor: SolluColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode "$query" tidak ditemukan dalam katalog'),
          backgroundColor: SolluColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleShortcut(String key) async {
    if (!mounted) return;

    switch (key) {
      case 'F1':
        _searchFocusNode.requestFocus();
        break;

      case 'F2':
        final authorized = await _ensureAuthorized(
          'transaction.discount',
          'Diskon Manual',
        );
        if (authorized && mounted) {
          DiscountDialog.show(context);
        }
        break;

      case 'F3':
        _cartFocusNode.requestFocus();
        final cart = ref.read(cartProvider);
        if (cart.isNotEmpty) {
          final selectedIndex =
              ref.read(selectedCartIndexProvider).clamp(0, cart.length - 1);
          final item = cart[selectedIndex];
          EditCartItemDialog.show(
            context: context,
            item: item,
            onSaved: (qty, discountType, discountValue, notes) {
              ref.read(cartProvider.notifier).updateItemDetails(
                    item.id,
                    qty: qty,
                    discountType: discountType,
                    discountValue: discountValue,
                    notes: notes,
                  );
            },
          );
        }
        break;

      case 'F4':
        CustomerDialog.show(context);
        break;

      case 'F5':
        final cartF5 = ref.read(cartProvider);
        if (cartF5.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keranjang masih kosong')),
          );
          return;
        }
        final idxF5 =
            ref.read(selectedCartIndexProvider).clamp(0, cartF5.length - 1);
        final itemF5 = cartF5[idxF5];
        final authF5 = await _ensureAuthorized(
          'transaction.override_price',
          'Ubah Harga (${itemF5.name})',
        );
        if (authF5 && mounted) {
          OpenPriceDialog.show(
            context,
            item: itemF5,
            onPriceUpdated: (newPrice) {
              ref.read(cartProvider.notifier).updatePrice(itemF5.id, newPrice);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Harga "${itemF5.name}" diubah menjadi ${CurrencyFormatter.format(newPrice.toInt())}',
                  ),
                  backgroundColor: SolluColors.success,
                ),
              );
            },
          );
        }
        break;

      case 'F6':
        final cartF6 = ref.read(cartProvider);
        if (cartF6.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keranjang masih kosong')),
          );
          return;
        }
        final idxF6 =
            ref.read(selectedCartIndexProvider).clamp(0, cartF6.length - 1);
        final itemF6 = cartF6[idxF6];
        final authF6 = await _ensureAuthorized(
          'transaction.void',
          'Void Item "${itemF6.name}"',
        );
        if (authF6 && mounted) {
          ref.read(cartProvider.notifier).removeItem(itemF6.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item "${itemF6.name}" berhasil dihapus/void'),
              backgroundColor: SolluColors.warning,
            ),
          );
        }
        break;

      case 'F7':
        final cartF7 = ref.read(cartProvider);
        if (cartF7.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keranjang sudah kosong')),
          );
          return;
        }
        final authF7 = await _ensureAuthorized(
          'transaction.void',
          'Void Seluruh Transaksi',
        );
        if (authF7 && mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: SolluColors.neutral, width: 1.5),
              ),
              title: const Text(
                'Konfirmasi Void Seluruh Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Apakah Anda yakin ingin membatalkan dan mengosongkan seluruh item dalam keranjang?',
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal (Esc)'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolluColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Ya, Void Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            ref.read(cartProvider.notifier).clearCart();
            ref.read(appliedDiscountProvider.notifier).clearDiscount();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seluruh transaksi berhasil di-void'),
                backgroundColor: SolluColors.danger,
              ),
            );
          }
        }
        break;

      case 'F8':
        _handleHoldOrder();
        break;

      case 'F9':
        HoldOrdersDialog.show(context);
        break;

      case 'F10':
        final cartF10 = ref.read(cartProvider);
        if (cartF10.isEmpty) {
          EmptyCartDialog.show(context);
          return;
        }
        final allowNegF10 = ref.read(allowNegativeStockProvider);
        if (!allowNegF10) {
          final posRepo = ref.read(posRepositoryProvider);
          final outOfStockItems =
              await posRepo.checkCartStockAvailability(cartF10);
          if (outOfStockItems.isNotEmpty && mounted) {
            await InsufficientStockDialog.show(
              context,
              outOfStockItemNames: outOfStockItems,
            );
            return;
          }
        }
        if (mounted) {
          context.push('/checkout', extra: {'initialMethodType': 'cash'});
        }
        break;

      case 'F11':
        final cartF11 = ref.read(cartProvider);
        if (cartF11.isEmpty) {
          EmptyCartDialog.show(context);
          return;
        }
        final allowNegF11 = ref.read(allowNegativeStockProvider);
        if (!allowNegF11) {
          final posRepo = ref.read(posRepositoryProvider);
          final outOfStockItems =
              await posRepo.checkCartStockAvailability(cartF11);
          if (outOfStockItems.isNotEmpty && mounted) {
            await InsufficientStockDialog.show(
              context,
              outOfStockItemNames: outOfStockItems,
            );
            return;
          }
        }
        if (mounted) {
          context.push('/checkout', extra: {'initialMethodType': 'qris'});
        }
        break;

      case 'F12':
        _handleCheckout();
        break;

      case 'Space':
        final authDrawer = await _ensureAuthorized(
          'transaction.open_drawer',
          'Buka Laci Kasir Manual',
        );
        if (authDrawer && mounted) {
          final res = await openCashDrawerAction(ref: ref);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.message),
                backgroundColor:
                    res.success ? SolluColors.success : SolluColors.warning,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        break;

      case 'Esc':
        _searchController.clear();
        ref.read(posSearchQueryProvider.notifier).setQuery('');
        _keyboardFocusNode.requestFocus();
        break;
    }
  }

  Future<void> _handleHoldOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keranjang masih kosong, tidak ada pesanan untuk ditahan.',
          ),
          backgroundColor: SolluColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final labelController = TextEditingController(
      text:
          'Pesanan #${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    );

    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SolluColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: SolluColors.neutral, width: 1.0),
        ),
        title: const Text('Tahan Pesanan (Hold)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beri label atau catatan untuk pesanan ini (misal meja/pelanggan):',
              style: TextStyle(fontSize: 13, color: SolluColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Contoh: Meja 5 / Budi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () =>
                Navigator.of(ctx).pop(labelController.text.trim()),
            child: const Text('Tahan Pesanan'),
          ),
        ],
      ),
    );

    if (label != null && label.isNotEmpty && mounted) {
      final heldOrder =
          await ref.read(heldBillsServiceProvider).holdCurrentCart(
                items: cart,
                holdLabel: label,
              );
      if (heldOrder != null && mounted) {
        ref.read(appliedDiscountProvider.notifier).clearDiscount();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Pesanan '$label' berhasil disimpan ke daftar Hold. Tekan F9 untuk memuat kembali.",
            ),
            backgroundColor: SolluColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckout() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      EmptyCartDialog.show(context);
      return;
    }

    final allowNegativeStock = ref.read(allowNegativeStockProvider);
    if (!allowNegativeStock) {
      final posRepo = ref.read(posRepositoryProvider);
      final outOfStockItems = await posRepo.checkCartStockAvailability(cart);
      if (outOfStockItems.isNotEmpty && mounted) {
        await InsufficientStockDialog.show(
          context,
          outOfStockItemNames: outOfStockItems,
        );
        return;
      }
    }

    if (mounted) {
      context.push('/checkout');
    }
  }

  Future<void> _handleBackToDashboard() async {
    final cart = ref.read(cartProvider);
    if (cart.isNotEmpty) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
            'Terdapat ${cart.length} jenis item di keranjang belanja. Pesanan akan tetap tersimpan sementara di kasir ini.',
            style: const TextStyle(fontSize: 14, color: SolluColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: SolluColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ya, ke Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
    final activeShiftAsync = ref.watch(activeShiftProvider);

    // Initialize auto-sync watcher
    ref.watch(autoSyncProvider);

    // Sync search text field when searchQuery provider is reset externally (e.g. after checkout)
    ref.listen<String>(posSearchQueryProvider, (prev, next) {
      if (next.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    // Optimasi Riverpod: ref.listen tidak memicu rebuild UI, cukup merespons event shortcut
    ref.listen<String?>(shortcutProvider, (previous, next) {
      if (next != null) {
        _handleShortcut(next);
      }
    });

    return HardwareScannerListener(
      onBarcodeScanned: (barcode) => _handleBarcodeScanned(barcode),
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final logicalKey = event.logicalKey;
            final isCtrl = HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed;

            // Ctrl + P: Cetak ulang struk transaksi terakhir
            if (isCtrl && logicalKey == LogicalKeyboardKey.keyP) {
              _handleReprintLastReceipt();
              return KeyEventResult.handled;
            }

            // Spacebar: Buka laci kasir manual jika tidak sedang fokus di pencarian
            if (logicalKey == LogicalKeyboardKey.space &&
                !_searchFocusNode.hasFocus) {
              ref.read(shortcutProvider.notifier).trigger('Space');
              return KeyEventResult.handled;
            }

            // Panah Bawah / Atas: Navigasi item keranjang
            if (logicalKey == LogicalKeyboardKey.arrowDown &&
                !_searchFocusNode.hasFocus) {
              final cart = ref.read(cartProvider);
              if (cart.isNotEmpty) {
                final current = ref.read(selectedCartIndexProvider);
                final next = (current + 1).clamp(0, cart.length - 1);
                ref.read(selectedCartIndexProvider.notifier).state = next;
              }
              return KeyEventResult.handled;
            } else if (logicalKey == LogicalKeyboardKey.arrowUp &&
                !_searchFocusNode.hasFocus) {
              final cart = ref.read(cartProvider);
              if (cart.isNotEmpty) {
                final current = ref.read(selectedCartIndexProvider);
                final next = (current - 1).clamp(0, cart.length - 1);
                ref.read(selectedCartIndexProvider.notifier).state = next;
              }
              return KeyEventResult.handled;
            }

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
            } else if (logicalKey == LogicalKeyboardKey.f11) {
              ref.read(shortcutProvider.notifier).trigger('F11');
              return KeyEventResult.handled;
            } else if (logicalKey == LogicalKeyboardKey.f12) {
              ref.read(shortcutProvider.notifier).trigger('F12');
              return KeyEventResult.handled;
            } else if (logicalKey == LogicalKeyboardKey.escape) {
              ref.read(shortcutProvider.notifier).trigger('Esc');
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: SolluColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Kembali ke Dashboard',
                child: InkWell(
                  onTap: _handleBackToDashboard,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SolluColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SolluColors.neutral),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: SolluColors.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Image.asset('img/logo-colored.png', height: 32),
              const SizedBox(width: 18),
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
                      final matchedItem = await repository
                          .findItemByBarcodeOrSku(query);

                      if (matchedItem != null) {
                        final cartItem = CartItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          productId: matchedItem.isProductMode
                              ? matchedItem.id
                              : (matchedItem.inventory?.productId ?? matchedItem.product?.id ?? matchedItem.id),
                          inventoryItemId: matchedItem.isProductMode
                              ? ''
                              : matchedItem.id,
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
                            content: Text(
                              'Barcode/SKU "$query" tidak ditemukan',
                            ),
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
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: SolluColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: SolluColors.neutralMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: SolluColors.neutral,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: SolluColors.neutral,
                        ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final heldBillsAsync =
                      ref.watch(heldTransactionsStreamProvider);
                  final count = heldBillsAsync.asData?.value.length ?? 0;
                  return InkWell(
                    onTap: () => HeldBillsDrawer.showAsDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 38),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: count > 0
                            ? SolluColors.warning.withValues(alpha: 0.1)
                            : SolluColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: count > 0
                              ? SolluColors.warning
                              : SolluColors.neutral,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            size: 16,
                            color: count > 0
                                ? SolluColors.warning
                                : SolluColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hold ($count)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: count > 0
                                  ? SolluColors.warning
                                  : SolluColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? SolluColors.success.withValues(alpha: 0.1)
                          : SolluColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOnline
                            ? SolluColors.success
                            : SolluColors.danger,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOnline ? Icons.wifi : Icons.wifi_off,
                          size: 14,
                          color: isOnline
                              ? SolluColors.success
                              : SolluColors.danger,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOnline
                                ? SolluColors.success
                                : SolluColors.danger,
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
                      ? ref
                            .watch(cashierNameProvider(shift.userId))
                            .when(
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
                            isShiftOpen
                                ? Icons.storefront
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: isShiftOpen
                                ? SolluColors.primary
                                : SolluColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shiftText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isShiftOpen
                                  ? SolluColors.primary
                                  : SolluColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 8),
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  final unsyncedCountAsync =
                      ref.watch(unsyncedTransactionsCountProvider);
                  final failedCountAsync =
                      ref.watch(failedTransactionsCountProvider);
                  final unsyncedCount = unsyncedCountAsync.value ?? 0;
                  final failedCount = failedCountAsync.value ?? 0;

                  return Tooltip(
                    message: 'Sinkronkan Transaksi & Data',
                    child: InkWell(
                      onTap: _isSyncing
                          ? null
                          : () async {
                              setState(() {
                                _isSyncing = true;
                              });

                              final messenger = ScaffoldMessenger.of(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Menyinkronkan transaksi dan pembaruan data...',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              try {
                                final syncCoordinator = ref.read(
                                  syncCoordinatorServiceProvider,
                                );
                                final result =
                                    await syncCoordinator.synchronizeAll();

                                ref.invalidate(employeeListProvider);
                                ref.invalidate(posItemsProvider);
                                ref.invalidate(posCategoriesProvider);
                                ref.invalidate(
                                  currentShiftTransactionsProvider,
                                );
                                ref.invalidate(allTransactionsProvider);
                                ref.invalidate(heldTransactionsStreamProvider);

                                ref
                                    .read(lastSyncProvider.notifier)
                                    .updateTimestamp();

                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.userFriendlyMessage,
                                      ),
                                      backgroundColor: result.hasFailures
                                          ? SolluColors.warning
                                          : Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tidak dapat terhubung ke server. Data transaksi tetap aman di perangkat kasir.',
                                      ),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: SolluColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: _isSyncing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.sync,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                            ),
                            if (!_isSyncing && failedCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: SolluColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$failedCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else if (!_isSyncing && unsyncedCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SolluColors.warning,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unsyncedCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
                const Expanded(flex: 2, child: CategorySidebar()),
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
                Expanded(flex: 3, child: CartPanel(focusNode: _cartFocusNode)),
              ],
            ),

            // Floating Sync Overlay
            const SyncProgressOverlay(),
          ],
        ),
        ),
      ),
    );
  }
}
