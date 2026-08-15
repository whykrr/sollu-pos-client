import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextInputFormatter yang secara otomatis memformat input angka
/// dengan titik pemisah ribuan (format Indonesia).
///
/// Contoh: 15000 → 15.000, 1500000 → 1.500.000
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hanya ambil digit
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse ke integer
    final int? value = int.tryParse(digitsOnly);
    if (value == null) {
      return oldValue;
    }

    // Format dengan titik pemisah ribuan
    final String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Helper statis untuk parse string terformat kembali ke angka.
  /// Menghapus semua karakter non-digit sebelum parsing.
  static double parse(String formattedText) {
    final digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digitsOnly) ?? 0.0;
  }

  /// Helper statis untuk format angka menjadi string dengan titik pemisah.
  static String format(int value) {
    return NumberFormat.decimalPattern('id_ID').format(value);
  }
}
