import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/auth/presentation/providers/auth_provider.dart';

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
  ConsumerState<EmployeeLoginDialog> createState() => _EmployeeLoginDialogState();
}

class _EmployeeLoginDialogState extends ConsumerState<EmployeeLoginDialog> {
  final List<Map<String, dynamic>> _dummyEmployees = [
    {'id': '1', 'name': 'Budi Santoso', 'role': 'Kasir', 'pin': '123456'},
    {'id': '2', 'name': 'Siti Rahma', 'role': 'Supervisor', 'pin': '654321'},
  ];

  Map<String, dynamic>? _selectedEmployee;
  String _errorMessage = '';

  void _verifyPin(String inputPin) {
    if (_selectedEmployee != null && inputPin == _selectedEmployee!['pin']) {
      // PIN Benar
      ref.read(activeEmployeeProvider.notifier).login(_selectedEmployee!);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: _selectedEmployee == null ? _buildEmployeeSelection() : _buildPinVerification(),
      ),
    );
  }

  Widget _buildEmployeeSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Karyawan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari nama karyawan...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            itemCount: _dummyEmployees.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final emp = _dummyEmployees[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: SolluColors.primaryLight,
                  child: Text(emp['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(emp['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(emp['role']),
                onTap: () {
                  setState(() {
                    _selectedEmployee = emp;
                    _errorMessage = '';
                  });
                },
              );
            },
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SolluColors.textDark),
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
          child: Text(_selectedEmployee!['name'][0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(_selectedEmployee!['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark)),
        Text(_selectedEmployee!['role'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void didUpdateWidget(covariant _PinSingleCharForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage.isNotEmpty && oldWidget.errorMessage != widget.errorMessage) {
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
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.primary),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? SolluColors.danger : SolluColors.neutral,
                width: hasError ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
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
            style: const TextStyle(color: SolluColors.danger, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
