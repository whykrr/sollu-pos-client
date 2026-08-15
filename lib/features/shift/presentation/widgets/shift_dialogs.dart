import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/theme/sollu_spacing.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/shift/data/shift_repository.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

class OpenShiftDialog extends ConsumerStatefulWidget {
  const OpenShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Wajib diisi sebelum mulai kasir
      builder: (context) => const OpenShiftDialog(),
    );
  }

  @override
  ConsumerState<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends ConsumerState<OpenShiftDialog> {
  final TextEditingController _cashController = TextEditingController();
  String? _selectedEmployeeId;
  bool _isLoading = false;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cashText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final openingCash = double.tryParse(cashText) ?? 0.0;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(shiftRepositoryProvider);
      await repository.openShift(
        openingCash: openingCash,
        userId: _selectedEmployeeId ?? 'default-cashier',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shift berhasil dibuka dengan kas awal ${CurrencyFormatter.format(openingCash.toInt())}',
            ),
            backgroundColor: SolluColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka shift: $e'),
            backgroundColor: SolluColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SolluColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: SolluColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Buka Shift Kasir',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: SolluColors.textDark,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silakan pilih kasir yang bertugas dan masukkan modal awal (kas) di laci untuk memulai shift.',
              style: TextStyle(color: SolluColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Pilihan Karyawan Kasir
            const Text(
              'Kasir yang Bertugas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) {
                  return const Text(
                    'Kasir Default',
                    style: TextStyle(color: SolluColors.textMuted),
                  );
                }
                _selectedEmployeeId ??= employees.first.id;

                return DropdownButtonFormField<String>(
                  initialValue: _selectedEmployeeId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: employees.map((emp) {
                    return DropdownMenuItem(
                      value: emp.id,
                      child: Text('${emp.name} (${emp.role ?? "Kasir"})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedEmployeeId = val;
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Kasir Default',
                style: TextStyle(color: SolluColors.textMuted),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Modal Awal (Kas di Laci)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SolluColors.primary,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                contentPadding: SolluSpacing.inputPadding,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                  context.go('/dashboard');
                },
          icon: const Icon(
            Icons.dashboard_outlined,
            size: 16,
            color: SolluColors.textMuted,
          ),
          label: const Text(
            'Kembali ke Dashboard',
            style: TextStyle(
              color: SolluColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Mulai Shift'),
        ),
      ],
    );
  }
}

class CloseShiftDialog extends ConsumerStatefulWidget {
  const CloseShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CloseShiftDialog(),
    );
  }

  @override
  ConsumerState<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends ConsumerState<CloseShiftDialog> {
  final TextEditingController _actualCashController = TextEditingController();
  bool _isLoading = false;
  double _actualCash = 0.0;

  @override
  void initState() {
    super.initState();
    _actualCashController.addListener(() {
      final text = _actualCashController.text.replaceAll(RegExp(r'[^0-9]'), '');
      setState(() {
        _actualCash = double.tryParse(text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  Future<void> _submitCloseShift(Shift shift, ShiftSummary summary) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(shiftRepositoryProvider);
      await repository.closeShift(
        shiftId: shift.id,
        closingCash: _actualCash,
        expectedCash: summary.expectedCash,
        totalSales: summary.totalSales,
      );

      if (mounted) {
        Navigator.of(context).pop();
        context.go('/dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift berhasil ditutup! Laporan shift tercatat.'),
            backgroundColor: SolluColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menutup shift: $e'),
            backgroundColor: SolluColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeShiftAsync = ref.watch(activeShiftProvider);

    return activeShiftAsync.when(
      data: (shift) {
        if (shift == null) {
          return AlertDialog(
            title: const Text('Tutup Shift (F12)'),
            content: const Text('Tidak ada shift yang sedang aktif.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          );
        }

        final summaryAsync = ref.watch(shiftSummaryProvider(shift.id));

        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SolluColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: SolluColors.danger,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tutup Shift Kasir (F12)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: summaryAsync.when(
              data: (summary) {
                final double variance = _actualCash - summary.expectedCash;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(
                        'Modal Awal',
                        CurrencyFormatter.format(summary.openingCash.toInt()),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        'Total Penjualan Tunai',
                        CurrencyFormatter.format(summary.cashSales.toInt()),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        'Total Penjualan Non-Tunai',
                        CurrencyFormatter.format(summary.nonCashSales.toInt()),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        'Kas Masuk/Keluar',
                        CurrencyFormatter.format(
                          (summary.cashIn - summary.cashOut).toInt(),
                        ),
                      ),
                      const Divider(height: 24, color: SolluColors.neutral),
                      _SummaryRow(
                        'Ekspektasi Kas di Laci',
                        CurrencyFormatter.format(summary.expectedCash.toInt()),
                        isBold: true,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kas Aktual di Laci',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SolluColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _actualCashController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: SolluColors.primary,
                        ),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          hintText: '0',
                          contentPadding: SolluSpacing.inputPadding,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selisih Kas:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: SolluColors.textDark,
                            ),
                          ),
                          Text(
                            variance == 0
                                ? 'Rp 0 (Pas)'
                                : (variance > 0
                                      ? '+${CurrencyFormatter.format(variance.toInt())} (Lebih)'
                                      : '${CurrencyFormatter.format(variance.toInt())} (Kurang)'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: variance == 0
                                  ? SolluColors.success
                                  : (variance > 0
                                        ? SolluColors.warning
                                        : SolluColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Error kalkulasi: $err'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal (Esc)',
                style: TextStyle(color: SolluColors.textMuted),
              ),
            ),
            summaryAsync.maybeWhen(
              data: (summary) => ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _submitCloseShift(shift, summary),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolluColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Akhiri Shift & Rekonsiliasi'),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        );
      },
      loading: () => const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => AlertDialog(content: Text('Error: $err')),
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
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? SolluColors.primary : SolluColors.textDark,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
