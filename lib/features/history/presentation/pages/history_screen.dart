import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: SolluColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: SolluColors.neutralMuted),
              SizedBox(height: 16),
              Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.textDark),
              ),
              SizedBox(height: 8),
              Text('Modul ini siap dikembangkan untuk menampilkan histori penjualan.', style: TextStyle(color: SolluColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
