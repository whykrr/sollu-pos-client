import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/device_info_service.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthRepository {
  final DioClient _dioClient;
  final DeviceInfoService _deviceInfoService;
  final SecureStorageService _secureStorage;

  AuthRepository(this._dioClient, this._deviceInfoService, this._secureStorage);

  /// Pair device using OTP
  Future<bool> connectDevice(String otp) async {
    try {
      final deviceUuid = await _deviceInfoService.getOrCreateDeviceUuid();
      final hardwareSignature = await _deviceInfoService.getOrCreateHardwareSignature();
      final appVersion = await _deviceInfoService.getAppVersion();
      final platformType = _deviceInfoService.getPlatformType();

      final response = await _dioClient.dio.post(
        '/device/connect',
        data: {
          'otp': otp,
          'device_uuid': deviceUuid,
          'hardware_fingerprint': hardwareSignature,
          'app_version': appVersion,
          'platform_type': platformType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['token'] != null) {
          // Save the token returned by the server
          await _secureStorage.saveToken(data['token']);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      throw Exception('Failed to connect device: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Check if the device is still connected/valid
  Future<bool> checkDeviceStatus() async {
    try {
      final appVersion = await _deviceInfoService.getAppVersion();
      final platformType = _deviceInfoService.getPlatformType();
      
      final response = await _dioClient.dio.get(
        '/device/status',
        queryParameters: {
          'app_version': appVersion,
          'platform_type': platformType,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Disconnect/Logout device
  Future<void> disconnect() async {
    await _secureStorage.clearAll();
  }
}
