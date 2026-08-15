import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';

class ErrorLoggingService {
  final DioClient _dioClient;

  ErrorLoggingService(this._dioClient);

  Future<void> logError(dynamic exception, StackTrace? stackTrace) async {
    // Only forward logs to Discord if running in release mode
    if (!kReleaseMode) {
      debugPrint('ErrorLoggingService: Not in release mode, ignoring error log.');
      debugPrint('Exception: $exception');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      return;
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      Map<String, dynamic> deviceData = {};
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      final payload = {
        'error': exception.toString(),
        'stack_trace': stackTrace?.toString(),
        'device_info': deviceData,
        'app_version': '${packageInfo.version} (${packageInfo.buildNumber})',
      };

      await _dioClient.dio.post(
        '/pos/logs/error',
        data: payload,
      );
    } catch (e) {
      // Failed to send error log, avoid infinite loop
      debugPrint('Failed to send error log to backend: $e');
    }
  }
}
