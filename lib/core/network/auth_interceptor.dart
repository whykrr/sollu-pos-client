import 'package:dio/dio.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    final deviceUuid = await _storage.getDeviceUuid();
    final hardwareSignature = await _storage.getHardwareSignature();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (deviceUuid != null && deviceUuid.isNotEmpty) {
      options.headers['X-DEVICE-UUID'] = deviceUuid;
    }

    if (hardwareSignature != null && hardwareSignature.isNotEmpty) {
      options.headers['X-HARDWARE-SIGNATURE'] = hardwareSignature;
    }

    super.onRequest(options, handler);
  }
}
