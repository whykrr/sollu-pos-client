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
    return prefs.getString(_key) ?? 'product';
  }

  Future<void> setMode(String mode) async {
    if (mode == 'product' || mode == 'variant') {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_key, mode);
      state = mode;
    }
  }
}
