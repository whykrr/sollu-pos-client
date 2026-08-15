import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/payment/presentation/widgets/payment_dialog.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

import 'package:flutter/services.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';

import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

class CartPanel extends ConsumerStatefulWidget {
  final FocusNode? focusNode;

  const CartPanel({super.key, this.focusNode});

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  int _selectedCartIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    
    // Each cart item is roughly 80px height including separator
    const double estimatedItemHeight = 75.0; 
    final targetTop = (index * estimatedItemHeight) - 30; // Buffer for top padding
    final targetBottom = targetTop + estimatedItemHeight + 60; // Buffer for bottom
    
    final currentOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    if (targetTop < currentOffset) {
       _scrollController.animateTo((targetTop < 0 ? 0 : targetTop), duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    } else if (targetBottom > currentOffset + viewportHeight) {
       _scrollController.animateTo(targetBottom - viewportHeight, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  void _openEditItemDialog(CartItem item) {
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

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final appliedDiscount = ref.watch(appliedDiscountProvider);
    final taxRate = ref.watch(activeTaxRateProvider);
    final serviceChargeRate = ref.watch(activeServiceChargeRateProvider);

    final double subtotal = cart.fold(0, (sum, item) => sum + item.calculatedSubtotal);
    final double discountAmount = appliedDiscount != null ? appliedDiscount.calculateDiscount(subtotal) : 0.0;
    final double taxableAmount = (subtotal - discountAmount).clamp(0.0, double.infinity);
    final double tax = taxableAmount * (taxRate / 100.0);
    final double serviceCharge = taxableAmount * (serviceChargeRate / 100.0);
    final double total = taxableAmount + tax + serviceCharge;

    final isCartFocused = widget.focusNode?.hasFocus ?? false;
    if (_selectedCartIndex >= cart.length && cart.isNotEmpty) {
      _selectedCartIndex = cart.length - 1;
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: SolluColors.textDark),
                Text(
                  'Keranjang (${cart.fold(0, (sum, item) => sum + item.qty)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'F3',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SolluColors.primary),
                  ),
                ),
              ],
            ),
          ),
          
          // Sub-header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Item', style: TextStyle(color: SolluColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                    if (cart.isNotEmpty)
                      InkWell(
                        onTap: () => ref.read(cartProvider.notifier).clearCart(),
                        child: const Text('Kosongkan', style: TextStyle(color: SolluColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: SolluColors.neutral),
              ],
            ),
          ),

          // Cart Items with Keyboard Listener
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 48, color: SolluColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'Keranjang masih kosong',
                          style: TextStyle(color: SolluColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tekan F2 untuk pilih produk',
                          style: TextStyle(color: SolluColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : Focus(
                    focusNode: widget.focusNode,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent || event is KeyRepeatEvent) {
                        final key = event.logicalKey;
                        if (key == LogicalKeyboardKey.arrowDown) {
                          setState(() {
                            _selectedCartIndex = (_selectedCartIndex + 1).clamp(0, cart.length - 1);
                          });
                          _scrollToIndex(_selectedCartIndex);
                          return KeyEventResult.handled;
                        } else if (key == LogicalKeyboardKey.arrowUp) {
                          setState(() {
                            _selectedCartIndex = (_selectedCartIndex - 1).clamp(0, cart.length - 1);
                          });
                          _scrollToIndex(_selectedCartIndex);
                          return KeyEventResult.handled;
                        } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
                          if (_selectedCartIndex >= 0 && _selectedCartIndex < cart.length) {
                            _openEditItemDialog(cart[_selectedCartIndex]);
                            return KeyEventResult.handled;
                          }
                        } else if (key == LogicalKeyboardKey.equal || key == LogicalKeyboardKey.add) {
                          if (_selectedCartIndex >= 0 && _selectedCartIndex < cart.length) {
                            ref.read(cartProvider.notifier).updateQty(cart[_selectedCartIndex].id, 1);
                            return KeyEventResult.handled;
                          }
                        } else if (key == LogicalKeyboardKey.minus) {
                          if (_selectedCartIndex >= 0 && _selectedCartIndex < cart.length) {
                            final item = cart[_selectedCartIndex];
                            if (item.qty > 1) {
                              ref.read(cartProvider.notifier).updateQty(item.id, -1);
                            } else {
                              ref.read(cartProvider.notifier).removeItem(item.id);
                            }
                            return KeyEventResult.handled;
                          }
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: cart.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        final isSelected = isCartFocused && (_selectedCartIndex == index);

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected ? SolluColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? SolluColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCartIndex = index;
                              });
                              _openEditItemDialog(item);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark, fontSize: 13),
                                      ),
                                      const SizedBox(height: 3),
                                      if (item.calculatedDiscountAmount > 0) ...[
                                        Row(
                                          children: [
                                            Text(
                                              CurrencyFormatter.format(item.price.toInt()),
                                              style: TextStyle(
                                                color: SolluColors.textMuted.withValues(alpha: 0.6),
                                                fontSize: 12,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: SolluColors.danger.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.discountType == 'percentage'
                                                    ? 'Disc ${item.discountValue?.toInt()}%'
                                                    : 'Disc ${CurrencyFormatter.format(item.calculatedDiscountAmount.toInt())}',
                                                style: const TextStyle(color: SolluColors.danger, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                      ] else ...[
                                        Text(
                                          CurrencyFormatter.format(item.price.toInt()),
                                          style: const TextStyle(color: SolluColors.textMuted, fontSize: 12),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        'Subtotal: ${CurrencyFormatter.format(item.calculatedSubtotal.toInt())}',
                                        style: const TextStyle(color: SolluColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(Icons.edit_note, size: 14, color: SolluColors.textMuted.withValues(alpha: 0.6)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item.notes!,
                                                style: TextStyle(color: SolluColors.textMuted.withValues(alpha: 0.6), fontSize: 11),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Square Qty Controls
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildQtyButton(Icons.remove, () {
                                      if (item.qty > 1) {
                                        ref.read(cartProvider.notifier).updateQty(item.id, -1);
                                      } else {
                                        ref.read(cartProvider.notifier).removeItem(item.id);
                                      }
                                    }),
                                    InkWell(
                                      onTap: () => _openEditItemDialog(item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: SolluColors.background,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: SolluColors.neutral),
                                        ),
                                        child: Text(
                                          '${item.qty}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark),
                                        ),
                                      ),
                                    ),
                                    _buildQtyButton(Icons.add, () {
                                      ref.read(cartProvider.notifier).updateQty(item.id, 1);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Order Summary & Checkout
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, -5),
                  blurRadius: 15,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(subtotal.toInt())),
                const SizedBox(height: 8),
                if (appliedDiscount != null && discountAmount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Diskon (${appliedDiscount.name})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SolluColors.success),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => ref.read(appliedDiscountProvider.notifier).clearDiscount(),
                            child: const Icon(Icons.cancel, size: 14, color: SolluColors.danger),
                          ),
                        ],
                      ),
                      Text(
                        '- ${CurrencyFormatter.format(discountAmount.toInt())}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SolluColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (serviceCharge > 0) ...[
                  _SummaryRow(
                    label: 'Service (${serviceChargeRate % 1 == 0 ? serviceChargeRate.toInt() : serviceChargeRate}%)',
                    value: CurrencyFormatter.format(serviceCharge.toInt()),
                  ),
                  const SizedBox(height: 8),
                ],
                if (tax > 0) ...[
                  _SummaryRow(
                    label: 'Pajak (${taxRate % 1 == 0 ? taxRate.toInt() : taxRate}%)',
                    value: CurrencyFormatter.format(tax.toInt()),
                  ),
                  const SizedBox(height: 8),
                ],
                const Divider(color: SolluColors.neutral),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark)),
                    Text(CurrencyFormatter.format(total.toInt()), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: SolluColors.textDark)),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons Row
                Row(
                  children: [
                    _buildActionButton(Icons.pause_circle_outline, 'Hold', onTap: () {
                      if (cart.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong')));
                        return;
                      }
                      ref.read(holdCartProvider.notifier).holdCurrentCart(cart);
                      ref.read(cartProvider.notifier).clearCart();
                      ref.read(appliedDiscountProvider.notifier).clearDiscount();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil di-hold')));
                    }),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.percent_outlined,
                      appliedDiscount != null ? 'Promo Aktif' : 'Diskon',
                      isActive: appliedDiscount != null,
                      onTap: () => DiscountDialog.show(context),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.receipt_long_outlined, 'Split Bill', isDisabled: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (cart.isEmpty) {
                            EmptyCartDialog.show(context);
                            return;
                          }
                          PaymentDialog.show(context, total.toInt());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('BAYAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: SolluColors.textMuted),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap, bool isActive = false, bool isDisabled = false}) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isDisabled 
            ? SolluColors.neutral.withValues(alpha: 0.3)
            : isActive ? SolluColors.primary.withValues(alpha: 0.12) : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: SolluColors.primary, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 24, 
              color: isDisabled 
                ? SolluColors.textMuted.withValues(alpha: 0.4) 
                : isActive ? SolluColors.primary : SolluColors.textDark.withValues(alpha: 0.8)
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isDisabled 
                  ? SolluColors.textMuted.withValues(alpha: 0.4) 
                  : isActive ? SolluColors.primary : SolluColors.textDark.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: SolluColors.textDark,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SolluColors.textDark,
          ),
        ),
      ],
    );
  }
}
