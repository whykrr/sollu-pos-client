import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';

class ReceiptSettingsDialog extends ConsumerStatefulWidget {
  const ReceiptSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ReceiptSettingsDialog(),
    );
  }

  @override
  ConsumerState<ReceiptSettingsDialog> createState() => _ReceiptSettingsDialogState();
}

class _ReceiptSettingsDialogState extends ConsumerState<ReceiptSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final config = ref.read(selectedPrinterProvider);
    if (config != null) {
      _storeNameController.text = config.storeName ?? '';
      _headerController.text = config.headerNote ?? '';
      _footerController.text = config.footerNote ?? '';
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final storeName = _storeNameController.text.trim();
    final headerNote = _headerController.text.trim();
    final footerNote = _footerController.text.trim();

    final currentConfig = ref.read(selectedPrinterProvider);
    if (currentConfig != null) {
      final updated = currentConfig.copyWith(
        storeName: storeName.isNotEmpty ? storeName : null,
        headerNote: headerNote.isNotEmpty ? headerNote : null,
        footerNote: footerNote.isNotEmpty ? footerNote : null,
      );
      await ref.read(selectedPrinterProvider.notifier).savePrinter(updated);
    } else {
      // Create a default printer config with these notes
      final newConfig = PrinterConfig(
        name: 'Default Thermal Printer',
        address: '',
        storeName: storeName.isNotEmpty ? storeName : null,
        headerNote: headerNote.isNotEmpty ? headerNote : null,
        footerNote: footerNote.isNotEmpty ? footerNote : null,
      );
      await ref.read(selectedPrinterProvider.notifier).savePrinter(newConfig);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Pengaturan struk berhasil disimpan!'),
            ],
          ),
          backgroundColor: SolluColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SolluColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long, color: SolluColors.secondaryDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan Struk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: SolluColors.textDark,
                          ),
                        ),
                        Text(
                          'Kustomisasi header, footer, dan pesan struk',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolluColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
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
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Nama Toko Kustom (Opsional)
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Toko pada Struk (Opsional)',
                  hintText: 'Biarkan kosong untuk memakai nama outlet resmi',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // Header Note
              TextField(
                controller: _headerController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Teks Header Pembuka (Opsional)',
                  hintText: 'Contoh: Selamat Datang di Resto Kami / Free WiFi: sollu_guest',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.title),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // Footer Note
              TextField(
                controller: _footerController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Pesan Footer Penutup',
                  hintText: 'Contoh: Terima kasih telah berbelanja! Barang yang dibeli tidak dapat ditukar.',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.short_text),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal', style: TextStyle(color: SolluColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolluColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Simpan Pengaturan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
