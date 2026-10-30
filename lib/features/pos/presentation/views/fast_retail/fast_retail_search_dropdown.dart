import 'package:flutter/material.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';

/// Floating Dropdown Overlay untuk live fulltext omni-search di Kasir Cepat
class FastRetailSearchDropdown extends StatefulWidget {
  final List<PosItem> items;
  final int selectedIndex;
  final ValueChanged<PosItem> onItemSelected;
  final VoidCallback? onClose;
  final int multiplier;

  const FastRetailSearchDropdown({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onClose,
    this.multiplier = 1,
  });

  @override
  State<FastRetailSearchDropdown> createState() => _FastRetailSearchDropdownState();
}

class _FastRetailSearchDropdownState extends State<FastRetailSearchDropdown> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToSelected();
  }

  @override
  void didUpdateWidget(covariant FastRetailSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.items != widget.items) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || widget.items.isEmpty) return;
      const double itemHeight = 62.0;
      final viewportHeight = _scrollController.position.viewportDimension > 0
          ? _scrollController.position.viewportDimension
          : 250.0;
      final safeIndex = widget.selectedIndex.clamp(0, widget.items.length - 1);
      final itemTop = safeIndex * itemHeight;
      final itemBottom = itemTop + itemHeight;
      final currentOffset = _scrollController.offset;

      double targetOffset = currentOffset;
      if (itemTop < currentOffset) {
        targetOffset = itemTop;
      } else if (itemBottom > currentOffset + viewportHeight) {
        targetOffset = itemBottom - viewportHeight;
      }

      targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
      if ((targetOffset - currentOffset).abs() > 1.0) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: Container(
          width: 500,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SolluColors.neutral, width: 1.0),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_off, size: 18, color: SolluColors.textMuted),
              SizedBox(width: 8),
              Text(
                'Tidak ada produk yang cocok dengan pencarian.',
                style: TextStyle(fontSize: 12.5, color: SolluColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: Container(
        width: 540,
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SolluColors.primary.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown List
            Flexible(
              child: ListView.separated(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: widget.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: SolluColors.neutral),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.selectedIndex;

                  final String stockText;
                  if (item.isService) {
                    stockText = 'Layanan';
                  } else if (!item.trackInventory) {
                    stockText = 'Stok: ∞';
                  } else {
                    stockText = 'Stok: ${item.stock.toInt()} ${item.unit}';
                  }

                  return InkWell(
                    onTap: () => widget.onItemSelected(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: isSelected
                          ? SolluColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          if (isSelected)
                            Container(
                              width: 3,
                              height: 28,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: SolluColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (widget.multiplier > 1) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: SolluColors.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${widget.multiplier}x',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          color: SolluColors.textDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (item.barcode != null || item.sku != null) ...[
                                      Text(
                                        item.barcode ?? item.sku!,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          color: SolluColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (item.variantCombination != null && item.variantCombination!.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: SolluColors.background,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: SolluColors.neutral, width: 0.5),
                                        ),
                                        child: Text(
                                          item.variantCombination!,
                                          style: const TextStyle(fontSize: 10, color: SolluColors.textMuted),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      stockText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: item.stock <= 0 && item.trackInventory
                                            ? SolluColors.danger
                                            : SolluColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            CurrencyFormatter.format(item.price.toInt()),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer Hints
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
                border: Border(
                  top: BorderSide(color: SolluColors.neutral, width: 1.0),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '[↑ / ↓] Navigasi Baris',
                      style: TextStyle(fontSize: 11, color: SolluColors.textMuted),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '[Enter] Pilih & Masuk Keranjang',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SolluColors.primary),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '[Esc] Tutup',
                      style: TextStyle(fontSize: 11, color: SolluColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
