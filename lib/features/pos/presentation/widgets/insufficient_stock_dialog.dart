import 'package:flutter/material.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';

class InsufficientStockDialog extends StatelessWidget {
  final List<String>? outOfStockItemNames;

  const InsufficientStockDialog({
    super.key,
    this.outOfStockItemNames,
  });

  static Future<void> show(
    BuildContext context, {
    List<String>? outOfStockItemNames,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InsufficientStockDialog(
        outOfStockItemNames: outOfStockItemNames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                Icons.inventory_2_outlined,
                size: 44,
                color: SolluColors.warning,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Stok Tidak Cukup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stok tidak cukup, Harap sesuaikan kuantitas barang di keranjang belanja.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: SolluColors.textMuted,
                height: 1.4,
              ),
            ),
            if (outOfStockItemNames != null && outOfStockItemNames!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: outOfStockItemNames!.length,
                  separatorBuilder: (_, _) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 14,
                          color: SolluColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            outOfStockItemNames![index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SolluColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
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
                  'Mengerti',
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
