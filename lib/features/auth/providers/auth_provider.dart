import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/device_info_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../data/auth_repository.dart';

// --- Dependency Providers ---

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DeviceInfoService(storage);
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final deviceInfoService = ref.watch(deviceInfoServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  
  return AuthRepository(dioClient, deviceInfoService, secureStorage);
});

// --- State Management ---

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthNotifier extends Notifier<AuthState> {
  String? errorMessage;

  @override
  AuthState build() {
    _checkInitialAuth();
    return AuthState.initial;
  }

  Future<void> _checkInitialAuth() async {
    // We delay slightly to avoid modifying state during build
    Future.microtask(() async {
      state = AuthState.loading;
      final storage = ref.read(secureStorageProvider);
      final repo = ref.read(authRepositoryProvider);
      final token = await storage.getToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, verify status
        final isValid = await repo.checkDeviceStatus();
        if (isValid) {
          state = AuthState.authenticated;
        } else {
          await repo.disconnect();
          state = AuthState.unauthenticated;
        }
      } else {
        state = AuthState.unauthenticated;
      }
    });
  }

  Future<void> connectDevice(String otp) async {
    state = AuthState.loading;
    errorMessage = null;
    try {
      final repo = ref.read(authRepositoryProvider);
      final success = await repo.connectDevice(otp);
      if (success) {
        state = AuthState.authenticated;
      } else {
        errorMessage = 'Failed to connect. Please try again.';
        state = AuthState.error;
      }
    } catch (e) {
      errorMessage = e.toString();
      state = AuthState.error;
    }
  }

  Future<void> disconnect() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.disconnect();
    state = AuthState.unauthenticated;
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
