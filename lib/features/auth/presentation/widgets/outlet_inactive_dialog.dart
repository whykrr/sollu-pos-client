import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/providers/auth_provider.dart';

class OutletInactiveDialog extends ConsumerStatefulWidget {
  final String? message;

  const OutletInactiveDialog({
    super.key,
    this.message,
  });

  static bool isShowing = false;

  static Future<void> show(BuildContext context, {String? message}) async {
    if (isShowing) return;
    isShowing = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OutletInactiveDialog(message: message),
      );
    } finally {
      isShowing = false;
    }
  }

  @override
  ConsumerState<OutletInactiveDialog> createState() => _OutletInactiveDialogState();
}

class _OutletInactiveDialogState extends ConsumerState<OutletInactiveDialog> {
  bool _isChecking = false;
  String? _errorMessage;

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final isOnlineAndActive = await repo.checkDeviceStatus();

      if (!mounted) return;

      if (isOnlineAndActive) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cabang outlet telah aktif kembali. Kasir siap digunakan.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: SolluColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Cabang masih berstatus nonaktif. Silakan pastikan pemilik usaha telah mengaktifkan cabang ini pada Pengaturan Outlet di web.';
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memeriksa status cabang: ${e.toString().replaceFirst('Exception: ', '')}';
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = widget.message ??
        'Cabang outlet ini sedang dinonaktifkan oleh pemilik usaha. Silakan aktifkan cabang pada menu Pengaturan Outlet untuk melanjutkan transaksi kasir.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: SolluColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: SolluColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cabang Dinonaktifkan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              'Koneksi Kasir Dikunci',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Server Message
                Text(
                  displayMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: SolluColors.textDark,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Step by Step Guidance Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: SolluColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Panduan Pengaktifan Kembali:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStepRow('1', 'Buka dashboard web pemilik usaha.'),
                      const SizedBox(height: 4),
                      _buildStepRow('2', 'Masuk ke menu Pengaturan > Outlet.'),
                      const SizedBox(height: 4),
                      _buildStepRow('3', 'Aktifkan kembali saklar status cabang ini.'),
                      const SizedBox(height: 4),
                      _buildStepRow('4', 'Tekan tombol Periksa Status di bawah ini.'),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isChecking
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                context.go('/login');
                              },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          foregroundColor: SolluColors.textMuted,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keluar Sesi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : _checkStatus,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 18),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Periksa Status',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: SolluColors.textDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: SolluColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
