import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/held_bills_drawer.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';

/// Panel Kiri Kasir Cepat: Wide Data Table dengan keyboard navigation & kontras tinggi
class FastRetailTablePane extends ConsumerStatefulWidget {
  final FocusNode? focusNode;
  final FocusNode? omniFocusNode;
  final VoidCallback? onFocusOmni;
  final VoidCallback? onOpenDiscount;
  final VoidCallback? onHoldBill;
  final VoidCallback? onRecallBills;
  final ValueChanged<CartItem>? onEditItem;
  final Future<bool> Function(String permission, String title)? ensureAuthorized;

  const FastRetailTablePane({
    super.key,
    this.focusNode,
    this.omniFocusNode,
    this.onFocusOmni,
    this.onOpenDiscount,
    this.onHoldBill,
    this.onRecallBills,
    this.onEditItem,
    this.ensureAuthorized,
  });

  @override
  ConsumerState<FastRetailTablePane> createState() => _FastRetailTablePaneState();
}

class _FastRetailTablePaneState extends ConsumerState<FastRetailTablePane> {
  final ScrollController _scrollController = ScrollController();
  static const double _rowHeight = 52.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureRowVisible(int index) {
    if (!_scrollController.hasClients) return;
    final targetOffset = index * _rowHeight;
    final currentOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    if (targetOffset < currentOffset) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    } else if (targetOffset + _rowHeight > currentOffset + viewportHeight) {
      _scrollController.animateTo(
        targetOffset + _rowHeight - viewportHeight + 10,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  void _openEditDialog(CartItem item) {
    if (widget.onEditItem != null) {
      widget.onEditItem!(item);
      return;
    }
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
        widget.onFocusOmni?.call();
        widget.omniFocusNode?.requestFocus();
      },
    );
  }

  Future<void> _handleDeleteItem(CartItem item) async {
    if (widget.ensureAuthorized != null) {
      final authorized = await widget.ensureAuthorized!(
        'transaction.void',
        'Void Item "${item.name}"',
      );
      if (!authorized) return;
    }
    ref.read(cartProvider.notifier).removeItem(item.id);
    widget.onFocusOmni?.call();
    widget.omniFocusNode?.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return KeyEventResult.ignored;

    final currentIndex = ref.read(selectedCartIndexProvider).clamp(0, cart.length - 1);
    final currentItem = cart[currentIndex];

    // Arrow Down
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final next = (currentIndex + 1).clamp(0, cart.length - 1);
      ref.read(selectedCartIndexProvider.notifier).state = next;
      _ensureRowVisible(next);
      return KeyEventResult.handled;
    }

    // Arrow Up
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final prev = (currentIndex - 1).clamp(0, cart.length - 1);
      ref.read(selectedCartIndexProvider.notifier).state = prev;
      _ensureRowVisible(prev);
      return KeyEventResult.handled;
    }

    // '+' Key: Increment Qty
    if (event.logicalKey == LogicalKeyboardKey.add ||
        event.logicalKey == LogicalKeyboardKey.numpadAdd ||
        (event.logicalKey == LogicalKeyboardKey.equal &&
            !HardwareKeyboard.instance.isShiftPressed)) {
      ref.read(cartProvider.notifier).updateQty(currentItem.id, 1);
      return KeyEventResult.handled;
    }

    // '-' Key: Decrement Qty
    if (event.logicalKey == LogicalKeyboardKey.minus ||
        event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
      ref.read(cartProvider.notifier).updateQty(currentItem.id, -1);
      return KeyEventResult.handled;
    }

    // Delete / Backspace: Void Item
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      _handleDeleteItem(currentItem);
      return KeyEventResult.handled;
    }

    // Enter: Edit item detail
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _openEditDialog(currentItem);
      return KeyEventResult.handled;
    }

    // Esc: Return focus to omni-bar
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onFocusOmni?.call();
      widget.omniFocusNode?.requestFocus();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final selectedIndex = ref.watch(selectedCartIndexProvider);

    ref.listen<int>(selectedCartIndexProvider, (prev, next) {
      if (next >= 0 && next < cart.length) {
        _ensureRowVisible(next);
      }
    });

    if (cart.isEmpty) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SolluColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 40,
                color: SolluColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keranjang Belanja Masih Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan barcode scanner hardware atau ketik nama/SKU di kolom omni-bar atas.\n'
              'Format multiplier: ketik 3* lalu scan barcode untuk 3 pcs seketika.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: SolluColors.textMuted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.discount_outlined, size: 16, color: SolluColors.primary),
                  label: const Text('Diskon Nota', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    if (widget.onOpenDiscount != null) {
                      widget.onOpenDiscount!();
                    } else {
                      DiscountDialog.show(context);
                    }
                    widget.onFocusOmni?.call();
                  },
                  backgroundColor: SolluColors.background,
                  side: const BorderSide(color: SolluColors.neutral),
                ),
                ActionChip(
                  avatar: const Icon(Icons.pause_circle_outline, size: 16, color: SolluColors.primary),
                  label: const Text('Tahan Tagihan', style: TextStyle(fontSize: 12)),
                  onPressed: widget.onHoldBill,
                  backgroundColor: SolluColors.background,
                  side: const BorderSide(color: SolluColors.neutral),
                ),
                ActionChip(
                  avatar: const Icon(Icons.receipt_long_outlined, size: 16, color: SolluColors.primary),
                  label: const Text('Tagihan Tertahan', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    if (widget.onRecallBills != null) {
                      widget.onRecallBills!();
                    } else {
                      HeldBillsDrawer.showAsDialog(context);
                    }
                  },
                  backgroundColor: SolluColors.background,
                  side: const BorderSide(color: SolluColors.neutral),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Table Header
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: SolluColors.neutral, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('No', width: 44, alignment: Alignment.center),
                  _buildHeaderCell('Barcode / SKU', width: 130),
                  _buildHeaderCell('Nama Produk', flex: 4),
                  _buildHeaderCell('Varian / Modifier', flex: 3),
                  _buildHeaderCell('Qty', width: 120, alignment: Alignment.center),
                  _buildHeaderCell('Harga', width: 110, alignment: Alignment.centerRight),
                  _buildHeaderCell('Diskon', width: 100, alignment: Alignment.centerRight),
                  _buildHeaderCell('Subtotal', width: 120, alignment: Alignment.centerRight),
                  _buildHeaderCell('', width: 48, alignment: Alignment.center),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: cart.length,
                itemExtent: _rowHeight,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  final isSelected = index == selectedIndex;

                  return Container(
                    height: _rowHeight,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SolluColors.primary.withValues(alpha: 0.08)
                          : (index.isEven ? Colors.white : const Color(0xFFFAFAFA)),
                      border: Border(
                        bottom: const BorderSide(color: SolluColors.neutral, width: 0.5),
                        left: isSelected
                            ? const BorderSide(color: SolluColors.primary, width: 4.0)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Selectable & Double-tap editable region (Columns 1-8)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              ref.read(selectedCartIndexProvider.notifier).select(index);
                              widget.focusNode?.requestFocus();
                            },
                            onDoubleTap: () => _openEditDialog(item),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Row(
                                children: [
                                  // 1. No
                                  SizedBox(
                                    width: 44,
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? SolluColors.primary : SolluColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 2. Barcode / SKU
                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      item.barcode ?? item.sku ?? item.productItemId ?? (item.inventoryItemId.isNotEmpty ? item.inventoryItemId : '-'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: SolluColors.textDark,
                                      ),
                                    ),
                                  ),

                                  // 3. Nama Produk
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: SolluColors.textDark,
                                          ),
                                        ),
                                        if (item.notes != null && item.notes!.isNotEmpty)
                                          Text(
                                            item.notes!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              color: SolluColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // 4. Varian / Modifier
                                  Expanded(
                                    flex: 3,
                                    child: _buildVariantModifierBadges(item),
                                  ),

                                  // 5. Qty Controls (- / Qty / +)
                                  SizedBox(
                                    width: 120,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          onTap: () {
                                            ref.read(cartProvider.notifier).updateQty(item.id, -1);
                                            widget.focusNode?.requestFocus();
                                          },
                                        ),
                                        InkWell(
                                          onTap: () => _openEditDialog(item),
                                          child: Container(
                                            constraints: const BoxConstraints(minWidth: 32),
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${item.qty}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: SolluColors.textDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          onTap: () {
                                            ref.read(cartProvider.notifier).updateQty(item.id, 1);
                                            widget.focusNode?.requestFocus();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 6. Unit Price
                                  Container(
                                    width: 110,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      CurrencyFormatter.format(item.price.toInt()),
                                      style: const TextStyle(fontSize: 12, color: SolluColors.textDark),
                                    ),
                                  ),

                                  // 7. Discount
                                  Container(
                                    width: 100,
                                    alignment: Alignment.centerRight,
                                    child: item.calculatedDiscountAmount > 0
                                        ? Text(
                                            '- ${CurrencyFormatter.format(item.calculatedDiscountAmount.toInt())}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: SolluColors.danger,
                                            ),
                                          )
                                        : const Text('-', style: TextStyle(color: SolluColors.neutralDark)),
                                  ),

                                  // 8. Subtotal
                                  Container(
                                    width: 120,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      CurrencyFormatter.format(item.calculatedSubtotal.toInt()),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? SolluColors.primary : SolluColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 9. Delete Action
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 48,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: SolluColors.danger),
                              tooltip: 'Hapus / Void Item',
                              onPressed: () => _handleDeleteItem(item),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex, Alignment alignment = Alignment.centerLeft}) {
    final text = Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: SolluColors.textMuted,
        letterSpacing: 0.3,
      ),
    );

    if (flex != null) {
      return Expanded(
        flex: flex,
        child: Container(alignment: alignment, child: text),
      );
    }
    return SizedBox(
      width: width,
      child: Container(alignment: alignment, child: text),
    );
  }

  Widget _buildVariantModifierBadges(CartItem item) {
    final parts = <String>[];
    if (item.variantCombination != null && item.variantCombination!.isNotEmpty) {
      parts.add(item.variantCombination!);
    }
    for (final modEntry in item.selectedModifiers.entries) {
      if (modEntry.value.isNotEmpty) {
        parts.addAll(modEntry.value);
      }
    }

    if (parts.isEmpty) {
      return const Text('-', style: TextStyle(color: SolluColors.neutralDark, fontSize: 12));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: parts.map((part) {
          return Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: SolluColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: SolluColors.neutral, width: 0.5),
            ),
            child: Text(
              part,
              style: const TextStyle(fontSize: 11, color: SolluColors.textMuted),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SolluColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SolluColors.neutral),
        ),
        child: Icon(icon, size: 14, color: SolluColors.textDark),
      ),
    );
  }
}
