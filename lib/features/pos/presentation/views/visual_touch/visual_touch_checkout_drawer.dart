import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_cart_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

/// Fullscreen slide-over drawer checkout khusus mode Visual Touch (Layar Sentuh / Tablet)
/// Menampilkan animasi geser mulus dari kanan ke kiri tanpa perpindahan rute GoRouter
class VisualTouchCheckoutDrawer extends ConsumerWidget {
  final String? initialMethodType;

  const VisualTouchCheckoutDrawer({
    super.key,
    this.initialMethodType,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? initialMethodType,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup Checkout',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return VisualTouchCheckoutDrawer(
          initialMethodType: initialMethodType,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedAnimation = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
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
      child: Scaffold(
        backgroundColor: SolluColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: SolluColors.textDark),
            tooltip: 'Kembali ke Katalog (Esc)',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          title: Row(
            children: [
              const Text(
                'Checkout Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(width: 16),
              if (activeEmployee != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SolluColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SolluColors.neutral, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: SolluColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activeEmployee['name'] ?? 'Kasir',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SolluColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              if (activeShift != null) ...[
                const SizedBox(width: 8),
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
                      fontSize: 12,
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
              icon: const Icon(Icons.close, color: SolluColors.textMuted),
              tooltip: 'Tutup',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: SolluColors.neutral, height: 1.0),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Tablet / Desktop Split View (>= 768dp)
            if (constraints.maxWidth >= 768) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Pane: Ringkasan Keranjang (~42%)
                  const Expanded(
                    flex: 42,
                    child: CheckoutCartPane(),
                  ),
                  // Right Pane: Pembayaran & Numpad (~58%)
                  Expanded(
                    flex: 58,
                    child: CheckoutPaymentPane(
                      initialMethodType: initialMethodType,
                      onCompleted: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              );
            }

            // Small Screen / Mobile Layout (Stacked)
            return Column(
              children: [
                const Expanded(
                  flex: 4,
                  child: CheckoutCartPane(),
                ),
                Expanded(
                  flex: 6,
                  child: CheckoutPaymentPane(
                    initialMethodType: initialMethodType,
                    onCompleted: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
