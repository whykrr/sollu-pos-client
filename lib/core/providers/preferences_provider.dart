import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final posDisplayModeProvider = NotifierProvider<PosDisplayModeNotifier, String>(PosDisplayModeNotifier.new);

class PosDisplayModeNotifier extends Notifier<String> {
  static const _key = 'pos_display_mode';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key) ?? 'variant';
  }

  Future<void> setMode(String mode) async {
    if (mode == 'product' || mode == 'variant') {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_key, mode);
      state = mode;
    }
  }
}

final lastSyncProvider = NotifierProvider<LastSyncNotifier, DateTime?>(LastSyncNotifier.new);

class LastSyncNotifier extends Notifier<DateTime?> {
  static const _key = 'last_sync_at';

  @override
  DateTime? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored != null) {
      return DateTime.tryParse(stored);
    }
    return null;
  }

  Future<void> updateTimestamp() async {
    final now = DateTime.now();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, now.toIso8601String());
    state = now;
  }

  /// Menghasilkan teks waktu relatif yang mudah dibaca
  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return 'Belum pernah sinkronisasi';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
