import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';

class EmployeeLoginDialog extends ConsumerStatefulWidget {
  const EmployeeLoginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const EmployeeLoginDialog(),
    );
  }

  @override
  ConsumerState<EmployeeLoginDialog> createState() =>
      _EmployeeLoginDialogState();
}

class _EmployeeLoginDialogState extends ConsumerState<EmployeeLoginDialog> {
  Employee? _selectedEmployee;
  String _errorMessage = '';
  bool _isSyncing = false;

  bool _isValidPin(String inputPin, String? storedPin) {
    if (storedPin == null || storedPin.isEmpty) return false;
    // Fast check if plain match
    if (inputPin == storedPin) return true;
    try {
      return BCrypt.checkpw(inputPin, storedPin);
    } catch (_) {
      return false;
    }
  }

  void _verifyPin(String inputPin) {
    final storedPin = _selectedEmployee?.pin;
    if (_selectedEmployee != null && _isValidPin(inputPin, storedPin)) {
      // PIN Benar
      final mapEmployee = {
        'id': _selectedEmployee!.id,
        'name': _selectedEmployee!.name,
        'role': _selectedEmployee!.role ?? 'Kasir',
      };
      ref.read(activeEmployeeProvider.notifier).login(mapEmployee);
      Navigator.of(context).pop();
    } else {
      // PIN Salah
      setState(() {
        _errorMessage = 'PIN tidak valid!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 420,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: _selectedEmployee == null
            ? _buildEmployeeSelection()
            : _buildPinVerification(),
      ),
    );
  }

  Widget _buildEmployeeSelection() {
    final employeesAsync = ref.watch(employeeListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Karyawan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: _isSyncing
                    ? null
                    : () async {
                        setState(() {
                          _isSyncing = true;
                        });
                        try {
                          await ref.read(employeeRepositoryProvider).syncEmployees();
                          ref.invalidate(employeeListProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        } finally {
                          setState(() {
                            _isSyncing = false;
                          });
                        }
                      },
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: const Text('Load Karyawan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama karyawan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: employeesAsync.when(
            data: (employees) {
              if (employees.isEmpty) {
                return const Center(child: Text('Tidak ada data karyawan. Klik Load Karyawan.'));
              }
              return ListView.separated(
                itemCount: employees.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: SolluColors.primaryLight,
                      child: Text(
                        emp.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      emp.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(emp.role ?? 'Kasir'),
                    onTap: () {
                      setState(() {
                        _selectedEmployee = emp;
                        _errorMessage = '';
                      });
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildPinVerification() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedEmployee = null;
                  _errorMessage = '';
                });
              },
            ),
            const Expanded(
              child: Text(
                'Masukkan PIN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48), // Balancing back button
          ],
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 32,
          backgroundColor: SolluColors.primary,
          child: Text(
            _selectedEmployee!.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedEmployee!.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: SolluColors.textDark,
          ),
        ),
        Text(
          _selectedEmployee!.role ?? 'Kasir',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 28),

        // Single Character PIN Input (6 Boxes)
        _PinSingleCharForm(
          errorMessage: _errorMessage,
          onCompleted: (pin) {
            _verifyPin(pin);
          },
        ),

        const SizedBox(height: 12),
      ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 6; i++) ...[
              _buildSingleBox(i),
              if (i < 5) const SizedBox(width: 8),
            ],
          ],
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
          ),
        ],
      ],
    );
  }
}
