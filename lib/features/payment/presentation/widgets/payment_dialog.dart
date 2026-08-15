import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/core/utils/currency_input_formatter.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final int totalAmount;

  const PaymentDialog({super.key, required this.totalAmount});

  static Future<void> show(BuildContext context, int totalAmount) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(totalAmount: totalAmount),
    );
  }

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  PaymentMethod? _selectedMethod;
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  double _cashReceived = 0.0;
  bool _isProcessing = false;
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cashReceived = widget.totalAmount.toDouble();
    _cashReceivedController.text = CurrencyInputFormatter.format(widget.totalAmount);
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _referenceController.dispose();
    _keyboardFocusNode.dispose();
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

    // Calculate nice round cash options above total
    final denominations = [10000.0, 20000.0, 50000.0, 100000.0];
    for (final denom in denominations) {
      if (total < denom) {
        options.add(denom);
      }
    }

    // Add next 50k / 100k multiple
    final next50k = (total / 50000.0).ceil() * 50000.0;
    if (next50k > total) options.add(next50k);

    final next100k = (total / 100000.0).ceil() * 100000.0;
    if (next100k > total) options.add(next100k);

    final list = options.toList()..sort();
    return list.take(5).toList();
  }

  Future<void> _handlePaymentSubmit(PaymentMethod method) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final isCash = method.type == 'cash' || method.name.toLowerCase().contains('tunai');
    if (isCash && _cashReceived < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang dari total tagihan!'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final appliedDiscount = ref.read(appliedDiscountProvider);
      final activeShift = ref.read(activeShiftProvider).asData?.value;

      final double subtotal = cart.fold(0.0, (sum, item) => sum + (item.price * item.qty));
      final double discountAmount = appliedDiscount != null ? appliedDiscount.calculateDiscount(subtotal) : 0.0;
      final double taxableAmount = (subtotal - discountAmount).clamp(0.0, double.infinity);
      final double tax = taxableAmount * 0.1;
      final double changeAmount = isCash ? (_cashReceived - widget.totalAmount) : 0.0;

      final repository = ref.read(transactionRepositoryProvider);
      final tx = await repository.createTransaction(
        shiftId: activeShift?.id,
        items: cart,
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountType: appliedDiscount?.type,
        discountValue: appliedDiscount?.value,
        promoName: appliedDiscount?.name,
        promoId: appliedDiscount?.promoId,
        taxAmount: tax,
        total: widget.totalAmount.toDouble(),
        paymentMethod: method,
        cashReceived: isCash ? _cashReceived : widget.totalAmount.toDouble(),
        changeAmount: changeAmount,
        notes: _referenceController.text.trim().isNotEmpty ? _referenceController.text.trim() : null,
      );

      // Bersihkan keranjang dan promo
      ref.read(cartProvider.notifier).clearCart();
      ref.read(appliedDiscountProvider.notifier).clearDiscount();

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog bayar
        _showSuccessDialog(tx, method, changeAmount);

        // Buka laci kasir otomatis jika tipe pembayaran tunai (Cash)
        if (isCash) {
          openCashDrawerAction(ref: ref).then((result) {
            if (!result.success && mounted) {
              debugPrint('Gagal membuka laci: ${result.message}');
            }
          });
        }

        // Otomatis cetak struk karena user menekan "Bayar & Cetak Struk"
        printTransactionReceiptAction(ref: ref, transactionId: tx.id).then((result) {
          if (!result.success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mencetak struk otomatis: ${result.message}'),
                backgroundColor: SolluColors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
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

  void _showSuccessDialog(Transaction tx, PaymentMethod method, double changeAmount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: SolluColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
              const SizedBox(height: 8),
              Text('Nomor: ${tx.transactionNumber}', style: const TextStyle(fontWeight: FontWeight.w600, color: SolluColors.primary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Metode', style: TextStyle(color: SolluColors.textMuted)),
                        Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Dibayar', style: TextStyle(color: SolluColors.textMuted)),
                        Text(CurrencyFormatter.format(tx.total.toInt()), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (changeAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kembalian', style: TextStyle(color: SolluColors.success, fontWeight: FontWeight.bold)),
                          Text(CurrencyFormatter.format(changeAmount.toInt()), style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.success, fontSize: 16)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Mencetak struk ${tx.transactionNumber}...'),
                  backgroundColor: SolluColors.secondary,
                  duration: const Duration(seconds: 1),
                ),
              );

              final result = await printTransactionReceiptAction(
                ref: ref,
                transactionId: tx.id,
              );

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          result.success ? Icons.check_circle : Icons.error_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(result.message)),
                      ],
                    ),
                    backgroundColor: result.success ? SolluColors.success : SolluColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            icon: const Icon(Icons.print_outlined, size: 16),
            label: const Text('Cetak Ulang Struk'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsAsync = ref.watch(activePaymentMethodsProvider);

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final logicalKey = event.logicalKey;
          if (logicalKey == LogicalKeyboardKey.enter || logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (!_isProcessing && _selectedMethod != null) {
              _handlePaymentSubmit(_selectedMethod!);
            }
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.escape) {
            if (!_isProcessing) {
              Navigator.of(context).pop();
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 860,
        height: 640,
        padding: const EdgeInsets.all(28),
        child: paymentMethodsAsync.when(
          data: (methods) {
            // Default fallback if no methods exist in DB
            final activeMethods = methods.isNotEmpty
                ? methods
                : [
                    PaymentMethod(id: 'default-cash', name: 'Tunai', type: 'cash', isActive: true),
                    PaymentMethod(id: 'default-qris', name: 'QRIS', type: 'qris', isActive: true),
                  ];

            _selectedMethod ??= activeMethods.first;
            final currentMethod = _selectedMethod!;
            final isCash = currentMethod.type == 'cash' || currentMethod.name.toLowerCase().contains('tunai');
            final double change = isCash ? (_cashReceived - widget.totalAmount).clamp(0.0, double.infinity) : 0.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Payment Details & Methods
                Expanded(
                  flex: 3,
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
                            child: const Icon(Icons.point_of_sale, color: SolluColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('Pembayaran', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: activeMethods.map((m) {
                          final isSelected = currentMethod.id == m.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMethod = m;
                                if (m.type == 'cash' || m.name.toLowerCase().contains('tunai')) {
                                  _cashReceivedController.text = CurrencyInputFormatter.format(widget.totalAmount);
                                  _cashReceived = widget.totalAmount.toDouble();
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 120,
                              height: 90,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? SolluColors.primary : SolluColors.neutral,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected ? SolluColors.primary.withValues(alpha: 0.08) : Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_getIconForType(m.type), size: 28, color: isSelected ? SolluColors.primary : SolluColors.neutralDark),
                                  const SizedBox(height: 6),
                                  Text(
                                    m.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? SolluColors.primary : SolluColors.textDark,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      if (isCash) ...[
                        const Text('Uang Diterima (Tunai)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cashReceivedController,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SolluColors.primary),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          onChanged: (val) {
                            setState(() {
                              _cashReceived = CurrencyInputFormatter.parse(val);
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // Quick Cash Buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _getQuickCashOptions(widget.totalAmount.toDouble()).map((amt) {
                            final isExact = amt == widget.totalAmount.toDouble();
                            final label = isExact ? 'Uang Pas' : CurrencyFormatter.format(amt.toInt());
                            return OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _cashReceived = amt;
                                  _cashReceivedController.text = CurrencyInputFormatter.format(amt.toInt());
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SolluColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: SolluColors.neutral),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(_getIconForType(currentMethod.type), color: SolluColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Pembayaran ${currentMethod.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Pastikan pelanggan telah menyelesaikan pembayaran sesuai nominal tagihan sebelum memproses.', style: TextStyle(fontSize: 12, color: SolluColors.textMuted)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _referenceController,
                                decoration: InputDecoration(
                                  hintText: 'Nomor Referensi / No Transaksi (Opsional)',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const VerticalDivider(width: 48, thickness: 1, color: SolluColors.neutral),
                // Right Column: Summary & Submit
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: SolluColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: SolluColors.neutral),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Total Tagihan', style: TextStyle(color: SolluColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              CurrencyFormatter.format(widget.totalAmount),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: SolluColors.primary,
                              ),
                            ),
                            const Divider(height: 28, color: SolluColors.neutral),
                            if (isCash) ...[
                              const Text('Kembalian', style: TextStyle(color: SolluColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(
                                CurrencyFormatter.format(change.toInt()),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: change > 0 ? SolluColors.success : SolluColors.textDark,
                                ),
                              ),
                            ] else ...[
                              const Text('Status Pembayaran', style: TextStyle(color: SolluColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: SolluColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Siap Diverifikasi (${currentMethod.name})',
                                  style: const TextStyle(color: SolluColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _handlePaymentSubmit(currentMethod),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Bayar & Cetak Struk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                        child: const Text('Batal (Esc)', style: TextStyle(color: SolluColors.textMuted)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Gagal memuat metode pembayaran: $err')),
        ),
      ),
      ),
    );
  }
}
