import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/theme/sollu_spacing.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/utils/currency_input_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

class DiscountDialog extends ConsumerStatefulWidget {
  const DiscountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const DiscountDialog(),
    );
  }

  @override
  ConsumerState<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends ConsumerState<DiscountDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _manualValController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  final FocusNode _dialogFocusNode = FocusNode();
  final FocusNode _manualValFocusNode = FocusNode();
  final FocusNode _manualNameFocusNode = FocusNode();
  final ScrollController _promoScrollController = ScrollController();
  String _manualType = 'percentage'; // 'percentage' or 'fixed'
  int _selectedPromoIndex = 0;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.index == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _manualValFocusNode.requestFocus();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _dialogFocusNode.requestFocus();
        });
      }
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dialogFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promoScrollController.dispose();
    _dialogFocusNode.dispose();
    _manualValFocusNode.dispose();
    _manualNameFocusNode.dispose();
    _manualValController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  void _scrollToSelectedPromo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_promoScrollController.hasClients) return;
      const double itemHeight = 76.0;
      final viewportHeight = _promoScrollController.position.viewportDimension > 0
          ? _promoScrollController.position.viewportDimension
          : 250.0;
      final itemTop = _selectedPromoIndex * itemHeight;
      final itemBottom = itemTop + itemHeight;
      final currentOffset = _promoScrollController.offset;

      double targetOffset = currentOffset;
      if (itemTop < currentOffset) {
        targetOffset = itemTop;
      } else if (itemBottom > currentOffset + viewportHeight) {
        targetOffset = itemBottom - viewportHeight;
      }

      targetOffset = targetOffset.clamp(0.0, _promoScrollController.position.maxScrollExtent);
      if ((targetOffset - currentOffset).abs() > 1.0) {
        _promoScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _applyPromo(Promo promo) {
    if (_isApplying) return;
    _isApplying = true;

    ref.read(appliedDiscountProvider.notifier).applyPromo(promo);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo "${promo.name}" berhasil diterapkan!'),
        backgroundColor: SolluColors.success,
      ),
    );
  }

  void _applyManualDiscount() {
    if (_isApplying) return;

    final val = _manualType == 'fixed'
        ? CurrencyInputFormatter.parse(_manualValController.text)
        : (double.tryParse(
                _manualValController.text.trim().replaceAll(',', '.'),
              ) ??
              0.0);
    if (val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nilai diskon yang valid'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }

    if (_manualType == 'percentage' && val > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Persentase diskon tidak boleh melebihi 100%'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }

    _isApplying = true;
    final customName = _manualNameController.text.trim().isNotEmpty
        ? _manualNameController.text.trim()
        : (_manualType == 'percentage'
              ? 'Diskon $val%'
              : 'Potongan ${CurrencyFormatter.format(val.toInt())}');

    ref
        .read(appliedDiscountProvider.notifier)
        .applyManualDiscount(type: _manualType, value: val, name: customName);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diskon "$customName" berhasil diterapkan!'),
        backgroundColor: SolluColors.success,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    final isAlt = HardwareKeyboard.instance.isAltPressed;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (_tabController.index == 0) {
      final promos = ref.read(activePromosProvider).asData?.value ?? [];

      if (event.logicalKey == LogicalKeyboardKey.tab ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _tabController.animateTo(1);
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (promos.isNotEmpty) {
          setState(() {
            _selectedPromoIndex = (_selectedPromoIndex + 1).clamp(0, promos.length - 1);
          });
          _scrollToSelectedPromo();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (promos.isNotEmpty) {
          setState(() {
            _selectedPromoIndex = (_selectedPromoIndex - 1).clamp(0, promos.length - 1);
          });
          _scrollToSelectedPromo();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (promos.isNotEmpty && _selectedPromoIndex < promos.length) {
          _applyPromo(promos[_selectedPromoIndex]);
          return KeyEventResult.handled;
        }
      }
    }

    if (_tabController.index == 1) {
      // Ctrl+Tab / Shift+Tab to switch back to Tab 0
      if ((isCtrl || isShift) && event.logicalKey == LogicalKeyboardKey.tab) {
        _tabController.animateTo(0);
        return KeyEventResult.handled;
      }

      // Alt+1 / Alt+ArrowLeft: Select %
      if (isAlt && (event.logicalKey == LogicalKeyboardKey.digit1 ||
          event.logicalKey == LogicalKeyboardKey.numpad1 ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft)) {
        setState(() {
          _manualType = 'percentage';
          _manualValController.clear();
        });
        _manualValFocusNode.requestFocus();
        return KeyEventResult.handled;
      }

      // Alt+2 / Alt+ArrowRight: Select Rp
      if (isAlt && (event.logicalKey == LogicalKeyboardKey.digit2 ||
          event.logicalKey == LogicalKeyboardKey.numpad2 ||
          event.logicalKey == LogicalKeyboardKey.arrowRight)) {
        setState(() {
          _manualType = 'fixed';
          _manualValController.clear();
        });
        _manualValFocusNode.requestFocus();
        return KeyEventResult.handled;
      }

      // ArrowLeft / ArrowRight selection when editing value is empty or not in text field
      if (!_manualNameFocusNode.hasFocus) {
        final valText = _manualValController.text.trim();
        if (valText.isEmpty || !_manualValFocusNode.hasFocus) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_manualType == 'percentage') {
              setState(() {
                _manualType = 'fixed';
                _manualValController.clear();
              });
              _manualValFocusNode.requestFocus();
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_manualType == 'fixed') {
              setState(() {
                _manualType = 'percentage';
                _manualValController.clear();
              });
              _manualValFocusNode.requestFocus();
              return KeyEventResult.handled;
            } else if (_manualType == 'percentage') {
              // Return to Tab 0 (Promo Master)
              _tabController.animateTo(0);
              return KeyEventResult.handled;
            }
          }
        }
      }

      // Enter to submit
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        _applyManualDiscount();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(activePromosProvider);
    final appliedDiscount = ref.watch(appliedDiscountProvider);

    return Focus(
      focusNode: _dialogFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 560,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SolluColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.discount_outlined,
                      color: SolluColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promo & Diskon',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: SolluColors.textDark,
                          ),
                        ),
                        if (appliedDiscount != null)
                          Text(
                            'Aktif: ${appliedDiscount.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolluColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          const Text(
                            'Pilih promo master atau atur diskon manual',
                            style: TextStyle(
                              fontSize: 12,
                              color: SolluColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (appliedDiscount != null)
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(appliedDiscountProvider.notifier)
                            .clearDiscount();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: SolluColors.danger,
                      ),
                      label: const Text(
                        'Hapus Promo',
                        style: TextStyle(color: SolluColors.danger, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: SolluColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: SolluColors.textMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Pilih Promo Master'),
                    Tab(text: 'Diskon Manual'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Promos List from Master Data
                    promosAsync.when(
                      data: (promos) {
                        if (promos.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 48,
                                  color: SolluColors.neutralMuted.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada promo aktif',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: SolluColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Promo master data dapat disinkronkan dari web backoffice.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: SolluColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: _promoScrollController,
                          itemCount: promos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final promo = promos[index];
                            final isApplied =
                                appliedDiscount?.promoId == promo.id;
                            final isHighlighted = index == _selectedPromoIndex;

                            final String discountTag =
                                promo.promoType == 'percentage'
                                ? '${promo.discountValue.toInt()}% OFF'
                                : 'Potongan ${CurrencyFormatter.format(promo.discountValue.toInt())}';

                            final String dateStr = promo.endDate != null
                                ? 'Berlaku s/d ${DateFormat('dd MMM yyyy').format(promo.endDate!)}'
                                : 'Berlaku selamanya';

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPromoIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isApplied
                                      ? SolluColors.primary.withValues(alpha: 0.06)
                                      : isHighlighted
                                          ? SolluColors.primary.withValues(alpha: 0.04)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isApplied || isHighlighted
                                        ? SolluColors.primary
                                        : SolluColors.neutral,
                                    width: (isApplied || isHighlighted) ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isApplied
                                            ? SolluColors.primary
                                            : SolluColors.secondary.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        discountTag,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isApplied
                                              ? Colors.white
                                              : SolluColors.secondaryDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promo.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: SolluColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Target: ${promo.targetType == "product" ? "Per Produk" : "Per Bill"} • $dateStr',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: SolluColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () => _applyPromo(promo),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isApplied
                                            ? SolluColors.success
                                            : SolluColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isApplied ? 'Terpasang' : 'Terapkan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) =>
                          Center(child: Text('Gagal memuat promo: $err')),
                    ),

                    // Tab 2: Manual Discount
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipe Diskon',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: SolluColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _manualType = 'percentage';
                                      _manualValController.clear();
                                    });
                                    _manualValFocusNode.requestFocus();
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _manualType == 'percentage'
                                          ? SolluColors.primary.withValues(
                                              alpha: 0.1,
                                            )
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _manualType == 'percentage'
                                            ? SolluColors.primary
                                            : SolluColors.neutral,
                                        width: _manualType == 'percentage'
                                            ? 1.5
                                            : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Persentase (%) [Alt+1]',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _manualType == 'percentage'
                                              ? SolluColors.primary
                                              : SolluColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _manualType = 'fixed';
                                      _manualValController.clear();
                                    });
                                    _manualValFocusNode.requestFocus();
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _manualType == 'fixed'
                                          ? SolluColors.primary.withValues(
                                              alpha: 0.1,
                                            )
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _manualType == 'fixed'
                                            ? SolluColors.primary
                                            : SolluColors.neutral,
                                        width: _manualType == 'fixed' ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Nominal Tetap (Rp) [Alt+2]',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _manualType == 'fixed'
                                              ? SolluColors.primary
                                              : SolluColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _manualType == 'percentage'
                                ? 'Persentase Diskon (%)'
                                : 'Jumlah Potongan (Rp)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: SolluColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _manualValController,
                            focusNode: _manualValFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: _manualType == 'fixed'
                                ? [CurrencyInputFormatter()]
                                : [],
                            autofocus: true,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: _manualType == 'percentage'
                                  ? 'Contoh: 10'
                                  : 'Contoh: 15000',
                              prefixText: _manualType == 'fixed' ? 'Rp ' : null,
                              suffixText: _manualType == 'percentage'
                                  ? '%'
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSubmitted: (_) => _applyManualDiscount(),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Catatan / Keterangan (Opsional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: SolluColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _manualNameController,
                            focusNode: _manualNameFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Cth: Diskon Khusus Karyawan / Kerabat',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSubmitted: (_) => _applyManualDiscount(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _applyManualDiscount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SolluColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Terapkan Diskon Manual',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Footer Shortcuts Guide
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SolluColors.neutral, width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tabController.index == 0
                            ? '[Tab / →] Diskon Manual  •  [↑ / ↓] Pilih Promo  •  [Enter] Terapkan  •  [Esc] Tutup'
                            : '[Ctrl+Tab] Promo Master  •  [←/Alt+1] %  •  [→/Alt+2] Rp  •  [Enter] Terapkan  •  [Esc] Tutup',
                        style: const TextStyle(
                          fontSize: 11,
                          color: SolluColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Tutup (Esc)',
                        style: TextStyle(color: SolluColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerDialog extends ConsumerStatefulWidget {
  const CustomerDialog({super.key});

  static Future<Customer?> show(BuildContext context) {
    return showDialog<Customer?>(
      context: context,
      builder: (context) => const CustomerDialog(),
    );
  }

  @override
  ConsumerState<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends ConsumerState<CustomerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    return AlertDialog(
      title: const Text(
        'Pilih Pelanggan / Member',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: SolluColors.textDark,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama atau no HP pelanggan...',
                prefixIcon: const Icon(Icons.person_search),
                contentPadding: SolluSpacing.inputPadding,
                border: OutlineInputBorder(borderRadius: SolluSpacing.radiusSm),
              ),
            ),
            const SizedBox(height: SolluSpacing.lg),
            SizedBox(
              height: 260,
              child: customersAsync.when(
                data: (customers) {
                  final filtered = customers.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        (c.phone != null && c.phone!.contains(_searchQuery));
                  }).toList();

                  return ListView.separated(
                    itemCount: filtered.length + 1,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: SolluColors.neutral),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedCustomer == null;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: const Icon(
                            Icons.people_outline,
                            color: SolluColors.primary,
                          ),
                          title: const Text(
                            'Pelanggan Umum (Walk-in)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Tanpa data member khusus',
                            style: TextStyle(
                              fontSize: 11,
                              color: SolluColors.textMuted,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: SolluColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            ref
                                .read(selectedCustomerProvider.notifier)
                                .clearCustomer();
                            Navigator.of(context).pop(null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mode Pelanggan Umum dipilih'),
                                backgroundColor: SolluColors.info,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      }

                      final cust = filtered[index - 1];
                      final isSelected = selectedCustomer?.id == cust.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: const Icon(
                          Icons.person,
                          color: SolluColors.primary,
                        ),
                        title: Text(
                          cust.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          cust.phone ?? cust.code ?? 'Member',
                          style: const TextStyle(
                            fontSize: 11,
                            color: SolluColors.textMuted,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: SolluColors.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          ref
                              .read(selectedCustomerProvider.notifier)
                              .selectCustomer(cust);
                          Navigator.of(context).pop(cust);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pelanggan "${cust.name}" dipilih'),
                              backgroundColor: SolluColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal (Esc)',
            style: TextStyle(color: SolluColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class EditCartItemDialog extends StatefulWidget {
  final CartItem item;
  final void Function(
    int qty,
    String? discountType,
    double? discountValue,
    String? notes,
  )
  onSaved;

  const EditCartItemDialog({
    super.key,
    required this.item,
    required this.onSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required CartItem item,
    required void Function(
      int qty,
      String? discountType,
      double? discountValue,
      String? notes,
    )
    onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EditCartItemDialog(item: item, onSaved: onSaved),
    );
  }

  @override
  State<EditCartItemDialog> createState() => _EditCartItemDialogState();
}

class _EditCartItemDialogState extends State<EditCartItemDialog> {
  late final TextEditingController _qtyController;
  late final TextEditingController _discountController;
  late final TextEditingController _notesController;
  String _discountType = 'fixed';

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.item.qty.toString());
    _qtyController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _qtyController.text.length,
    );

    _discountType = widget.item.discountType ?? 'fixed';
    _discountController = TextEditingController(
      text: widget.item.discountValue != null && widget.item.discountValue! > 0
          ? widget.item.discountValue!.toInt().toString()
          : '',
    );
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final newQty = int.tryParse(_qtyController.text.trim());
    if (newQty != null && newQty > 0) {
      double? discVal;
      final discText = _discountController.text.trim().replaceAll(',', '.');
      if (discText.isNotEmpty) {
        discVal = double.tryParse(discText);
      }

      widget.onSaved(
        newQty,
        discVal != null && discVal > 0 ? _discountType : null,
        discVal != null && discVal > 0 ? discVal : null,
        _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _submit();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SolluColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_note,
                color: SolluColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Detail Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: SolluColors.textDark,
                    ),
                  ),
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SolluColors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QTY
                const Text(
                  'Kuantitas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.primary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),

                // DISCOUNT
                const Text(
                  'Diskon Per Item',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: SolluColors.neutral),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _discountType,
                          items: const [
                            DropdownMenuItem(value: 'fixed', child: Text('Rp')),
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text('%'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _discountType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Nilai Diskon',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NOTES
                const Text(
                  'Catatan Tambahan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Misal: Jangan pakai bawang...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal (Esc)',
              style: TextStyle(color: SolluColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.primary,
              foregroundColor: Colors.white,
              padding: SolluSpacing.buttonPadding,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class ShortcutHelpDialog extends StatelessWidget {
  const ShortcutHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ShortcutHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shortcuts = [
      {'key': 'F1', 'desc': 'Pencarian Produk / Scan Barcode Ready'},
      {'key': 'F2', 'desc': 'Diskon Transaksi / Item (Perlu Wewenang)'},
      {'key': 'F3', 'desc': 'Fokus Keranjang & Ubah Qty'},
      {'key': 'F4', 'desc': 'Pilih Pelanggan / Member'},
      {'key': 'F5', 'desc': 'Open Price / Ubah Harga Manual (Perlu Wewenang)'},
      {'key': 'F6', 'desc': 'Void Item Keranjang (Perlu Wewenang)'},
      {'key': 'F7', 'desc': 'Void Seluruh Transaksi / Bersihkan (Perlu Wewenang)'},
      {'key': 'F8', 'desc': 'Tahan Pesanan (Hold Bill)'},
      {'key': 'F9', 'desc': 'Daftar Pesanan Ditahan (Recall Bill)'},
      {'key': 'F10', 'desc': 'Bayar Cepat Tunai (Quick Cash)'},
      {'key': 'F11', 'desc': 'Metode Pembayaran Lain (QRIS / EDC / Transfer)'},
      {'key': 'F12', 'desc': 'Bayar & Selesaikan Transaksi (Checkout)'},
      {'key': 'Esc', 'desc': 'Batal / Bersihkan Input / Tutup Modal'},
      {'key': '↑ / ↓', 'desc': 'Navigasi Pilihan Item Keranjang'},
      {'key': 'Enter', 'desc': 'Konfirmasi Aksi / Tambah Item'},
      {'key': 'Ctrl+P', 'desc': 'Cetak Ulang Struk Transaksi Terakhir'},
      {'key': 'Space', 'desc': 'Buka Laci Kasir Manual (Cash Drawer Kick)'},
    ];

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard, color: SolluColors.primary),
          SizedBox(width: SolluSpacing.md),
          Text(
            'Panduan Keyboard Shortcut',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: SolluColors.textDark,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan tombol fungsi pada keyboard untuk mempercepat navigasi kasir:',
              style: TextStyle(color: SolluColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: SolluSpacing.lg),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shortcuts.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: SolluColors.neutral),
                itemBuilder: (context, index) {
                  final s = shortcuts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SolluColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: SolluColors.primaryLight.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            s['key']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SolluColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: SolluSpacing.lg),
                        Expanded(
                          child: Text(
                            s['desc']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: SolluColors.textDark,
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
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.primary,
            foregroundColor: Colors.white,
            padding: SolluSpacing.buttonPadding,
          ),
          child: const Text('Tutup (Esc)'),
        ),
      ],
    );
  }
}

class EmptyCartDialog extends StatelessWidget {
  const EmptyCartDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const EmptyCartDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolluColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_shopping_cart_outlined,
                size: 48,
                color: SolluColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tidak dapat melanjutkan pembayaran. Silakan pilih minimal satu produk ke dalam keranjang terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: SolluColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolluColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Mengerti (Esc)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Dialog untuk Open Price / Ubah Harga Manual Baris Item (Shortcut F5)
class OpenPriceDialog extends StatefulWidget {
  final CartItem item;
  final Function(double newPrice) onPriceUpdated;

  const OpenPriceDialog({
    super.key,
    required this.item,
    required this.onPriceUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required CartItem item,
    required Function(double newPrice) onPriceUpdated,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OpenPriceDialog(
        item: item,
        onPriceUpdated: onPriceUpdated,
      ),
    );
  }

  @override
  State<OpenPriceDialog> createState() => _OpenPriceDialogState();
}

class _OpenPriceDialogState extends State<OpenPriceDialog> {
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _priceController.text = CurrencyInputFormatter.format(widget.item.price.toInt());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _priceController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _priceController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = CurrencyInputFormatter.parse(_priceController.text);
    if (parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga tidak boleh negatif'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }
    widget.onPriceUpdated(parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _submit();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SolluColors.neutral, width: 1.5),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SolluColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.price_change_outlined, color: SolluColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ubah Harga Jual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Harga saat ini: ${CurrencyFormatter.format(widget.item.price.toInt())}',
                style: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
              ),
              const SizedBox(height: 16),
              const Text(
                'Harga Satuan Baru (Rp)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SolluColors.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.neutral, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal (Esc)'),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Simpan (Enter)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Modal Dialog Bayar Cepat Tunai (Shortcut F10)
class QuickCashDialog extends StatefulWidget {
  final int totalAmount;
  final Function(double cashReceived) onConfirm;

  const QuickCashDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required int totalAmount,
    required Function(double cashReceived) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickCashDialog(
        totalAmount: totalAmount,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<QuickCashDialog> createState() => _QuickCashDialogState();
}

class _QuickCashDialogState extends State<QuickCashDialog> {
  final TextEditingController _cashController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  double _cashReceived = 0.0;

  @override
  void initState() {
    super.initState();
    _cashReceived = widget.totalAmount.toDouble();
    _cashController.text = CurrencyInputFormatter.format(widget.totalAmount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _cashController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _cashController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<double> _getPresets() {
    final total = widget.totalAmount.toDouble();
    final Set<double> presets = {total};

    final standardDenominations = [20000.0, 50000.0, 100000.0, 200000.0];
    for (final denom in standardDenominations) {
      if (denom > total) {
        presets.add(denom);
      }
    }

    final next50k = (total / 50000.0).ceil() * 50000.0;
    if (next50k > total) presets.add(next50k);

    final next100k = (total / 100000.0).ceil() * 100000.0;
    if (next100k > total) presets.add(next100k);

    final sorted = presets.toList()..sort();
    return sorted.take(4).toList();
  }

  void _onPresetSelected(double amount) {
    setState(() {
      _cashReceived = amount;
      _cashController.text = CurrencyInputFormatter.format(amount.toInt());
    });
  }

  void _submit() {
    if (_cashReceived < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang tunai kurang dari total tagihan!'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }
    Navigator.of(context).pop();
    widget.onConfirm(_cashReceived);
  }

  @override
  Widget build(BuildContext context) {
    final double change = (_cashReceived - widget.totalAmount).clamp(0.0, double.infinity);
    final presets = _getPresets();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _submit();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SolluColors.neutral, width: 1.5),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SolluColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payments_outlined, color: SolluColors.success, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Bayar Cepat Tunai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SolluColors.textDark),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Tagihan Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SolluColors.neutral, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tagihan:', style: TextStyle(fontSize: 14, color: SolluColors.textMuted)),
                    Text(
                      CurrencyFormatter.format(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SolluColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pilihan Cepat / Preset Pecahan
              const Text(
                'Pilihan Nominal Cepat',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SolluColors.textDark),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((amount) {
                  final isExact = amount == widget.totalAmount.toDouble();
                  final isSelected = _cashReceived == amount;
                  return InkWell(
                    onTap: () => _onPresetSelected(amount),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SolluColors.primary.withValues(alpha: 0.1)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? SolluColors.primary : SolluColors.neutral,
                          width: isSelected ? 2.0 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isExact ? 'Uang Pas (${CurrencyFormatter.format(amount.toInt())})' : CurrencyFormatter.format(amount.toInt()),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? SolluColors.primary : SolluColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Input Diterima
              const Text(
                'Uang Diterima (Rp)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SolluColors.textDark),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _cashController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SolluColors.textDark),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.neutral, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: SolluColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  final parsed = CurrencyInputFormatter.parse(val);
                  setState(() {
                    _cashReceived = parsed;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Kembalian
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: change > 0 ? SolluColors.success.withValues(alpha: 0.08) : SolluColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: change > 0 ? SolluColors.success.withValues(alpha: 0.4) : SolluColors.neutral,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kembalian:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: change > 0 ? SolluColors.success : SolluColors.textMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(change.toInt()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: change > 0 ? SolluColors.success : SolluColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal (Esc)'),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Selesaikan Pembayaran (Enter)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
