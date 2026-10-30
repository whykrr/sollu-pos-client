import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';

/// Mode operasional antarmuka kasir POS Sollu
enum PosMode {
  /// Fast Retail: Layar dominan tabel keranjang belanja lebar, barcode selalu auto-fokus,
  /// dialog katalog lookup (F1), dan full keyboard-driven checkout tanpa mouse.
  fastRetail('fast_retail', 'Fast Retail (Barcode/Keyboard)'),

  /// Visual Touch: Layar sentuh F&B / Kafe dengan kategori sidebar, kartu produk grid,
  /// dan panel keranjang ringkas.
  visualTouch('visual_touch', 'Visual Touch (Grid/Kategori)');

  final String code;
  final String label;
  const PosMode(this.code, this.label);

  static PosMode fromCode(String? code) {
    if (code == 'fast_retail') return PosMode.fastRetail;
    if (code == 'visual_touch') return PosMode.visualTouch;
    return detectAdaptiveDefault();
  }

  /// Deteksi otomatis adaptif berdasarkan form factor dan platform:
  /// - Desktop (macOS, Windows, Linux) atau layar besar landscape (width >= 1024) -> Fast Retail
  /// - Mobile / Tablet -> Visual Touch
  static PosMode detectAdaptiveDefault() {
    // 1. Cek Desktop Platform
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return PosMode.fastRetail;
    }

    // 2. Cek Viewport Size (Layar besar landscape >= 1024px)
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final view = views.first;
        final pixelRatio = view.devicePixelRatio > 0 ? view.devicePixelRatio : 1.0;
        final logicalWidth = view.physicalSize.width / pixelRatio;
        final logicalHeight = view.physicalSize.height / pixelRatio;

        if (logicalWidth >= 1024 && logicalWidth > logicalHeight) {
          return PosMode.fastRetail;
        }
      }
    } catch (e) {
      debugPrint('[PosMode] Viewport detection error: $e');
    }

    // 3. Default untuk Mobile / Tablet
    return PosMode.visualTouch;
  }
}

class PosModeNotifier extends Notifier<PosMode> {
  static const String storageKey = 'user_pos_mode_preference';

  @override
  PosMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(storageKey);

    if (savedCode != null && savedCode.isNotEmpty) {
      if (savedCode == 'fast_retail') return PosMode.fastRetail;
      if (savedCode == 'visual_touch') return PosMode.visualTouch;
    }

    return PosMode.detectAdaptiveDefault();
  }

  /// Ubah mode POS dan simpan preferensi kasir secara persisten di SharedPreferences
  Future<void> setMode(PosMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(storageKey, mode.code);
    state = mode;
  }

  /// Beralih antara Fast Retail dan Visual Touch
  Future<void> toggleMode() async {
    final nextMode = state == PosMode.fastRetail
        ? PosMode.visualTouch
        : PosMode.fastRetail;
    await setMode(nextMode);
  }

  /// Reset ke deteksi otomatis platform
  Future<void> resetToAuto() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(storageKey);
    state = PosMode.detectAdaptiveDefault();
  }

  /// Mengecek apakah kasir telah melakukan override manual
  bool get hasManualOverride {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.containsKey(storageKey);
  }
}

/// Provider utama untuk mode operasional POS
final posModeProvider = NotifierProvider<PosModeNotifier, PosMode>(
  PosModeNotifier.new,
);

/// Helper boolean provider untuk mengecek apakah sedang dalam mode Fast Retail
final isFastRetailProvider = Provider<bool>((ref) {
  return ref.watch(posModeProvider) == PosMode.fastRetail;
});
