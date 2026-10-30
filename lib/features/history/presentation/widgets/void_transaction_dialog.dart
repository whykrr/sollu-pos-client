import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/sollu_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pos/presentation/providers/transaction_provider.dart';
import '../../../pos/presentation/widgets/supervisor_challenge_dialog.dart';

class VoidTransactionDialog extends ConsumerStatefulWidget {
  final Transaction transaction;

  const VoidTransactionDialog({
    super.key,
    required this.transaction,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Transaction transaction,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoidTransactionDialog(transaction: transaction),
    );
  }

  @override
  ConsumerState<VoidTransactionDialog> createState() =>
      _VoidTransactionDialogState();
}

class _VoidTransactionDialogState extends ConsumerState<VoidTransactionDialog> {
  static const List<String> _presetReasons = [
    'Salah input item',
    'Pelanggan membatalkan',
    'Kendala pembayaran',
    'Lainnya',
  ];

  late String _selectedReason;
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = _presetReasons.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmVoid() async {
    if (_selectedReason == 'Lainnya' && _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan catatan untuk alasan lainnya.'),
          backgroundColor: SolluColors.warning,
        ),
      );
      return;
    }

    final activeEmployee = ref.read(activeEmployeeProvider);
    final isSupervisor = activeEmployee?.isSupervisor() ?? false;
    final hasDirectVoidPerm = activeEmployee?.hasPermission('transaction.void') ?? false;

    String? supervisorId;
    String? supervisorName;
    String? supervisorPin;

    if (!isSupervisor && !hasDirectVoidPerm) {
      // Perlu otorisasi supervisor jika kasir tidak memiliki izin void
      final authResult = await SupervisorChallengeDialog.authorize(
        context,
        actionTitle: 'Otorisasi Void Transaksi',
        requiredPermission: 'transaction.void',
      );

      if (!authResult.authorized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Otorisasi supervisor dibatalkan atau ditolak.'),
              backgroundColor: SolluColors.warning,
            ),
          );
        }
        return;
      }

      supervisorId = authResult.supervisorId;
      supervisorName = authResult.supervisorName;
      supervisorPin = authResult.pin;
    } else {
      supervisorId = activeEmployee?['id']?.toString();
      supervisorName = activeEmployee?['name']?.toString();
    }

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final result = await repo.voidTransaction(
        transactionId: widget.transaction.id,
        reason: _selectedReason,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : (supervisorName != null ? 'Disetujui oleh: $supervisorName' : null),
        supervisorId: supervisorId,
        supervisorPin: supervisorPin,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: SolluColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: SolluColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat membatalkan transaksi: $e'),
            backgroundColor: SolluColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SolluColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: SolluColors.danger,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Void Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Transaksi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'No. Transaksi',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolluColors.textMuted,
                          ),
                        ),
                        Text(
                          widget.transaction.transactionNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SolluColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Nominal',
                          style: TextStyle(
                            fontSize: 12,
                            color: SolluColors.textMuted,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(widget.transaction.total.toInt()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: SolluColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Peringatan
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SolluColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SolluColors.danger.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: SolluColors.danger,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembatalan transaksi tidak dapat dikembalikan. Status akan diubah menjadi VOID.',
                        style: TextStyle(
                          fontSize: 12,
                          color: SolluColors.danger,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Alasan Void Dropdown
              const Text(
                'Alasan Pembatalan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedReason,
                    items: _presetReasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: SolluColors.textDark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedReason = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Catatan Tambahan TextField
              const Text(
                'Catatan Tambahan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _selectedReason == 'Lainnya'
                      ? 'Wajib diisi untuk alasan lainnya...'
                      : 'Opsional: keterangan lebih detail...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: SolluColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SolluColors.neutral),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SolluColors.neutral),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: SolluColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        OutlinedButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: SolluColors.textMuted,
            side: const BorderSide(color: SolluColors.neutral),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _handleConfirmVoid,
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.danger,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Konfirmasi Void',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
