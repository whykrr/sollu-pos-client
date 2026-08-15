import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage_service.dart';

class DeviceInfoService {
  final SecureStorageService _storage;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  DeviceInfoService(this._storage);

  /// Get or create Device UUID
  Future<String> getOrCreateDeviceUuid() async {
    String? uuid = await _storage.getDeviceUuid();
    if (uuid == null) {
      uuid = const Uuid().v4();
      await _storage.saveDeviceUuid(uuid);
    }
    return uuid;
  }

  /// Get or create Hardware Signature (SHA-256)
  Future<String> getOrCreateHardwareSignature() async {
    String? signature = await _storage.getHardwareSignature();
    if (signature == null) {
      signature = await _generateHardwareSignature();
      await _storage.saveHardwareSignature(signature);
    }
    return signature;
  }

  Future<String> _generateHardwareSignature() async {
    String hardwareData = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        hardwareData = '${androidInfo.board}-${androidInfo.model}-${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        hardwareData = iosInfo.identifierForVendor ?? '';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfoPlugin.windowsInfo;
        hardwareData = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfoPlugin.macOsInfo;
        hardwareData = macOsInfo.systemGUID ?? '';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        hardwareData = linuxInfo.machineId ?? '';
      } else {
        hardwareData = 'unknown-device-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      hardwareData = 'fallback-device-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Fallback if hardware data is somehow empty
    if (hardwareData.isEmpty || hardwareData == 'null-null-null') {
       hardwareData = 'fallback-device-${DateTime.now().millisecondsSinceEpoch}';
    }

    final bytes = utf8.encode(hardwareData);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// Get App Version
  Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get Platform Type
  String getPlatformType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
