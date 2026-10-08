import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/sollu_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/checkout_cart_pane.dart';
import '../widgets/checkout_payment_pane.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shift/presentation/providers/shift_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String? initialMethodType;

  const CheckoutScreen({
    super.key,
    this.initialMethodType,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus after frame to capture hardware shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (mounted) context.pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final activeEmployee = ref.watch(activeEmployeeProvider);
    final activeShift = ref.watch(activeShiftProvider).asData?.value;

    return Focus(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: SolluColors.background,
        appBar: AppBar(
          backgroundColor: SolluColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: SolluColors.textDark),
            tooltip: 'Kembali ke Kasir (ESC)',
            onPressed: () => context.pop(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: SolluColors.neutral,
                      width: 1.0,
                    ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: SolluColors.neutral,
              height: 1.0,
            ),
          ),
        ),
        body: cart.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: SolluColors.neutralDark,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Keranjang Belanja Kosong',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SolluColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SolluColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: const Text('Kembali ke Katalog'),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
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
                            initialMethodType: widget.initialMethodType,
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
                          initialMethodType: widget.initialMethodType,
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
