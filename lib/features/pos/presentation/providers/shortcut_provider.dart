import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortcutNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void trigger(String key) {
    state = key;
    Future.microtask(() => state = null);
  }
}

final shortcutProvider = NotifierProvider<ShortcutNotifier, String?>(ShortcutNotifier.new);
