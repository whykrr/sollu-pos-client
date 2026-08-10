import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveEmployeeNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() {
    return null;
  }

  void login(Map<String, dynamic> employee) {
    state = employee;
  }

  void logout() {
    state = null;
  }
}

final activeEmployeeProvider = NotifierProvider<ActiveEmployeeNotifier, Map<String, dynamic>?>(
  ActiveEmployeeNotifier.new,
);
