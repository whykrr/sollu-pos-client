import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';

/// Dialog Panduan Operasional Keyboard Standar Industri Ritel (Kasir Cepat)
class FastRetailKeyboardGuideDialog extends ConsumerWidget {
  const FastRetailKeyboardGuideDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const FastRetailKeyboardGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureGating = ref.watch(featureGatingProvider);
    final canUseCrm = featureGating.canUseCrm();
    final canUseCashDrawer = featureGating.canUseCashDrawer();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SolluColors.neutral, width: 1.0),
        ),
        child: Container(
          width: 720,
          constraints: const BoxConstraints(maxHeight: 650),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SolluColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.keyboard_alt_outlined, color: SolluColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panduan Operasional Keyboard Kasir Cepat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: SolluColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Standar Operasional Ritel Modern Bebas Mouse (Alfamart, Indomaret & POS Industri)',
                          style: TextStyle(fontSize: 12, color: SolluColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: SolluColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4 Thematic Groups in 2x2 Grid
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCategoryCard(
                              title: '1. Scanning, Input & Multiplier (Omni-Bar)',
                              icon: Icons.qr_code_scanner,
                              items: [
                                _OpKeyItem('Scanner', 'Pindai barcode hardware kapan saja burst (<50ms)'),
                                _OpKeyItem('[N]*[Item]', 'Multiplier kuantitas (contoh: 3* lalu scan/Enter -> 3 pcs)'),
                                _OpKeyItem('Ketik Teks', 'Pencarian nama produk / SKU live dropdown otomatis'),
                                _OpKeyItem('↑ / ↓', 'Pindah baris pada dropdown hasil pencarian'),
                                _OpKeyItem('Enter', 'Masukkan produk terpilih / buka varian'),
                                _OpKeyItem('Esc', 'Bersihkan input pencarian & tutup dropdown'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildCategoryCard(
                              title: '2. Navigasi & Tabel Keranjang',
                              icon: Icons.table_chart_outlined,
                              items: [
                                _OpKeyItem('↓ (Panah)', 'Pindah fokus dari omni-bar kosong ke tabel keranjang'),
                                _OpKeyItem('↑ / ↓', 'Pindah baris item aktif (highlight border)'),
                                _OpKeyItem('+ / -', 'Tambah / kurangi kuantitas item aktif 1 unit'),
                                _OpKeyItem('Del / Backspace', 'Void / hapus baris item aktif (PIN supervisi jika aktif)'),
                                _OpKeyItem('Enter', 'Buka modal edit detail item (diskon/catatan)'),
                                _OpKeyItem('Esc', 'Kembalikan fokus ke omni-bar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCategoryCard(
                              title: '3. Checkout & Tender (Alur 2-Enter)',
                              icon: Icons.payments_outlined,
                              items: [
                                _OpKeyItem('Enter', 'Buka checkout (saat omni-bar kosong)'),
                                _OpKeyItem('Enter ke-2', 'Tender Tunai Uang Pas instan di layar checkout'),
                                _OpKeyItem('Tab / ← →', 'Pindah tab metode pembayaran (Tunai/QRIS/EDC)'),
                                _OpKeyItem('Alt+1..4', 'Pilih instan metode pembayaran 1..4'),
                                _OpKeyItem('Numpad 0-9', 'Ketik langsung nominal uang diterima tanpa mouse'),
                                _OpKeyItem('Esc', 'Kembali ke kasir tanpa membatalkan transaksi'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildCategoryCard(
                              title: '4. Dialog Bebas Mouse & Kontrol Kasir',
                              icon: Icons.touch_app_outlined,
                              items: [
                                _OpKeyItem('Enter / Space', 'Selesai & cetak struk pada dialog sukses'),
                                _OpKeyItem('Numpad 0-9', 'Input 6-digit PIN supervisi + Enter verifikasi'),
                                _OpKeyItem('Angka 1-9', 'Pilih opsi varian langsung via nomor urut'),
                                _OpKeyItem('Member CRM', 'Pilih pelanggan / member kasir',
                                    statusBadge: canUseCrm ? 'Aktif' : 'Nonaktif',
                                    isGatedActive: canUseCrm),
                                _OpKeyItem('Space', 'Buka laci kasir manual (drawer kick)',
                                    statusBadge: canUseCashDrawer ? 'Aktif' : 'Nonaktif',
                                    isGatedActive: canUseCashDrawer),
                                _OpKeyItem('Ctrl+P', 'Cetak ulang struk transaksi terakhir'),
                                _OpKeyItem('?', 'Buka panduan operasional keyboard ini'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Tips: Kasir Cepat dioptimalkan 100% untuk keyboard fisik & barcode scanner tanpa mouse.',
                      style: TextStyle(fontSize: 12, color: SolluColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolluColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Mengerti (Esc)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required List<_OpKeyItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SolluColors.neutral, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: SolluColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SolluColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 58),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: SolluColors.neutral),
                      ),
                      child: Text(
                        it.key,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: SolluColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it.desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: it.isGatedActive == false
                              ? SolluColors.textMuted.withValues(alpha: 0.6)
                              : SolluColors.textDark,
                        ),
                      ),
                    ),
                    if (it.statusBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: (it.isGatedActive ?? false)
                              ? SolluColors.success.withValues(alpha: 0.1)
                              : SolluColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (it.isGatedActive ?? false)
                                ? SolluColors.success.withValues(alpha: 0.3)
                                : SolluColors.neutral,
                          ),
                        ),
                        child: Text(
                          it.statusBadge!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: (it.isGatedActive ?? false)
                                ? SolluColors.success
                                : SolluColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _OpKeyItem {
  final String key;
  final String desc;
  final String? statusBadge;
  final bool? isGatedActive;

  _OpKeyItem(this.key, this.desc, {this.statusBadge, this.isGatedActive});
}
