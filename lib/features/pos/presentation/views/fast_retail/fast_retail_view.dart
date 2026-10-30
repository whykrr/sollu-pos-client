import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/hardware_scanner_listener.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/held_bills_drawer.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/insufficient_stock_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/supervisor_challenge_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/variant_dialog.dart';
import 'fast_retail_checkout_dialog.dart';
import 'fast_retail_cockpit.dart';
import 'fast_retail_header.dart';
import 'fast_retail_keyboard_guide_dialog.dart';
import 'fast_retail_table_pane.dart';

/// Ekosistem Tampilan Kasir Cepat (Fast Retail View)
/// Dirancang untuk minimarket, toko kelontong & retail bervolume tinggi berbasis keyboard dan barcode hardware.
class FastRetailView extends ConsumerStatefulWidget {
  const FastRetailView({super.key});

  @override
  ConsumerState<FastRetailView> createState() => _FastRetailViewState();
}

class _FastRetailViewState extends ConsumerState<FastRetailView> {
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _omniSearchFocusNode = FocusNode();
  final FocusNode _tableFocusNode = FocusNode();
  final TextEditingController _omniSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ensureOmniFocused();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _omniSearchFocusNode.dispose();
    _tableFocusNode.dispose();
    _omniSearchController.dispose();
    super.dispose();
  }

  void _ensureOmniFocused() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _omniSearchFocusNode.canRequestFocus) {
        _omniSearchFocusNode.requestFocus();
      }
    });
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

    final enableSupervisorPin = ref.read(enableSupervisorPinProvider);
    if (!enableSupervisorPin) {
      return true;
    }

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
      if (!mounted) return;
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
                backgroundColor: res.success ? SolluColors.success : SolluColors.danger,
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

  Future<void> _handleBarcodeOrSearchSubmit(String input, int multiplier) async {
    final query = input.trim();
    if (query.isEmpty) {
      _ensureOmniFocused();
      return;
    }

    final repository = ref.read(posRepositoryProvider);
    final matchedItem = await repository.findItemByBarcodeOrSku(query);

    if (!mounted) return;

    if (matchedItem == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode/SKU "$query" tidak ditemukan dalam katalog'),
          backgroundColor: SolluColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
      _omniSearchController.clear();
      _ensureOmniFocused();
      return;
    }

    if (!matchedItem.isActive) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${matchedItem.name} sedang dinonaktifkan dari kasir.'),
          backgroundColor: SolluColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
      _omniSearchController.clear();
      _ensureOmniFocused();
      return;
    }

    final isVariantBarcode = matchedItem.barcode == query || matchedItem.sku == query;
    final isParentScan = matchedItem.hasVariants && !isVariantBarcode;

    if (isParentScan) {
      final parentPosItem = PosItem(
        id: matchedItem.product?.id ?? matchedItem.id,
        name: matchedItem.product?.name ?? matchedItem.name,
        categoryId: matchedItem.categoryId,
        price: matchedItem.price,
        stock: matchedItem.stock,
        unit: matchedItem.unit,
        productType: matchedItem.productType,
        isActive: matchedItem.isActive,
        hasVariants: true,
        hasModifiers: matchedItem.hasModifiers,
        isProductMode: true,
        product: matchedItem.product,
        trackInventory: matchedItem.trackInventory,
      );

      _omniSearchController.clear();
      await VariantDialog.show(context, parentPosItem);
      _ensureOmniFocused();
    } else {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: matchedItem.product?.id ??
            (matchedItem.isProductMode
                ? matchedItem.id
                : (matchedItem.inventory?.productId ?? matchedItem.id)),
        productItemId: matchedItem.productItemId ?? matchedItem.id,
        inventoryItemId: matchedItem.isProductMode ? '' : matchedItem.id,
        name: matchedItem.name,
        variantCombination: matchedItem.variantCombination,
        trackInventory: matchedItem.trackInventory,
        price: matchedItem.price,
        qty: multiplier > 0 ? multiplier : 1,
        barcode: matchedItem.barcode,
        sku: matchedItem.sku,
      );

      ref.read(cartProvider.notifier).addItem(cartItem);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item ditambahkan: ${matchedItem.name} (${cartItem.qty}x)'),
          backgroundColor: SolluColors.success,
          duration: const Duration(seconds: 1),
        ),
      );

      _omniSearchController.clear();
      _ensureOmniFocused();
    }
  }

  void _handleItemPickedFromDropdown(PosItem item) {
    // Check if parent product with variants
    if (item.hasVariants && item.variantCombination == null) {
      _omniSearchController.clear();
      VariantDialog.show(context, item);
      _ensureOmniFocused();
      return;
    }

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: item.product?.id ?? item.id,
      productItemId: item.productItemId ?? item.id,
      inventoryItemId: item.inventory?.id ?? '',
      name: item.name,
      variantCombination: item.variantCombination,
      trackInventory: item.trackInventory,
      price: item.price,
      qty: 1,
      barcode: item.barcode,
      sku: item.sku,
    );

    ref.read(cartProvider.notifier).addItem(cartItem);
    _omniSearchController.clear();
    _ensureOmniFocused();
  }

  void _handleBarcodeScanned(String barcode) {
    // Extract multiplier from omni-bar if typed prior to scan (e.g. '3*')
    final currentText = _omniSearchController.text.trim();
    int multiplier = 1;
    final match = RegExp(r'^(\d+)\*').firstMatch(currentText);
    if (match != null) {
      multiplier = int.tryParse(match.group(1) ?? '1') ?? 1;
    }

    _handleBarcodeOrSearchSubmit(barcode, multiplier);
  }

  Future<void> _handleCheckout({String? initialMethodType}) async {
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
      await FastRetailCheckoutDialog.show(
        context,
        initialMethodType: initialMethodType,
      );
      _ensureOmniFocused();
    }
  }

  Future<void> _handleHoldOrder() async {
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

    final labelController = TextEditingController(
      text: 'Pesanan #${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
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
              'Beri label atau catatan untuk pesanan ini:',
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
            onPressed: () => Navigator.of(ctx).pop(labelController.text.trim()),
            child: const Text('Tahan Pesanan'),
          ),
        ],
      ),
    );

    if (label != null && label.isNotEmpty && mounted) {
      final heldOrder = await ref.read(heldBillsServiceProvider).holdCurrentCart(
            items: cart,
            holdLabel: label,
          );
      if (heldOrder != null && mounted) {
        ref.read(appliedDiscountProvider.notifier).clearDiscount();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pesanan '$label' berhasil disimpan ke daftar Hold."),
            backgroundColor: SolluColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        _ensureOmniFocused();
      }
    }
  }

  Future<void> _handleClearCartConfirmation() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final authorized = await _ensureAuthorized(
      'transaction.void',
      'Void Seluruh Transaksi',
    );
    if (!authorized || !mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SolluColors.neutral, width: 1.5),
        ),
        title: const Text(
          'Kosongkan Keranjang?',
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
            child: const Text('Ya, Kosongkan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(appliedDiscountProvider.notifier).clearDiscount();
      _ensureOmniFocused();
    }
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

  Future<void> _handleDeleteActiveRow() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final selectedIndex = ref.read(selectedCartIndexProvider).clamp(0, cart.length - 1);
    final item = cart[selectedIndex];

    final authorized = await _ensureAuthorized(
      'transaction.void',
      'Void Item "${item.name}"',
    );
    if (authorized && mounted) {
      ref.read(cartProvider.notifier).removeItem(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item "${item.name}" berhasil dihapus/void'),
          backgroundColor: SolluColors.warning,
          duration: const Duration(seconds: 1),
        ),
      );
      _ensureOmniFocused();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for shortcutProvider triggers
    ref.listen<String?>(shortcutProvider, (prev, next) {
      if (next == '?') {
        FastRetailKeyboardGuideDialog.show(context);
      } else if (next == 'Space') {
        openCashDrawerAction(ref: ref);
      }
    });

    return HardwareScannerListener(
      onBarcodeScanned: _handleBarcodeScanned,
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          final logicalKey = event.logicalKey;
          final isCtrl = HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed;

          // Ctrl + P: Cetak ulang struk terakhir
          if (isCtrl && logicalKey == LogicalKeyboardKey.keyP) {
            _handleReprintLastReceipt();
            return KeyEventResult.handled;
          }

          // '?' Key (when omni search is not typing)
          if ((event.character == '?' ||
                  (logicalKey == LogicalKeyboardKey.slash &&
                      HardwareKeyboard.instance.isShiftPressed)) &&
              !_omniSearchFocusNode.hasFocus) {
            FastRetailKeyboardGuideDialog.show(context);
            return KeyEventResult.handled;
          }

          // Space: Cash drawer kick (if enabled and not focused in omni)
          if (logicalKey == LogicalKeyboardKey.space && !_omniSearchFocusNode.hasFocus) {
            if (ref.read(featureGatingProvider).canUseCashDrawer()) {
              openCashDrawerAction(ref: ref);
              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: SolluColors.background,
          appBar: FastRetailHeader(
            searchController: _omniSearchController,
            searchFocusNode: _omniSearchFocusNode,
            onFocusTable: () => _tableFocusNode.requestFocus(),
            onBarcodeOrSearchSubmit: _handleBarcodeOrSearchSubmit,
            onItemPickedFromDropdown: _handleItemPickedFromDropdown,
            onEmptyEnterCheckout: () => _handleCheckout(initialMethodType: 'cash'),
            onClearCartRequested: _handleClearCartConfirmation,
            onBackToDashboard: _handleBackToDashboard,
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Table Pane (Flex 7)
              Expanded(
                flex: 7,
                child: FastRetailTablePane(
                  focusNode: _tableFocusNode,
                  omniFocusNode: _omniSearchFocusNode,
                  onFocusOmni: _ensureOmniFocused,
                  onOpenDiscount: () => DiscountDialog.show(context),
                  onHoldBill: _handleHoldOrder,
                  onRecallBills: () => HeldBillsDrawer.showAsDialog(context),
                  ensureAuthorized: _ensureAuthorized,
                ),
              ),

              // Right Industry Cockpit (Flex 3)
              Expanded(
                flex: 3,
                child: FastRetailCockpit(
                  onPay: () => _handleCheckout(initialMethodType: 'cash'),
                  onHold: _handleHoldOrder,
                  onRecall: () => HeldBillsDrawer.showAsDialog(context),
                  onDiscount: () => DiscountDialog.show(context),
                  onDeleteRow: _handleDeleteActiveRow,
                  onCancelCart: _handleClearCartConfirmation,
                  onOpenGuide: () => FastRetailKeyboardGuideDialog.show(context),
                  onChangeCustomer: () => CustomerDialog.show(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
