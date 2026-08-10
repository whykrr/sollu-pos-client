import 'package:flutter/material.dart';
import 'product_grid.dart';
import 'cart_panel.dart';

class PosLayout extends StatelessWidget {
  const PosLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir POS (F1-F12 Shortcuts)'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Shift: Siang | Kasir: Budi',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Sync Data
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sync Master Data'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Pane: Product Grid (2/3 of the screen)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: const ProductGrid(),
            ),
          ),
          // Vertical Divider
          const VerticalDivider(width: 1, thickness: 1),
          // Right Pane: Cart Panel (1/3 of the screen)
          const Expanded(
            flex: 1,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }
}
