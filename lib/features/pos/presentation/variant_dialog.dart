import 'package:flutter/material.dart';

class VariantDialog extends StatelessWidget {
  final Map<String, dynamic> product;

  const VariantDialog({super.key, required this.product});

  static Future<void> show(BuildContext context, Map<String, dynamic> product) {
    return showDialog(
      context: context,
      builder: (context) => VariantDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pilih Varian: ${product['name']}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ukuran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Regular'), selected: true, onSelected: (v) {}),
                ChoiceChip(label: const Text('Large (+Rp 5.000)'), selected: false, onSelected: (v) {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Misal: Jangan pakai bawang...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
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
          onPressed: () {
            // TODO: Tambah ke keranjang
            Navigator.of(context).pop();
          },
          child: const Text('Tambah ke Keranjang'),
        ),
      ],
    );
  }
}
