import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Centralized Application Configuration & Semantic Versioning
/// Loads properties from .env file, PackageInfo, and compile-time --dart-define.
class AppConfig {
  static PackageInfo? _packageInfo;

  /// Initialize dotenv and PackageInfo. Call this in main() before runApp().
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Info: .env file not found or could not be loaded ($e). Using default environment values.");
    }

    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint("Info: Could not load PackageInfo ($e). Using fallback version info.");
    }
  }

  /// PackageInfo instance (null if not initialized or on unsupported mock tests)
  static PackageInfo? get packageInfo => _packageInfo;

  /// Nama Aplikasi
  static String get appName {
    final envName = dotenv.env['APP_NAME'];
    if (envName != null && envName.isNotEmpty) return envName;
    if (_packageInfo != null && _packageInfo!.appName.isNotEmpty) {
      return _packageInfo!.appName;
    }
    return const String.fromEnvironment('APP_NAME', defaultValue: 'Sollu POS Client');
  }

  /// Package Name / Bundle ID (misal: com.sollu.pos)
  static String get packageName => _packageInfo?.packageName ?? 'com.sollu.pos_client';

  /// Semantic Version Name (misal: 1.0.0)
  static String get appVersion {
    if (_packageInfo != null && _packageInfo!.version.isNotEmpty) {
      return _packageInfo!.version;
    }
    return dotenv.env['APP_VERSION'] ??
        const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  }

  /// Build Number / Version Code (misal: 1)
  static String get buildNumber {
    if (_packageInfo != null && _packageInfo!.buildNumber.isNotEmpty) {
      return _packageInfo!.buildNumber;
    }
    return dotenv.env['BUILD_NUMBER'] ??
        const String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  }

  /// Full SemVer String (misal: "v1.0.0 (1)")
  static String get fullVersionString => 'v$appVersion ($buildNumber)';

  /// Environment Name (development, staging, production)
  static String get appEnv =>
      dotenv.env['APP_ENV'] ??
      const String.fromEnvironment('APP_ENV', defaultValue: 'development');

  /// Base URL API Backend POS
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://dashboard.sollu.test/api/pos',
      );

  /// Batas waktu koneksi ke API (detik)
  static int get connectTimeoutSeconds =>
      int.tryParse(dotenv.env['CONNECT_TIMEOUT_SECONDS'] ?? '') ??
      const int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 30);

  /// Batas waktu penerimaan data dari API (detik)
  static int get receiveTimeoutSeconds =>
      int.tryParse(dotenv.env['RECEIVE_TIMEOUT_SECONDS'] ?? '') ??
      const int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 30);

  /// Mengaktifkan logging request/response HTTP Dio
  static bool get enableLogging {
    final envVal = dotenv.env['ENABLE_LOGGING'];
    if (envVal != null) {
      return envVal.toLowerCase() == 'true';
    }
    return const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
  }

  /// Cek apakah berjalan di environment production
  static bool get isProduction => appEnv.toLowerCase() == 'production';
}
