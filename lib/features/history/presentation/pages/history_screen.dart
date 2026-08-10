import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: SolluColors.surface,
        elevation: 1,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: SolluColors.neutralMuted),
            SizedBox(height: 16),
            Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.textDark),
            ),
            SizedBox(height: 8),
            Text('Modul ini siap dikembangkan untuk menampilkan histori penjualan.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
