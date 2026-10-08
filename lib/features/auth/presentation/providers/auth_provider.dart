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

final activeEmployeeProvider =
    NotifierProvider<ActiveEmployeeNotifier, Map<String, dynamic>?>(
      ActiveEmployeeNotifier.new,
    );

extension ActiveEmployeePermissions on Map<String, dynamic> {
  bool get isRootUser =>
      this['is_root_user'] == true ||
      (this['role'] ?? '').toString().toLowerCase() == 'akun utama';

  List<String> get permissions {
    final raw = this['permissions'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  bool hasPermission(String permission) {
    if (isRootUser) {
      return true;
    }

    final perms = permissions;
    if (perms.contains('*') || perms.contains('all')) {
      return true;
    }
    if (perms.contains(permission)) {
      return true;
    }
    for (final perm in perms) {
      if (perm.endsWith('.*')) {
        final prefix = perm.substring(0, perm.length - 2);
        if (permission == prefix || permission.startsWith('$prefix.')) {
          return true;
        }
      }
    }
    return false;
  }

  /// Memeriksa apakah user memiliki hak akses pengelolaan perangkat ('setting.device' atau wildcard)
  bool hasDevicePermission() {
    return hasPermission('setting.device');
  }

  /// Memeriksa hak akses pengawas / supervisor / otorisator berbasis hak akses eksplisit.
  /// Decoupled dari nama peran dinamis sesuai PRD V1.2 Bab 8.2 & 9.2.
  bool isSupervisor() {
    return isRootUser ||
        hasPermission('transaction.validation_supervision') ||
        hasPermission('transaction.*') ||
        hasPermission('*') ||
        hasPermission('all');
  }
}
