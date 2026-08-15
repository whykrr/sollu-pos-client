import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/sollu_colors.dart';
import '../../../pos/presentation/providers/transaction_provider.dart';
import '../providers/payment_method_order_provider.dart';

class PaymentMethodSettingsScreen extends ConsumerStatefulWidget {
  const PaymentMethodSettingsScreen({super.key});

  @override
  ConsumerState<PaymentMethodSettingsScreen> createState() =>
      _PaymentMethodSettingsScreenState();
}

class _PaymentMethodSettingsScreenState
    extends ConsumerState<PaymentMethodSettingsScreen> {
  List<PaymentMethod>? _currentList;

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'qris':
        return Icons.qr_code_scanner;
      case 'edc':
      case 'debit':
      case 'credit':
        return Icons.credit_card;
      case 'transfer':
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (_currentList == null) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = _currentList!.removeAt(oldIndex);
      _currentList!.insert(newIndex, item);
    });

    // Otomatis simpan ke Database SQLite (local_sort_order) & SharedPreferences
    final ids = _currentList!.map((e) => e.id).toList();
    await ref.read(localPaymentMethodOrderProvider.notifier).saveOrder(ids);
  }

  Future<void> _handleReset() async {
    await ref.read(localPaymentMethodOrderProvider.notifier).resetToDefault();
    setState(() {
      _currentList = null; // will reload from default stream
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.restart_alt, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Urutan dikembalikan ke pengaturan pusat.'),
            ],
          ),
          backgroundColor: SolluColors.info,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final methodsAsync = ref.watch(activePaymentMethodsProvider);
    final customOrder = ref.watch(localPaymentMethodOrderProvider);

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran Kasir',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SolluColors.textDark,
          ),
        ),
        backgroundColor: SolluColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: SolluColors.textDark),
        actions: [
          if (customOrder.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset Urutan'),
              style: TextButton.styleFrom(
                foregroundColor: SolluColors.danger,
              ),
              onPressed: _handleReset,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: methodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Gagal memuat metode pembayaran: $err'),
        ),
        data: (methods) {
          if (methods.isEmpty) {
            return const Center(
              child: Text('Belum ada metode pembayaran aktif.'),
            );
          }

          _currentList ??= List.from(methods);

          return Column(
            children: [
              // Info Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SolluColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SolluColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: SolluColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kustomisasi Urutan Perangkat (Otomatis Tersimpan)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: SolluColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customOrder.isNotEmpty
                                ? 'Urutan di bawah tersimpan di database perangkat ini (kolom local_sort_order) dan tidak akan berubah saat sinkronisasi.'
                                : 'Saat ini urutan mengikuti aturan pusat. Tahan dan geser (drag) handle di kanan untuk mengubah urutan tampilan pada popup kasir.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolluColors.textDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Reorderable list (dengan buildDefaultDragHandles: false agar tidak terjadi duplikasi icon)
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _currentList!.length,
                  onReorder: _handleReorder,
                  itemBuilder: (context, index) {
                    final item = _currentList![index];
                    return Card(
                      key: ValueKey(item.id),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: SolluColors.neutral),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Nomor Urut
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: SolluColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: SolluColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Icon Tipe Pembayaran
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: SolluColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(item.type),
                                color: SolluColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Info Metode
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: SolluColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tipe: ${item.type.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SolluColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Single Drag Handle (Tepat di kanan, tidak bertumpuk)
                            ReorderableDragStartListener(
                              index: index,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: SolluColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.drag_indicator,
                                  color: SolluColors.neutralDark,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
