import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Notifier provider to monitor connectivity state (online/offline)
class ConnectivityNotifier extends Notifier<bool> {
  final Connectivity _connectivity = Connectivity();

  @override
  bool build() {
    _init();
    return true; // Default to online until checked
  }

  Future<void> _init() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateState(result);

    // Listen for future connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      state = false; // Offline
    } else {
      state = true;  // Online (WiFi, Mobile, etc)
    }
  }
}

final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);
