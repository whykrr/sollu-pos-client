import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'fast_retail_search_dropdown.dart';

/// Header Kasir Cepat dengan Omni-Bar, Multiplier [3x], Live Search Dropdown & Mode Switcher
class FastRetailHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onFocusTable;
  final Function(String query, int multiplier) onBarcodeOrSearchSubmit;
  final ValueChanged<PosItem> onItemPickedFromDropdown;
  final VoidCallback onEmptyEnterCheckout;
  final VoidCallback onClearCartRequested;
  final VoidCallback onBackToDashboard;

  const FastRetailHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onFocusTable,
    required this.onBarcodeOrSearchSubmit,
    required this.onItemPickedFromDropdown,
    required this.onEmptyEnterCheckout,
    required this.onClearCartRequested,
    required this.onBackToDashboard,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  ConsumerState<FastRetailHeader> createState() => _FastRetailHeaderState();
}

class _FastRetailHeaderState extends ConsumerState<FastRetailHeader> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<PosItem> _searchResults = [];
  int _selectedDropdownIndex = 0;
  int _currentMultiplier = 1;
  String _effectiveQuery = '';
  Timer? _debounceTimer;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchInputChanged);
    widget.searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeDropdownOverlay();
    widget.searchController.removeListener(_onSearchInputChanged);
    widget.searchFocusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (!widget.searchFocusNode.hasFocus) {
      _removeDropdownOverlay();
    }
  }

  void _parseMultiplierAndQuery(String input) {
    final trimmed = input.trim();
    final multiplierRegex = RegExp(r'^(\d+)\*(.*)$');
    final match = multiplierRegex.firstMatch(trimmed);

    if (match != null) {
      final multVal = int.tryParse(match.group(1) ?? '1') ?? 1;
      _currentMultiplier = multVal > 0 ? multVal : 1;
      _effectiveQuery = (match.group(2) ?? '').trim();
    } else {
      _currentMultiplier = 1;
      _effectiveQuery = trimmed;
    }
  }

  void _onSearchInputChanged() {
    final text = widget.searchController.text;
    _parseMultiplierAndQuery(text);
    setState(() {});

    _debounceTimer?.cancel();
    if (_effectiveQuery.isEmpty) {
      _removeDropdownOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 150), () async {
      final posRepo = ref.read(posRepositoryProvider);
      final results = await posRepo.searchItems(_effectiveQuery, limit: 8);
      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _selectedDropdownIndex = 0;
      });

      if (results.isNotEmpty && widget.searchFocusNode.hasFocus) {
        _showDropdownOverlay();
      } else {
        _removeDropdownOverlay();
      }
    });
  }

  void _showDropdownOverlay() {
    _removeDropdownOverlay();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeDropdownOverlay,
            ),
          ),
          Positioned(
            width: 540,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 46),
              child: FastRetailSearchDropdown(
                items: _searchResults,
                selectedIndex: _selectedDropdownIndex,
                multiplier: _currentMultiplier,
                onItemSelected: (item) {
                  _removeDropdownOverlay();
                  widget.onItemPickedFromDropdown(item);
                },
                onClose: _removeDropdownOverlay,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeDropdownOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  KeyEventResult _handleOmniKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Arrow Down
    if (key == LogicalKeyboardKey.arrowDown) {
      if (_overlayEntry != null && _searchResults.isNotEmpty) {
        setState(() {
          _selectedDropdownIndex = (_selectedDropdownIndex + 1).clamp(0, _searchResults.length - 1);
        });
        _overlayEntry?.markNeedsBuild();
        return KeyEventResult.handled;
      } else if (widget.searchController.text.isEmpty) {
        widget.onFocusTable();
        return KeyEventResult.handled;
      }
    }

    // Arrow Up
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_overlayEntry != null && _searchResults.isNotEmpty) {
        setState(() {
          _selectedDropdownIndex = (_selectedDropdownIndex - 1).clamp(0, _searchResults.length - 1);
        });
        _overlayEntry?.markNeedsBuild();
        return KeyEventResult.handled;
      }
    }

    // Enter
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (_overlayEntry != null && _searchResults.isNotEmpty) {
        final chosen = _searchResults[_selectedDropdownIndex];
        _removeDropdownOverlay();
        widget.onItemPickedFromDropdown(chosen);
        return KeyEventResult.handled;
      }

      if (widget.searchController.text.trim().isEmpty) {
        // 2-Enter flow part 1: Empty omni-bar Enter opens checkout
        widget.onEmptyEnterCheckout();
        return KeyEventResult.handled;
      } else {
        _removeDropdownOverlay();
        widget.onBarcodeOrSearchSubmit(_effectiveQuery, _currentMultiplier);
        return KeyEventResult.handled;
      }
    }

    // Esc
    if (key == LogicalKeyboardKey.escape) {
      if (_overlayEntry != null) {
        _removeDropdownOverlay();
        return KeyEventResult.handled;
      }
      if (widget.searchController.text.isNotEmpty) {
        widget.searchController.clear();
        setState(() {
          _currentMultiplier = 1;
          _effectiveQuery = '';
        });
        return KeyEventResult.handled;
      } else {
        widget.onClearCartRequested();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

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

          // OMNI-BAR TEXTFIELD WITH COMPOSITED TRANSFORM TARGET
          Expanded(
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Focus(
                onKeyEvent: _handleOmniKeyEvent,
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: widget.searchController,
                    focusNode: widget.searchFocusNode,
                    textInputAction: TextInputAction.none,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Pindai barcode hardware atau ketik SKU/Nama produk (contoh: 3*899123)...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: SolluColors.textMuted),
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.search, size: 20, color: SolluColors.primary),
                          const SizedBox(width: 6),
                          if (_currentMultiplier > 1) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: SolluColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_currentMultiplier}x',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      suffixIcon: widget.searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: SolluColors.textMuted),
                              onPressed: () {
                                widget.searchController.clear();
                                setState(() {
                                  _currentMultiplier = 1;
                                  _effectiveQuery = '';
                                });
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
            ),
          ),
        ],
      ),
      actions: [
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

        // Shift indicator (if feature enabled)
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
                                  content: Text(
                                    'Tidak dapat terhubung ke server. Data transaksi tetap aman di perangkat kasir.',
                                  ),
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

