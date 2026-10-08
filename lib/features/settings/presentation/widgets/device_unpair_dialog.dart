import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart' as auth_pres;

class DeviceUnpairDialog extends ConsumerStatefulWidget {
  const DeviceUnpairDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeviceUnpairDialog(),
    );
  }

  @override
  ConsumerState<DeviceUnpairDialog> createState() => _DeviceUnpairDialogState();
}

class _DeviceUnpairDialogState extends ConsumerState<DeviceUnpairDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidPin(String inputPin, String? storedPin) {
    if (storedPin == null || storedPin.isEmpty) return false;
    if (inputPin == storedPin) return true;
    try {
      return BCrypt.checkpw(inputPin, storedPin);
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleUnpair(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activeEmployee = ref.read(auth_pres.activeEmployeeProvider);
      if (activeEmployee == null) {
        throw Exception('Sesi pengguna tidak ditemukan.');
      }

      final hasPermission =
          auth_pres.ActiveEmployeePermissions(activeEmployee)
              .hasPermission('setting.device');

      if (!hasPermission) {
        throw Exception('Anda tidak memiliki hak akses pengelolaan perangkat.');
      }

      // 1. Validasi PIN lokal terhadap user yang sedang login
      final database = ref.read(databaseProvider);
      final activeUserId = (activeEmployee['id'] ?? '').toString();
      final currentEmp = await (database.select(database.employees)
            ..where((tbl) => tbl.id.equals(activeUserId)))
          .getSingleOrNull();

      if (currentEmp == null || !_isValidPin(pin, currentEmp.pin)) {
        throw Exception('PIN yang Anda masukkan salah.');
      }

      // 2. Unpair ke backend dengan identitas user terverifikasi (tanpa mengirimkan PIN)
      await ref
          .read(authNotifierProvider.notifier)
          .unpairDevice(userId: activeUserId);

      // 3. Clear sesi login user
      ref.read(auth_pres.activeEmployeeProvider.notifier).logout();

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        context.go('/login'); // Redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Koneksi perangkat berhasil diputuskan.'),
              ],
            ),
            backgroundColor: SolluColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEmployee = ref.watch(auth_pres.activeEmployeeProvider);
    final bool isAuthorized = activeEmployee != null &&
        auth_pres.ActiveEmployeePermissions(activeEmployee)
            .hasPermission('setting.device');

    if (!isAuthorized) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: SolluColors.danger,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Akses Ditolak',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  activeEmployee == null
                      ? 'Silakan masuk dengan akun yang memiliki hak akses pengelolaan perangkat.'
                      : 'Akun Anda (${activeEmployee['name']}) tidak memiliki hak akses pengelolaan perangkat.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SolluColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolluColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final employeeName = (activeEmployee['name'] ?? 'Pengguna').toString();
    final employeeRole = (activeEmployee['role'] ?? 'Kasir').toString();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SolluColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    color: SolluColors.danger,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Putuskan Hubungan Perangkat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SolluColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Otorisasi: $employeeName ($employeeRole)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SolluColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Warning Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Memutuskan perangkat ini akan menghapus seluruh data lokal kasir dan sesi login. Masukkan PIN akun Anda untuk memproses tindakan ini.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PIN Input Field
            Center(
              child: Text(
                'Masukkan PIN $employeeName',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SolluColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _PinSingleCharForm(
                    errorMessage: _errorMessage ?? '',
                    onCompleted: (pin) {
                      _handleUnpair(pin);
                    },
                  ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    minimumSize: const Size(64, 48),
                    foregroundColor: SolluColors.textMuted,
                  ),
                  child: const Text('Batal'),
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

class _PinSingleCharForm extends StatefulWidget {
  final Function(String) onCompleted;
  final String errorMessage;

  const _PinSingleCharForm({
    required this.onCompleted,
    required this.errorMessage,
  });

  @override
  State<_PinSingleCharForm> createState() => _PinSingleCharFormState();
}

class _PinSingleCharFormState extends State<_PinSingleCharForm> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PinSingleCharForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage.isNotEmpty &&
        oldWidget.errorMessage != widget.errorMessage) {
      for (var c in _controllers) {
        c.clear();
      }
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == 6) {
      widget.onCompleted(pin);
    }
  }

  Widget _buildSingleBox(int index) {
    final hasError = widget.errorMessage.isNotEmpty;
    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          obscureText: true,
          obscuringCharacter: '•',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: SolluColors.primary,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? SolluColors.danger : SolluColors.neutral,
                width: hasError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? SolluColors.danger : SolluColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (val) => _onChanged(index, val),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 6; i++) ...[
                _buildSingleBox(i),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        if (widget.errorMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.errorMessage,
            style: const TextStyle(
              color: SolluColors.danger,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
