import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/variant_dialog_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

class VariantDialog extends ConsumerWidget {
  final PosItem posItem;

  const VariantDialog({super.key, required this.posItem});

  static Future<void> show(BuildContext context, PosItem posItem) {
    return showDialog(
      context: context,
      builder: (context) => VariantDialog(posItem: posItem),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantDialogProvider(posItem));
    final notifier = ref.read(variantDialogProvider(posItem).notifier);

    if (state.isLoading) {
      return const AlertDialog(
        content: SizedBox(
          width: 400,
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalPrice = notifier.calculateTotalPrice();
    final resolvedItem = state.resolvedPosItem;

    final String stockText;
    if (posItem.isService || resolvedItem?.isService == true) {
      stockText = 'Layanan';
    } else if (!state.trackInventory) {
      stockText = 'Stok: ∞';
    } else {
      final unit = resolvedItem?.unit ?? posItem.unit;
      final stockVal = state.stock;
      final formatted = stockVal == stockVal.roundToDouble()
          ? stockVal.toInt().toString()
          : stockVal.toStringAsFixed(1);
      stockText = 'Stok: $formatted $unit';
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Pesan: ${posItem.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
            ),
            child: Text(
              stockText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SolluColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: SolluColors.danger.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: SolluColors.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: SolluColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (state.variantGroups.isNotEmpty) ...[
                const Text(
                  'Pilih Varian',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...state.variantGroups.map((group) {
                  final options = state.variantOptions[group.id] ?? [];
                  final selectedOptId = state.selectedVariants[group.id];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SolluColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: options.map((opt) {
                            final isSelected = opt.id == selectedOptId;
                            return ChoiceChip(
                              label: Text(opt.name),
                              selected: isSelected,
                              selectedColor: SolluColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? SolluColors.primary
                                    : SolluColors.textDark,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (bool selected) {
                                if (selected) {
                                  notifier.selectVariant(group.id, opt.id);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],

              if (state.modifierGroups.isNotEmpty) ...[
                const Text(
                  'Tambahan (Modifier)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...state.modifierGroups.map((group) {
                  final options = state.modifierOptions[group.id] ?? [];
                  final selectedOptIds =
                      state.selectedModifiers[group.id] ?? [];

                  final isRadio =
                      group.type == 'radio' || group.maxSelected == 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: SolluColors.textMuted,
                              ),
                            ),
                            if (group.minSelected > 0)
                              const Text(
                                '*Wajib',
                                style: TextStyle(
                                  color: SolluColors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else if (group.maxSelected > 0)
                              Text(
                                'Maks. ${group.maxSelected}',
                                style: const TextStyle(
                                  color: SolluColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...options.map((opt) {
                          final isSelected = selectedOptIds.contains(opt.id);
                          final priceText = opt.price > 0
                              ? '+${CurrencyFormatter.format(opt.price.toInt())}'
                              : '';

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(opt.name),
                                Text(
                                  priceText,
                                  style: const TextStyle(
                                    color: SolluColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value != null) {
                                notifier.toggleModifier(
                                  group.id,
                                  opt.id,
                                  value,
                                );
                              }
                            },
                            // Visual cue if it acts like a radio button
                            checkboxShape: isRadio
                                ? const CircleBorder()
                                : null,
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 12, color: SolluColors.textMuted),
                ),
                Text(
                  CurrencyFormatter.format(totalPrice.toInt() * state.qty),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: SolluColors.primary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal (Esc)'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.canAddToCart
                      ? () {
                          final selectedVariantOptionId =
                              state.selectedVariants.values.firstOrNull;

                          final cleanModifiers = Map.fromEntries(
                            state.selectedModifiers.entries
                                .where((e) => e.value.isNotEmpty),
                          );

                          final cartItem = CartItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            productId: posItem.isProductMode
                                ? posItem.id
                                : (posItem.product?.id ??
                                    posItem.inventory?.productId ??
                                    posItem.id),
                            productItemId: state.resolvedProductItemId,
                            inventoryItemId: resolvedItem?.inventory?.id ??
                                (posItem.isProductMode ? '' : posItem.id),
                            variantGroupOptionId: selectedVariantOptionId,
                            name: resolvedItem?.name ?? posItem.name,
                            variantCombination: state.variantCombination,
                            trackInventory: state.trackInventory,
                            price: totalPrice,
                            qty: state.qty,
                            discountType: state.discountType,
                            discountValue: state.discountValue,
                            selectedVariants: state.selectedVariants,
                            selectedModifiers: cleanModifiers,
                          );

                          ref.read(cartProvider.notifier).addItem(cartItem);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
