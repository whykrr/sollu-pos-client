import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global Hardware Barcode Scanner Interceptor (Keyboard Wedge)
/// Mendukung scanner fisik USB/Bluetooth HID di Windows, macOS, dan Android.
/// Membedakan ketikan manual kasir dengan burst scan berkecepatan tinggi (<50ms).
class HardwareScannerListener extends StatefulWidget {
  final Widget child;
  final ValueChanged<String> onBarcodeScanned;
  final bool enabled;

  const HardwareScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.enabled = true,
  });

  @override
  State<HardwareScannerListener> createState() =>
      _HardwareScannerListenerState();
}

class _HardwareScannerListenerState extends State<HardwareScannerListener> {
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeystrokeTime;

  /// Ambang batas interval waktu antar karakter untuk barcode scanner hardware (< 50ms)
  static const Duration _maxScannerInterval = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    super.dispose();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (!widget.enabled) return false;
    if (event is! KeyDownEvent) return false;

    final now = DateTime.now();

    // 1. Deteksi Tombol Enter (Akhir Pembacaan Barcode)
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_buffer.length >= 3) {
        // Cek apakah jeda karakter terakhir masih dalam batas wajar scanner
        if (_lastKeystrokeTime != null &&
            now.difference(_lastKeystrokeTime!) <= const Duration(milliseconds: 100)) {
          final barcode = _buffer.toString().trim();
          _buffer.clear();
          _lastKeystrokeTime = null;

          if (barcode.isNotEmpty) {
            widget.onBarcodeScanned(barcode);
            return true; // Intercept event agar tidak memicu tombol lain
          }
        }
      }
      _buffer.clear();
      _lastKeystrokeTime = null;
      return false;
    }

    // 2. Abaikan tombol-tombol pintasan fungsi (F1-F12, Esc, Ctrl, Alt, Arrow, dll)
    if (_isControlKey(event.logicalKey)) {
      _buffer.clear();
      _lastKeystrokeTime = null;
      return false;
    }

    // 3. Karakter Printable
    final character = event.character;
    if (character != null && character.isNotEmpty) {
      // Jika jeda antar karakter sebelumnya terlalu lama (> 50ms), reset buffer (ini ketikan manual kasir)
      if (_lastKeystrokeTime != null) {
        final elapsed = now.difference(_lastKeystrokeTime!);
        if (elapsed > _maxScannerInterval) {
          _buffer.clear();
        }
      }

      _buffer.write(character);
      _lastKeystrokeTime = now;
    }

    return false;
  }

  bool _isControlKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.f1 ||
        key == LogicalKeyboardKey.f2 ||
        key == LogicalKeyboardKey.f3 ||
        key == LogicalKeyboardKey.f4 ||
        key == LogicalKeyboardKey.f5 ||
        key == LogicalKeyboardKey.f6 ||
        key == LogicalKeyboardKey.f7 ||
        key == LogicalKeyboardKey.f8 ||
        key == LogicalKeyboardKey.f9 ||
        key == LogicalKeyboardKey.f10 ||
        key == LogicalKeyboardKey.f11 ||
        key == LogicalKeyboardKey.f12 ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.tab ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight ||
        key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
