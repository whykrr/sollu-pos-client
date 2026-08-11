import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  bool _isStorageReady = false;

  SecureStorageService() : _storage = const FlutterSecureStorage(
    mOptions: MacOsOptions(
      usesDataProtectionKeychain: false,
    ),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyDeviceUuid = 'device_uuid';
  static const String _keyHardwareSignature = 'hardware_signature';

  // Ensure storage is accessible, handle incompatible model configurations
  Future<void> _ensureReady() async {
    if (_isStorageReady) return;
    try {
      await _storage.read(key: 'dummy_check_key');
      _isStorageReady = true;
    } on PlatformException catch (e) {
      if (e.message != null && e.message!.contains('model configuration')) {
        await _storage.deleteAll();
      }
      _isStorageReady = true;
    } catch (e) {
      try {
        await _storage.deleteAll();
      } catch (_) {}
      _isStorageReady = true;
    }
  }

  // Token
  Future<void> saveToken(String token) async {
    await _ensureReady();
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    await _ensureReady();
    return await _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _ensureReady();
    await _storage.delete(key: _keyToken);
  }

  // Device UUID
  Future<void> saveDeviceUuid(String uuid) async {
    await _ensureReady();
    await _storage.write(key: _keyDeviceUuid, value: uuid);
  }

  Future<String?> getDeviceUuid() async {
    await _ensureReady();
    return await _storage.read(key: _keyDeviceUuid);
  }

  // Hardware Signature
  Future<void> saveHardwareSignature(String signature) async {
    await _ensureReady();
    await _storage.write(key: _keyHardwareSignature, value: signature);
  }

  Future<String?> getHardwareSignature() async {
    await _ensureReady();
    return await _storage.read(key: _keyHardwareSignature);
  }
  
  // Clear all
  Future<void> clearAll() async {
    await _ensureReady();
    await _storage.deleteAll();
  }
}
