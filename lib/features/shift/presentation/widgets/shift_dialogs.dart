import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/theme/sollu_spacing.dart';
import 'package:sollu_pos_app/core/utils/currency_formatter.dart';

class OpenShiftDialog extends StatelessWidget {
  const OpenShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Wajib diisi sebelum mulai kasir
      builder: (context) => const OpenShiftDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buka Shift', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang! Silakan masukkan modal awal (kas) di laci untuk memulai shift Anda.',
              style: TextStyle(color: SolluColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: SolluSpacing.xxl),
            const Text('Modal Awal (Kas)', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
            const SizedBox(height: SolluSpacing.sm),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.primary),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                contentPadding: SolluSpacing.inputPadding,
                border: OutlineInputBorder(borderRadius: SolluSpacing.radiusSm),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.primary,
            foregroundColor: Colors.white,
            padding: SolluSpacing.buttonPadding,
          ),
          child: const Text('Mulai Shift'),
        ),
      ],
    );
  }
}

class CloseShiftDialog extends StatelessWidget {
  const CloseShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CloseShiftDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tutup Shift', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow('Modal Awal', CurrencyFormatter.format(500000)),
            const SizedBox(height: SolluSpacing.sm),
            _SummaryRow('Total Penjualan Tunai', CurrencyFormatter.format(1250000)),
            const SizedBox(height: SolluSpacing.sm),
            _SummaryRow('Kas Masuk/Keluar', CurrencyFormatter.format(-50000)),
            const Divider(height: SolluSpacing.xl),
            _SummaryRow('Ekspektasi Kas di Laci', CurrencyFormatter.format(1700000), isBold: true),
            const SizedBox(height: SolluSpacing.xxl),
            const Text('Kas Aktual di Laci', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
            const SizedBox(height: SolluSpacing.sm),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.primary),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                contentPadding: SolluSpacing.inputPadding,
                border: OutlineInputBorder(borderRadius: SolluSpacing.radiusSm),
              ),
            ),
            const SizedBox(height: SolluSpacing.lg),
            const Text('Selisih: Rp 0', style: TextStyle(color: SolluColors.success, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal (Esc)', style: TextStyle(color: SolluColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.danger,
            foregroundColor: Colors.white,
            padding: SolluSpacing.buttonPadding,
          ),
          child: const Text('Akhiri Shift'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? SolluColors.textDark : SolluColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? SolluColors.primary : SolluColors.textDark,
          ),
        ),
      ],
    );
  }
}
