import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

/// Modal dialog checkout khusus mode Kasir Cepat (Fast Retail)
/// Memungkinkan eksekusi pembayaran instan 100% via keyboard tanpa perpindahan rute GoRouter
class FastRetailCheckoutDialog extends ConsumerWidget {
  final String? initialMethodType;

  const FastRetailCheckoutDialog({
    super.key,
    this.initialMethodType,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? initialMethodType,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FastRetailCheckoutDialog(
        initialMethodType: initialMethodType,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmployee = ref.watch(activeEmployeeProvider);
    final activeShift = ref.watch(activeShiftProvider).asData?.value;

    return Focus(
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop(false);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 680,
            maxHeight: 640,
          ),
          child: Scaffold(
            backgroundColor: SolluColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SolluColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.point_of_sale,
                      size: 20,
                      color: SolluColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Checkout Pembayaran (Kasir Cepat)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SolluColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (activeEmployee != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SolluColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: SolluColors.neutral,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        activeEmployee['name'] ?? 'Kasir',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: SolluColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (activeShift != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SolluColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Shift #${activeShift.shiftNumber}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: SolluColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: SolluColors.textMuted,
                    size: 20,
                  ),
                  tooltip: 'Batal (Esc)',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: SolluColors.neutral, height: 1.0),
              ),
            ),
            body: CheckoutPaymentPane(
              initialMethodType: initialMethodType,
              onCompleted: () => Navigator.of(context).pop(true),
            ),
          ),
        ),
      ),
    );
  }
}
