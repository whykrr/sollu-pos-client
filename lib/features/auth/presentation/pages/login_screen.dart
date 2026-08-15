import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _otpCode = '';

  void _verifyOtp(String otp) {
    setState(() {
      _otpCode = otp;
    });
    ref.read(authNotifierProvider.notifier).connectDevice(otp);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState == AuthState.loading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        context.go('/dashboard');
      } else if (next == AuthState.error) {
        final error = ref.read(authNotifierProvider.notifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal menghubungkan perangkat.'),
            backgroundColor: SolluColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: SolluColors.background,
      body: Stack(
          children: [
            Center(
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: SolluColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('img/logo-colored.png', width: 180),
                    const SizedBox(height: 24),
                    const Text(
                      'Hubungkan Perangkat',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masukkan 8-digit OTP dari Dashboard Outlet Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SolluColors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 36),
                    
                    // Single Character OTP Form ____-____
                    _OtpSingleCharForm(
                      onCompleted: (otp) {
                        if (!isLoading) {
                          _verifyOtp(otp);
                        }
                      },
                    ),

                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_otpCode.length == 8 && !isLoading) ? () => _verifyOtp(_otpCode) : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: SolluColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Hubungkan Perangkat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _OtpSingleCharForm extends StatefulWidget {
  final Function(String) onCompleted;

  const _OtpSingleCharForm({required this.onCompleted});

  @override
  State<_OtpSingleCharForm> createState() => _OtpSingleCharFormState();
}

class _OtpSingleCharFormState extends State<_OtpSingleCharForm> {
  final List<TextEditingController> _controllers = List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(8, (_) => FocusNode());

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
      if (index < 7) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 8) {
      widget.onCompleted(otp);
    }
  }

  Widget _buildSingleBox(int index) {
    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SolluColors.primary),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SolluColors.neutral, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SolluColors.primary, width: 2),
            ),
          ),
          onChanged: (val) => _onChanged(index, val),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 4; i++) ...[
          _buildSingleBox(i),
          if (i < 3) const SizedBox(width: 6),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('-', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: SolluColors.neutralDark)),
        ),
        for (int i = 4; i < 8; i++) ...[
          _buildSingleBox(i),
          if (i < 7) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
