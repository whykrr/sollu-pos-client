import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';

class SupervisorChallengeDialog extends ConsumerStatefulWidget {
  final String actionTitle;
  final String requiredPermission;

  const SupervisorChallengeDialog({
    super.key,
    required this.actionTitle,
    required this.requiredPermission,
  });

  /// Helper statis untuk memanggil dialog otorisasi supervisi.
  /// Mengembalikan Map berisi status otorisasi dan identitas supervisor.
  static Future<({bool authorized, String? supervisorId, String? supervisorName})>
      authorize(
    BuildContext context, {
    required String actionTitle,
    required String requiredPermission,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SupervisorChallengeDialog(
        actionTitle: actionTitle,
        requiredPermission: requiredPermission,
      ),
    );

    if (result != null && result['authorized'] == true) {
      return (
        authorized: true,
        supervisorId: result['supervisorId'] as String?,
        supervisorName: result['supervisorName'] as String?,
      );
    }

    return (authorized: false, supervisorId: null, supervisorName: null);
  }

  @override
  ConsumerState<SupervisorChallengeDialog> createState() =>
      _SupervisorChallengeDialogState();
}

class _SupervisorChallengeDialogState
    extends ConsumerState<SupervisorChallengeDialog> {
  String _inputPin = '';
  String _errorMessage = '';
  bool _isVerifying = false;

  void _onDigitPressed(String digit) {
    if (_inputPin.length < 6) {
      setState(() {
        _inputPin += digit;
        _errorMessage = '';
      });
      if (_inputPin.length == 6) {
        _verifySupervisorPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_inputPin.isNotEmpty) {
      setState(() {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _inputPin = '';
      _errorMessage = '';
    });
  }

  bool _isAuthorizedSupervisor(Employee emp) {
    if (emp.isRootUser || emp.role == 'Akun Utama') return true;
    if (emp.permissions == null || emp.permissions!.isEmpty) return false;

    try {
      final decoded = jsonDecode(emp.permissions!);
      if (decoded is List) {
        final perms = decoded.map((e) => e.toString()).toList();
        if (perms.contains('*') || perms.contains('all')) return true;
        if (perms.contains('transaction.validation_supervision')) return true;
        if (perms.contains('transaction.*')) return true;
        if (perms.contains(widget.requiredPermission)) return true;
      }
    } catch (_) {}

    return false;
  }

  Future<void> _verifySupervisorPin() async {
    setState(() => _isVerifying = true);

    try {
      final employees = await ref.read(employeeListProvider.future);
      Employee? authorizedStaff;

      for (final emp in employees) {
        if (!_isAuthorizedSupervisor(emp)) continue;

        final storedPin = emp.pin;
        if (storedPin == null || storedPin.isEmpty) continue;

        bool isMatch = false;
        if (_inputPin == storedPin) {
          isMatch = true;
        } else {
          try {
            isMatch = BCrypt.checkpw(_inputPin, storedPin);
          } catch (_) {}
        }

        if (isMatch) {
          authorizedStaff = emp;
          break;
        }
      }

      if (authorizedStaff != null && mounted) {
        Navigator.of(context).pop({
          'authorized': true,
          'supervisorId': authorizedStaff.id,
          'supervisorName': authorizedStaff.name,
        });
      } else if (mounted) {
        setState(() {
          _errorMessage =
              'PIN salah atau staf tidak memiliki hak otorisasi supervisi!';
          _inputPin = '';
          _isVerifying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan verifikasi: $e';
          _inputPin = '';
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SolluColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SolluColors.neutral, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SolluColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: SolluColors.warning,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Otorisasi Supervisi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.textDark,
                            ),
                          ),
                          Text(
                            'Hak Akses Diperlukan',
                            style: TextStyle(
                              fontSize: 12,
                              color: SolluColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: SolluColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: SolluColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SolluColors.neutral),
                ),
                child: Text(
                  'Aksi: ${widget.actionTitle}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SolluColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // PIN Dots Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final filled = index < _inputPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? SolluColors.primary : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? SolluColors.primary
                            : SolluColors.neutralDark,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SolluColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_isVerifying)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              const SizedBox(height: 20),
              // Virtual Numpad
              _buildNumpad(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SolluColors.neutral),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal (Esc)',
                    style: TextStyle(
                      color: SolluColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          children: [
            _buildNumpadKey('1'),
            const SizedBox(width: 12),
            _buildNumpadKey('2'),
            const SizedBox(width: 12),
            _buildNumpadKey('3'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildNumpadKey('4'),
            const SizedBox(width: 12),
            _buildNumpadKey('5'),
            const SizedBox(width: 12),
            _buildNumpadKey('6'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildNumpadKey('7'),
            const SizedBox(width: 12),
            _buildNumpadKey('8'),
            const SizedBox(width: 12),
            _buildNumpadKey('9'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActionKey(
              icon: Icons.clear_all,
              label: 'C',
              onPressed: _onClearPressed,
            ),
            const SizedBox(width: 12),
            _buildNumpadKey('0'),
            const SizedBox(width: 12),
            _buildActionKey(
              icon: Icons.backspace_outlined,
              label: '⌫',
              onPressed: _onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadKey(String digit) {
    return Expanded(
      child: Material(
        color: SolluColors.background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _onDigitPressed(digit),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SolluColors.neutral, width: 1.2),
            ),
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Material(
        color: SolluColors.background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SolluColors.neutral, width: 1.2),
            ),
            child: Icon(icon, color: SolluColors.neutralDark, size: 22),
          ),
        ),
      ),
    );
  }
}
