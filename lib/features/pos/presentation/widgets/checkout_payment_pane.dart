import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/sollu_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_mode_provider.dart';
import '../providers/pos_provider.dart';
import '../providers/promo_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/insufficient_stock_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/outlet_settings_provider.dart';
import '../../../settings/presentation/providers/printer_provider.dart';
import '../../../shift/presentation/providers/shift_provider.dart';

class CheckoutPaymentPane extends ConsumerStatefulWidget {
  final String? initialMethodType;
  final VoidCallback? onCompleted;

  const CheckoutPaymentPane({
    super.key,
    this.initialMethodType,
    this.onCompleted,
  });

  @override
  ConsumerState<CheckoutPaymentPane> createState() =>
      _CheckoutPaymentPaneState();
}

class _CheckoutPaymentPaneState extends ConsumerState<CheckoutPaymentPane> {
  PaymentMethod? _selectedMethod;
  final TextEditingController _cashReceivedController =
      TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _cashReceivedFocusNode = FocusNode();
  final FocusNode _referenceFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();
  double _cashReceived = 0.0;
  bool _isProcessing = false;
  bool _autoPrintReceipt = true;
  String? _selectedOrderType;

  @override
  void initState() {
    super.initState();
    // Default auto print dari preferences
    final autoPrint =
        ref.read(outletSettingsServiceProvider).getAutoPrint();
    _autoPrintReceipt = autoPrint;

    final isFastRetail = ref.read(posModeProvider) == PosMode.fastRetail;
    if (isFastRetail) {
      _selectedOrderType = 'walk_in';
    } else {
      final orderTypes = ref.read(posOrderTypesProvider);
      if (orderTypes.isNotEmpty) {
        _selectedOrderType = orderTypes.first;
      } else {
        _selectedOrderType = 'walk_in';
      }
    }
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _cashReceivedFocusNode.dispose();
    _referenceFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'qris':
        return Icons.qr_code_scanner;
      case 'edc':
      case 'debit':
      case 'credit':
        return Icons.credit_card;
      case 'transfer':
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  List<double> _getQuickCashOptions(double total) {
    final Set<double> options = {total};

    final denominations = [10000.0, 20000.0, 50000.0, 100000.0];
    for (final denom in denominations) {
      if (total < denom) {
        options.add(denom);
      }
    }

    final next50k = (total / 50000.0).ceil() * 50000.0;
    if (next50k > total) options.add(next50k);

    final next100k = (total / 100000.0).ceil() * 100000.0;
    if (next100k > total) options.add(next100k);

    final list = options.toList()..sort();
    return list.take(5).toList();
  }

  void _onNumpadTapped(String char, double grandTotal) {
    String currentText = _cashReceived.toInt().toString();
    if (currentText == '0') currentText = '';

    if (char == 'C') {
      currentText = '0';
    } else if (char == 'DEL') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
      if (currentText.isEmpty) currentText = '0';
    } else if (char == 'PAS') {
      currentText = grandTotal.toInt().toString();
    } else {
      currentText += char;
    }

    final parsed = double.tryParse(currentText) ?? 0.0;
    setState(() {
      _cashReceived = parsed;
      _cashReceivedController.text =
          CurrencyInputFormatter.format(parsed.toInt());
    });
  }

  Future<void> _handlePaymentSubmit(double grandTotal) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang belanja kosong!'),
          backgroundColor: SolluColors.warning,
        ),
      );
      return;
    }

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu!'),
          backgroundColor: SolluColors.warning,
        ),
      );
      return;
    }

    final isCash = _selectedMethod!.type == 'cash' ||
        _selectedMethod!.name.toLowerCase().contains('tunai');

    if (isCash && _cashReceived < grandTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang dari total tagihan!'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }

    // Validasi nomor referensi jika kebijakan wajib diisi (mandatory)
    final policy = _selectedMethod!.referencePolicy;
    if (policy == 'mandatory' && _referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nomor referensi / approval code wajib diisi untuk ${_selectedMethod!.name}!',
          ),
          backgroundColor: SolluColors.danger,
        ),
      );
      _referenceFocusNode.requestFocus();
      return;
    }

    // Validasi ketersediaan stok jika toleransi stok minus dinonaktifkan
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

    setState(() {
      _isProcessing = true;
    });

    try {
      final appliedDiscount = ref.read(appliedDiscountProvider);
      final activeShift = ref.read(activeShiftProvider).asData?.value;
      final activeEmployee = ref.read(activeEmployeeProvider);
      final taxRate = ref.read(activeTaxRateProvider);
      final serviceChargeRate = ref.read(activeServiceChargeRateProvider);
      final taxIncluded = ref.read(taxIncludedInPriceProvider);

      final double subtotal = cart.fold(
        0.0,
        (sum, item) => sum + item.calculatedSubtotal,
      );
      final double discountAmount = appliedDiscount != null
          ? appliedDiscount.calculateDiscount(subtotal)
          : 0.0;
      final double taxableAmount =
          (subtotal - discountAmount).clamp(0.0, double.infinity);
      final double tax = calculateTaxAmount(
        taxableAmount: taxableAmount,
        taxRate: taxRate,
        taxIncludedInPrice: taxIncluded,
      );
      final double serviceCharge = serviceChargeRate > 0
          ? (taxableAmount * (serviceChargeRate / 100.0))
          : 0.0;

      final double changeAmount =
          isCash ? (_cashReceived - grandTotal) : 0.0;

      final repository = ref.read(transactionRepositoryProvider);
      final txResult = await repository.createTransaction(
        shiftId: activeShift?.id,
        cashierId: activeEmployee?['id']?.toString(),
        items: cart,
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountType: appliedDiscount?.type,
        discountValue: appliedDiscount?.value,
        promoName: appliedDiscount?.name,
        promoId: appliedDiscount?.promoId,
        taxAmount: tax,
        serviceChargeAmount: serviceCharge,
        total: grandTotal,
        paymentMethod: _selectedMethod!,
        cashReceived: isCash ? _cashReceived : grandTotal,
        changeAmount: changeAmount,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        type: (ref.read(posModeProvider) == PosMode.fastRetail)
            ? 'walk_in'
            : (_selectedOrderType ?? 'walk_in'),
      );

      if (mounted) {
        final printerConfig = ref.read(selectedPrinterProvider);
        final bool shouldOpenDrawer = (_selectedMethod?.openCashDrawer ?? isCash) && (printerConfig?.openCashDrawer ?? false);
        final outletProfile = ref.read(outletProfileProvider);
        final String? outletName = outletProfile?['name']?.toString();

        // Jika struk dicetak otomatis:
        // generator.drawer() sudah otomatis digabung dalam byte print struk di PrinterService.
        // Hanya panggil openCashDrawerAction terpisah jika TIDAK auto-print struk.
        if (shouldOpenDrawer && !_autoPrintReceipt) {
          openCashDrawerAction(ref: ref).then((result) {
            if (!result.success && mounted) {
              debugPrint('Gagal membuka laci kasir: ${result.message}');
            }
          });
        }

        // Cetak struk jika auto-print aktif
        if (_autoPrintReceipt) {
          final messenger = ScaffoldMessenger.of(context);
          printTransactionReceiptAction(
            ref: ref,
            transactionId: txResult.transaction.id,
            outletName: outletName,
          ).then((result) {
            if (!result.success) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Gagal mencetak struk: ${result.message}',
                  ),
                  backgroundColor: SolluColors.warning,
                ),
              );
            }
          });
        }

        _showSuccessDialog(
          txResult.transaction,
          _selectedMethod!,
          changeAmount,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses transaksi: $e'),
            backgroundColor: SolluColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(
    Transaction tx,
    PaymentMethod method,
    double changeAmount,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        void finishAndReturn() {
          Navigator.of(dialogContext).pop();
          // Reset cart & diskon
          ref.read(cartProvider.notifier).clearCart();
          ref.read(appliedDiscountProvider.notifier).clearDiscount();
          // Reset filter kategori dan pencarian produk ke kondisi normal
          ref.read(posSelectedCategoryProvider.notifier).setCategory(null);
          ref.read(posSearchQueryProvider.notifier).setQuery('');
          if (widget.onCompleted != null) {
            widget.onCompleted!();
          } else {
            context.go('/pos');
          }
        }

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.numpadEnter ||
                key == LogicalKeyboardKey.space ||
                key == LogicalKeyboardKey.escape) {
              finishAndReturn();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: AlertDialog(
            backgroundColor: SolluColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: SolluColors.neutral, width: 1.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5), // Green 100
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: SolluColors.success,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No. Transaksi: ${tx.transactionNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: SolluColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                if (changeAmount > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: SolluColors.success.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kembalian',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolluColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(changeAmount.toInt()),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: SolluColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(
                            color: SolluColors.neutral,
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final outletProfile = ref.read(outletProfileProvider);
                          printTransactionReceiptAction(
                            ref: ref,
                            transactionId: tx.id,
                            outletName: outletProfile?['name']?.toString(),
                          );
                        },
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: finishAndReturn,
                        child: const Text('Selesai (Enter)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handlePaymentShortcuts({
    required KeyEvent event,
    required List<PaymentMethod> methods,
    required double grandTotal,
    required bool isUnderpaid,
    required bool roundingEnabled,
    required String roundingMode,
    required double baseGrandTotal,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final primaryFocus = FocusManager.instance.primaryFocus;
    final isEditingText = _cashReceivedFocusNode.hasFocus ||
        _referenceFocusNode.hasFocus ||
        _notesFocusNode.hasFocus ||
        (primaryFocus?.context?.widget is EditableText);

    final isAlt = HardwareKeyboard.instance.isAltPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    void selectMethodByIndex(int index) {
      if (index >= 0 && index < methods.length) {
        final m = methods[index];
        setState(() {
          _selectedMethod = m;
          final methodIsCash = m.type.toLowerCase() == 'cash' ||
              m.name.toLowerCase().contains('tunai');
          if (methodIsCash) {
            final payable = roundingEnabled
                ? applyCashRounding(
                    amount: baseGrandTotal,
                    roundingEnabled: true,
                    roundingMode: roundingMode,
                  )
                : baseGrandTotal;
            _cashReceived = payable;
            _cashReceivedController.text =
                CurrencyInputFormatter.format(payable.toInt());
          }
        });
      }
    }

    // Alt + 1..4: Akses cepat metode pembayaran 1..4
    if (isAlt) {
      if (event.logicalKey == LogicalKeyboardKey.digit1 || event.logicalKey == LogicalKeyboardKey.numpad1) {
        selectMethodByIndex(0);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit2 || event.logicalKey == LogicalKeyboardKey.numpad2) {
        selectMethodByIndex(1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit3 || event.logicalKey == LogicalKeyboardKey.numpad3) {
        selectMethodByIndex(2);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.digit4 || event.logicalKey == LogicalKeyboardKey.numpad4) {
        selectMethodByIndex(3);
        return KeyEventResult.handled;
      }
    }

    // Tab / Shift+Tab / Arrow Left / Arrow Right: Berpindah metode pembayaran saat tidak edit teks
    if (!isEditingText) {
      if (event.logicalKey == LogicalKeyboardKey.tab ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (methods.isNotEmpty) {
          final currentIdx = methods.indexWhere((m) => m.id == _selectedMethod?.id);
          final nextIdx = isShift
              ? (currentIdx - 1 + methods.length) % methods.length
              : (currentIdx + 1) % methods.length;
          selectMethodByIndex(nextIdx);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (methods.isNotEmpty) {
          final currentIdx = methods.indexWhere((m) => m.id == _selectedMethod?.id);
          final prevIdx = (currentIdx - 1 + methods.length) % methods.length;
          selectMethodByIndex(prevIdx);
          return KeyEventResult.handled;
        }
      }

      // 1, 2, 3 direct selection
      if (event.logicalKey == LogicalKeyboardKey.digit1 ||
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        final cashMethod = methods.firstWhereOrNull(
          (m) =>
              m.type.toLowerCase() == 'cash' ||
              m.name.toLowerCase().contains('tunai'),
        );
        if (cashMethod != null) {
          selectMethodByIndex(methods.indexOf(cashMethod));
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        final qrisMethod = methods.firstWhereOrNull(
          (m) =>
              m.type.toLowerCase() == 'qris' ||
              m.name.toLowerCase().contains('qris'),
        );
        if (qrisMethod != null) {
          selectMethodByIndex(methods.indexOf(qrisMethod));
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        final cardMethod = methods.firstWhereOrNull(
          (m) =>
              ['edc', 'debit', 'credit'].contains(m.type.toLowerCase()) ||
              m.name.toLowerCase().contains('edc') ||
              m.name.toLowerCase().contains('debit') ||
              m.name.toLowerCase().contains('kartu'),
        );
        if (cardMethod != null) {
          selectMethodByIndex(methods.indexOf(cardMethod));
          return KeyEventResult.handled;
        }
      }
    }

    // Enter / NumpadEnter: Selesaikan Pembayaran Tender
    if ((event.logicalKey == LogicalKeyboardKey.enter && !isEditingText) ||
        (event.logicalKey == LogicalKeyboardKey.numpadEnter && !isEditingText)) {
      if (!_isProcessing && !isUnderpaid && _selectedMethod != null) {
        _handlePaymentSubmit(grandTotal);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsAsync = ref.watch(activePaymentMethodsProvider);
    final cart = ref.watch(cartProvider);
    final appliedDiscount = ref.watch(appliedDiscountProvider);
    final taxRate = ref.watch(activeTaxRateProvider);
    final serviceChargeRate = ref.watch(activeServiceChargeRateProvider);
    final taxIncluded = ref.watch(taxIncludedInPriceProvider);
    final roundingEnabled = ref.watch(roundingEnabledProvider);
    final roundingMode = ref.watch(roundingModeProvider);

    final double subtotal = cart.fold(
      0.0,
      (sum, item) => sum + item.calculatedSubtotal,
    );
    final double discountAmount = appliedDiscount != null
        ? appliedDiscount.calculateDiscount(subtotal)
        : 0.0;
    final double taxableAmount =
        (subtotal - discountAmount).clamp(0.0, double.infinity);
    final double tax = calculateTaxAmount(
      taxableAmount: taxableAmount,
      taxRate: taxRate,
      taxIncludedInPrice: taxIncluded,
    );
    final double serviceCharge = serviceChargeRate > 0
        ? (taxableAmount * (serviceChargeRate / 100.0))
        : 0.0;
    final double baseGrandTotal = calculateGrandTotal(
      taxableAmount: taxableAmount,
      taxAmount: tax,
      serviceChargeAmount: serviceCharge,
      taxIncludedInPrice: taxIncluded,
    );

    return paymentMethodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Gagal memuat metode pembayaran: $e'),
      ),
      data: (methods) {
        if (methods.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada metode pembayaran yang aktif.',
              style: TextStyle(color: SolluColors.textMuted),
            ),
          );
        }

        // Inisialisasi selected method pertama kali
        if (_selectedMethod == null) {
          if (widget.initialMethodType != null) {
            _selectedMethod = methods.firstWhere(
              (m) =>
                  m.type.toLowerCase() ==
                  widget.initialMethodType!.toLowerCase(),
              orElse: () => methods.first,
            );
          } else {
            _selectedMethod = methods.first;
          }

          final initialIsCash = _selectedMethod?.type == 'cash' ||
              (_selectedMethod?.name.toLowerCase().contains('tunai') ?? false);
          final initialPayable = initialIsCash && roundingEnabled
              ? applyCashRounding(
                  amount: baseGrandTotal,
                  roundingEnabled: true,
                  roundingMode: roundingMode,
                )
              : baseGrandTotal;

          if (_cashReceived == 0.0) {
            _cashReceived = initialPayable;
            _cashReceivedController.text =
                CurrencyInputFormatter.format(initialPayable.toInt());
          }
        }

        final isCash = _selectedMethod?.type == 'cash' ||
            (_selectedMethod?.name.toLowerCase().contains('tunai') ?? false);

        final double grandTotal = isCash && roundingEnabled
            ? applyCashRounding(
                amount: baseGrandTotal,
                roundingEnabled: true,
                roundingMode: roundingMode,
              )
            : baseGrandTotal;

        final double change = isCash ? (_cashReceived - grandTotal) : 0.0;
        final bool isUnderpaid = isCash && _cashReceived < grandTotal;

        final isFastRetail = ref.watch(posModeProvider) == PosMode.fastRetail;
        final posOrderTypes = ref.watch(posOrderTypesProvider);
        if (isFastRetail) {
          _selectedOrderType = 'walk_in';
        } else if (_selectedOrderType == null || !posOrderTypes.contains(_selectedOrderType)) {
          if (posOrderTypes.isNotEmpty) {
            _selectedOrderType = posOrderTypes.first;
          }
        }

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) => _handlePaymentShortcuts(
            event: event,
            methods: methods,
            grandTotal: grandTotal,
            isUnderpaid: isUnderpaid,
            roundingEnabled: roundingEnabled,
            roundingMode: roundingMode,
            baseGrandTotal: baseGrandTotal,
          ),
          child: Container(
            color: SolluColors.background,
            padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector Tipe Pesanan (hanya tampil jika bukan Kasir Cepat dan > 1 opsi aktif)
              if (!isFastRetail && posOrderTypes.length > 1) ...[
                const Text(
                  'Tipe Pesanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SolluColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: posOrderTypes.map((typeKey) {
                    final isSelected = _selectedOrderType == typeKey;
                    final label = typeKey == 'walk_in'
                        ? 'Walk-In'
                        : typeKey == 'dine_in'
                            ? 'Dine-In'
                            : typeKey == 'take_away'
                                ? 'Take-Away'
                                : typeKey;
                    final icon = typeKey == 'walk_in'
                        ? Icons.directions_walk
                        : typeKey == 'dine_in'
                            ? Icons.restaurant
                            : Icons.shopping_bag_outlined;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOrderType = typeKey;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? SolluColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? SolluColors.primary
                                  : SolluColors.neutral,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : SolluColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : SolluColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Selector Metode Pembayaran (Horizontal List / Wrap)
              const Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: methods.map((method) {
                    final isSelected = _selectedMethod?.id == method.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMethod = method;
                            final methodIsCash = method.type == 'cash' ||
                                method.name.toLowerCase().contains('tunai');
                            final payableTotal = methodIsCash && roundingEnabled
                                ? applyCashRounding(
                                    amount: baseGrandTotal,
                                    roundingEnabled: true,
                                    roundingMode: roundingMode,
                                  )
                                : baseGrandTotal;
                            if (methodIsCash) {
                              _cashReceived = payableTotal;
                              _cashReceivedController.text =
                                  CurrencyInputFormatter.format(
                                payableTotal.toInt(),
                              );
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? SolluColors.primary.withValues(alpha: 0.08)
                                : SolluColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? SolluColors.primary
                                  : SolluColors.neutral,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getIconForType(method.type),
                                size: 20,
                                color: isSelected
                                    ? SolluColors.primary
                                    : SolluColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                method.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? SolluColors.primary
                                      : SolluColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Body Berdasarkan Tipe Pembayaran (Cash vs Non-Cash)
              Expanded(
                child: isCash
                    ? _buildCashPaymentSection(grandTotal, change, isUnderpaid)
                    : _buildNonCashPaymentSection(),
              ),

              const SizedBox(height: 12),

              // 3. Opsi Tambahan (Cetak Struk Checkbox)
              Row(
                children: [
                  Checkbox(
                    value: _autoPrintReceipt,
                    activeColor: SolluColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _autoPrintReceipt = val ?? true;
                      });
                    },
                  ),
                  const Text(
                    'Cetak struk secara otomatis setelah selesai',
                    style: TextStyle(
                      fontSize: 13,
                      color: SolluColors.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 4. Tombol Eksekusi CTA (Tinggi >= 56dp)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnderpaid
                      ? SolluColors.neutralDark
                      : SolluColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (_isProcessing || isUnderpaid)
                    ? null
                    : () => _handlePaymentSubmit(grandTotal),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Selesaikan Pembayaran (${CurrencyFormatter.format(grandTotal.toInt())})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildCashPaymentSection(
    double grandTotal,
    double change,
    bool isUnderpaid,
  ) {
    final quickCashOptions = _getQuickCashOptions(grandTotal);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sisi Kiri Bagian Tunai: Input Uang + Quick Cash + Status Kembalian
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Nominal Uang Diterima
                const Text(
                  'Uang Diterima',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SolluColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _cashReceivedController,
                  focusNode: _cashReceivedFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SolluColors.primary,
                  ),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: SolluColors.textDark,
                    ),
                    filled: true,
                    fillColor: SolluColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SolluColors.neutral,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SolluColors.neutral,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: SolluColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _cashReceived = CurrencyInputFormatter.parse(val);
                    });
                  },
                  onSubmitted: (_) {
                    if (!_isProcessing && !isUnderpaid && _selectedMethod != null) {
                      _handlePaymentSubmit(grandTotal);
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Quick Cash Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickCashOptions.map((amount) {
                    final isExact = amount == grandTotal;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _cashReceived = amount;
                          _cashReceivedController.text =
                              CurrencyInputFormatter.format(amount.toInt());
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: SolluColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isExact
                                ? SolluColors.primaryLight
                                : SolluColors.neutral,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          isExact
                              ? 'Uang Pas'
                              : CurrencyFormatter.format(amount.toInt()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isExact
                                ? SolluColors.primary
                                : SolluColors.textDark,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Status Box: Kembalian atau Kurang
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnderpaid
                        ? const Color(0xFFFEF2F2) // Red 50
                        : const Color(0xFFECFDF5), // Green 50
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUnderpaid
                          ? SolluColors.danger.withValues(alpha: 0.3)
                          : SolluColors.success.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUnderpaid ? 'Uang Kurang' : 'Kembalian',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isUnderpaid
                              ? SolluColors.danger
                              : SolluColors.success,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          (isUnderpaid ? (grandTotal - _cashReceived) : change)
                              .toInt(),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isUnderpaid
                              ? SolluColors.danger
                              : SolluColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Sisi Kanan Bagian Tunai: Ergonomic Virtual Numpad (Min Touch Target >= 48dp)
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SolluColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SolluColors.neutral, width: 1.0),
            ),
            child: Column(
              children: [
                _buildNumpadRow(['1', '2', '3'], grandTotal),
                const SizedBox(height: 8),
                _buildNumpadRow(['4', '5', '6'], grandTotal),
                const SizedBox(height: 8),
                _buildNumpadRow(['7', '8', '9'], grandTotal),
                const SizedBox(height: 8),
                _buildNumpadRow(['C', '0', '00'], grandTotal),
                const SizedBox(height: 8),
                _buildNumpadRow(['DEL', 'PAS'], grandTotal, isActionRow: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpadRow(
    List<String> buttons,
    double grandTotal, {
    bool isActionRow = false,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) {
          final isDel = btn == 'DEL';
          final isClear = btn == 'C';
          final isPas = btn == 'PAS';

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: isPas
                    ? SolluColors.primary.withValues(alpha: 0.1)
                    : (isClear || isDel)
                        ? const Color(0xFFFEE2E2) // Red 100
                        : SolluColors.background,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => _onNumpadTapped(btn, grandTotal),
                  borderRadius: BorderRadius.circular(6),
                  child: Center(
                    child: isDel
                        ? const Icon(
                            Icons.backspace_outlined,
                            size: 20,
                            color: SolluColors.danger,
                          )
                        : Text(
                            isPas ? 'PAS' : btn,
                            style: TextStyle(
                              fontSize: isPas ? 13 : 18,
                              fontWeight: FontWeight.w700,
                              color: isPas
                                  ? SolluColors.primary
                                  : (isClear)
                                      ? SolluColors.danger
                                      : SolluColors.textDark,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showQrZoomDialog(String qrImageUrl, String methodName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                methodName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrImageUrl,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 280,
                    height: 280,
                    color: SolluColors.background,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: SolluColors.textMuted),
                          SizedBox(height: 8),
                          Text('Gagal memuat gambar QR', style: TextStyle(color: SolluColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Arahkan kamera smartphone pelanggan ke QR Code di atas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: SolluColors.textMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolluColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNonCashPaymentSection() {
    final method = _selectedMethod;
    final type = method?.type.toLowerCase() ?? 'custom';
    final policy = method?.referencePolicy ?? 'optional';
    final isMandatoryRef = policy == 'mandatory';
    final isHiddenRef = policy == 'hidden';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Specialized Payment Method Card
          if (type == 'qris') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolluColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SolluColors.neutral, width: 1.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, color: SolluColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        method?.name ?? 'QRIS',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: SolluColors.textDark,
                        ),
                      ),
                      if (method?.provider != null && method!.provider!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: SolluColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            method.provider!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SolluColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (method?.qrImageUrl != null && method!.qrImageUrl!.isNotEmpty) ...[
                    InkWell(
                      onTap: () => _showQrZoomDialog(method.qrImageUrl!, method.name),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SolluColors.neutral),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                method.qrImageUrl!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Center(
                                    child: Icon(Icons.broken_image, size: 40, color: SolluColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in, size: 14, color: SolluColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Ketuk untuk memperbesar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: SolluColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    method?.instructions?.isNotEmpty == true
                        ? method!.instructions!
                        : 'Arahkan pelanggan untuk memindai QRIS melalui aplikasi mobile banking atau e-wallet mereka.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                  ),
                ],
              ),
            ),
          ] else if (type == 'bank_transfer' || type == 'transfer') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolluColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SolluColors.neutral, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SolluColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: SolluColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method?.name ?? 'Transfer Bank',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: SolluColors.textDark,
                              ),
                            ),
                            if (method?.provider != null && method!.provider!.isNotEmpty)
                              Text(
                                'Bank: ${method.provider}',
                                style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (method?.accountNumber != null && method!.accountNumber!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: SolluColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SolluColors.neutral),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor Rekening',
                                  style: TextStyle(fontSize: 11, color: SolluColors.textMuted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  method.accountNumber!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: SolluColors.textDark,
                                  ),
                                ),
                                if (method.accountName != null && method.accountName!.isNotEmpty)
                                  Text(
                                    'a.n. ${method.accountName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: SolluColors.textMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: method.accountNumber!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nomor rekening berhasil disalin!'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text('Salin', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SolluColors.primary,
                              side: const BorderSide(color: SolluColors.primary),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (method?.instructions != null && method!.instructions!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      method.instructions!,
                      style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // EDC / EWALLET / CUSTOM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolluColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SolluColors.neutral, width: 1.0),
              ),
              child: Column(
                children: [
                  Icon(
                    _getIconForType(method?.type ?? ''),
                    size: 40,
                    color: SolluColors.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    method?.name ?? 'Non-Tunai',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SolluColors.textDark,
                    ),
                  ),
                  if (method?.provider != null && method!.provider!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Provider / Mesin: ${method.provider}',
                      style: const TextStyle(fontSize: 13, color: SolluColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    method?.instructions?.isNotEmpty == true
                        ? method!.instructions!
                        : 'Pastikan proses transaksi pada mesin EDC / E-Wallet telah berhasil dan disetujui.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                  ),
                ],
              ),
            ),
          ],

          // 2. Input Nomor Referensi (jika tidak hidden)
          if (!isHiddenRef) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Nomor Referensi / Trace No',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMandatoryRef ? SolluColors.danger : SolluColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isMandatoryRef ? '(Wajib Diisi)' : '(Opsional)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isMandatoryRef ? FontWeight.bold : FontWeight.normal,
                    color: isMandatoryRef ? SolluColors.danger : SolluColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _referenceController,
              focusNode: _referenceFocusNode,
              decoration: InputDecoration(
                hintText: isMandatoryRef
                    ? 'Masukkan approval code / trace no *'
                    : 'Contoh: 123456789 / REF-001',
                filled: true,
                fillColor: SolluColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isMandatoryRef ? SolluColors.danger.withValues(alpha: 0.5) : SolluColors.neutral,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isMandatoryRef ? SolluColors.danger.withValues(alpha: 0.5) : SolluColors.neutral,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isMandatoryRef ? SolluColors.danger : SolluColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Text(
            'Catatan Transaksi (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SolluColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            focusNode: _notesFocusNode,
            decoration: InputDecoration(
              hintText: 'Contoh: Meja 4 / Atas nama Pak Joko',
              filled: true,
              fillColor: SolluColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: SolluColors.neutral,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: SolluColors.neutral,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
