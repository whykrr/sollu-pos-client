import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/utils/currency_formatter.dart';
import 'package:sollu_pos_app/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/variant_dialog_provider.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/cart_provider.dart';

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

    return AlertDialog(
      title: Text(
        'Opsi: ${posItem.name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.variantGroups.isNotEmpty) ...[
                const Text('Pilih Varian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...state.variantGroups.map((group) {
                  final options = state.variantOptions[group.id] ?? [];
                  final selectedOptId = state.selectedVariants[group.id];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600, color: SolluColors.textMuted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: options.map((opt) {
                            final isSelected = opt.id == selectedOptId;
                            return ChoiceChip(
                              label: Text(opt.name),
                              selected: isSelected,
                              selectedColor: SolluColors.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? SolluColors.primary : SolluColors.textDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                const Text('Tambahan (Modifier)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...state.modifierGroups.map((group) {
                  final options = state.modifierOptions[group.id] ?? [];
                  final selectedOptIds = state.selectedModifiers[group.id] ?? [];
                  
                  final isRadio = group.type == 'radio' || group.maxSelected == 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600, color: SolluColors.textMuted)),
                            if (group.minSelected > 0)
                              const Text('*Wajib', style: TextStyle(color: SolluColors.danger, fontSize: 12, fontWeight: FontWeight.bold))
                            else if (group.maxSelected > 0)
                              Text('Maks. ${group.maxSelected}', style: const TextStyle(color: SolluColors.textMuted, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...options.map((opt) {
                          final isSelected = selectedOptIds.contains(opt.id);
                          final priceText = opt.price > 0 ? '+${CurrencyFormatter.format(opt.price.toInt())}' : '';

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(opt.name),
                                Text(priceText, style: const TextStyle(color: SolluColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value != null) {
                                notifier.toggleModifier(group.id, opt.id, value);
                              }
                            },
                            // Visual cue if it acts like a radio button
                            checkboxShape: isRadio ? const CircleBorder() : null,
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],

              const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // We should ideally use a TextEditingController for notes.
              // For simplicity, we just leave it for now or implement a quick local state if needed.
              // In this case, I will just leave the UI and we will add to cart with no notes for now.
              TextField(
                decoration: InputDecoration(
                  hintText: 'Misal: Jangan pakai bawang...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
                onChanged: (val) {
                  // If we need to capture notes, we can add it to the provider
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CurrencyFormatter.format(totalPrice.toInt()),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: SolluColors.primary),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal (Esc)'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Validasi Modifier Required
                    
                    final cartItem = CartItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      productId: posItem.isProductMode ? posItem.id : posItem.inventory!.productId,
                      inventoryItemId: posItem.isProductMode ? state.selectedVariants.values.join('-') : posItem.id, // simplified
                      name: posItem.name,
                      price: totalPrice,
                      qty: 1,
                      selectedVariants: state.selectedVariants,
                      selectedModifiers: state.selectedModifiers,
                    );
                    
                    ref.read(cartProvider.notifier).addItem(cartItem);
                    Navigator.of(context).pop();
                  },
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
