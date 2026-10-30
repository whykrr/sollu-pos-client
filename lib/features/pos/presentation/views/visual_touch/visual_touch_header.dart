import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/held_bills_drawer.dart';

/// Header Bersih untuk Mode Visual Touch (Layar Sentuh Murni Tanpa Hotkey Keyboard)
class VisualTouchHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onBackToDashboard;

  const VisualTouchHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onBackToDashboard,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  ConsumerState<VisualTouchHeader> createState() => _VisualTouchHeaderState();
}

class _VisualTouchHeaderState extends ConsumerState<VisualTouchHeader> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final activeShiftAsync = ref.watch(activeShiftProvider);
    final isOnline = ref.watch(connectivityProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dashboard Back Button
          Tooltip(
            message: 'Kembali ke Dashboard',
            child: InkWell(
              onTap: widget.onBackToDashboard,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: const Icon(Icons.arrow_back, color: SolluColors.textDark, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Logo
          Image.asset('img/logo-colored.png', height: 30),
          const SizedBox(width: 14),

          // Touch Search Bar
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: widget.searchController,
                focusNode: widget.searchFocusNode,
                style: const TextStyle(fontSize: 13),
                onChanged: (val) {
                  ref.read(posSearchQueryProvider.notifier).setQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama produk atau kategori...',
                  hintStyle: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 20, color: SolluColors.neutralMuted),
                  suffixIcon: widget.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: SolluColors.textMuted),
                          onPressed: () {
                            widget.searchController.clear();
                            ref.read(posSearchQueryProvider.notifier).setQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.neutral),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.neutral),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: SolluColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Hold bills counter
        Center(
          child: Consumer(
            builder: (context, ref, child) {
              final heldBillsAsync = ref.watch(heldTransactionsStreamProvider);
              final count = heldBillsAsync.asData?.value.length ?? 0;
              return InkWell(
                onTap: () => HeldBillsDrawer.showAsDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 38),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: count > 0 ? SolluColors.warning.withValues(alpha: 0.1) : SolluColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: count > 0 ? SolluColors.warning : SolluColors.neutral,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pause_circle_outline,
                        size: 16,
                        color: count > 0 ? SolluColors.warning : SolluColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hold ($count)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: count > 0 ? SolluColors.warning : SolluColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Online / Offline Status
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline ? SolluColors.success.withValues(alpha: 0.1) : SolluColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOnline ? SolluColors.success : SolluColors.danger,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 14,
                  color: isOnline ? SolluColors.success : SolluColors.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? SolluColors.success : SolluColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Shift indicator
        if (ref.watch(featureGatingProvider).canUseShiftCashier()) ...[
          const SizedBox(width: 8),
          Center(
            child: activeShiftAsync.when(
              data: (shift) {
                final isShiftOpen = shift != null;
                final shiftText = isShiftOpen ? 'Shift #${shift.shiftNumber}' : 'Buka Shift';

                return InkWell(
                  onTap: () {
                    if (isShiftOpen) {
                      CloseShiftDialog.show(context);
                    } else {
                      OpenShiftDialog.show(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isShiftOpen
                          ? SolluColors.primary.withValues(alpha: 0.08)
                          : SolluColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isShiftOpen ? SolluColors.primary.withValues(alpha: 0.3) : SolluColors.warning,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isShiftOpen ? Icons.storefront : Icons.warning_amber_rounded,
                          size: 14,
                          color: isShiftOpen ? SolluColors.primary : SolluColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shiftText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isShiftOpen ? SolluColors.primary : SolluColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],

        const SizedBox(width: 8),

        // Sync button
        Center(
          child: Consumer(
            builder: (context, ref, child) {
              final unsyncedCountAsync = ref.watch(unsyncedTransactionsCountProvider);
              final failedCountAsync = ref.watch(failedTransactionsCountProvider);
              final unsyncedCount = unsyncedCountAsync.value ?? 0;
              final failedCount = failedCountAsync.value ?? 0;

              return Tooltip(
                message: 'Sinkronkan Transaksi & Data',
                child: InkWell(
                  onTap: _isSyncing
                      ? null
                      : () async {
                          setState(() => _isSyncing = true);
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Menyinkronkan transaksi dan pembaruan data...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          try {
                            final syncCoordinator = ref.read(syncCoordinatorServiceProvider);
                            final result = await syncCoordinator.synchronizeAll();

                            ref.invalidate(employeeListProvider);
                            ref.invalidate(posItemsProvider);
                            ref.invalidate(posCategoriesProvider);
                            ref.invalidate(currentShiftTransactionsProvider);
                            ref.invalidate(allTransactionsProvider);
                            ref.invalidate(heldTransactionsStreamProvider);
                            ref.read(lastSyncProvider.notifier).updateTimestamp();

                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(result.userFriendlyMessage),
                                  backgroundColor: result.hasFailures ? SolluColors.warning : Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Tidak dapat terhubung ke server. Data transaksi tetap aman.'),
                                  backgroundColor: SolluColors.danger,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSyncing = false);
                          }
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: SolluColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.sync, size: 18, color: Colors.white),
                              if (failedCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: SolluColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      '$failedCount',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (unsyncedCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: SolluColors.warning,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      '$unsyncedCount',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

