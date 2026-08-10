import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class DiscountDialog extends StatelessWidget {
  const DiscountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const DiscountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Diskon Bill (F4)', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Persentase (%) atau Nominal (Rp)',
                prefixIcon: const Icon(Icons.discount),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal (Esc)'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(backgroundColor: SolluColors.primary),
          child: const Text('Terapkan Diskon'),
        ),
      ],
    );
  }
}

class CustomerDialog extends StatelessWidget {
  const CustomerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CustomerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockCustomers = ['Pelanggan Umum', 'Budi Harapan (Member)', 'PT Solusi Makmur (B2B)'];

    return AlertDialog(
      title: const Text('Pilih Pelanggan (F5)', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
                prefixIcon: const Icon(Icons.person_search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                itemCount: mockCustomers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: SolluColors.primary),
                    title: Text(mockCustomers[index]),
                    onTap: () => Navigator.of(context).pop(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal (Esc)'),
        ),
      ],
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
    final shortcuts = [
      {'key': 'F1', 'desc': 'Cari Produk / Scan Barcode'},
      {'key': 'F2', 'desc': 'Fokus Panel Keranjang'},
      {'key': 'F3', 'desc': 'Tahan Pesanan (Hold Order)'},
      {'key': 'F4', 'desc': 'Tambah Diskon Bill'},
      {'key': 'F5', 'desc': 'Pilih Pelanggan / Member'},
      {'key': 'F8', 'desc': 'Checkout & Pembayaran'},
      {'key': 'F10', 'desc': 'Cetak Ulang Struk (Reprint)'},
      {'key': 'F12', 'desc': 'Tutup Shift Kasir'},
      {'key': 'Esc', 'desc': 'Tutup Popup / Batal'},
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.keyboard, color: SolluColors.primary),
          SizedBox(width: 12),
          Text('Panduan Keyboard Shortcut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gunakan tombol fungsi pada keyboard untuk mempercepat navigasi kasir:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shortcuts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = shortcuts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SolluColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SolluColors.primaryLight.withOpacity(0.3)),
                          ),
                          child: Text(
                            s['key']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(s['desc']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
          style: ElevatedButton.styleFrom(backgroundColor: SolluColors.primary),
          child: const Text('Tutup (Esc)'),
        ),
      ],
    );
  }
}
