import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  /// URL Appcast XML di Cloudflare R2
  static const String _feedUrl = 'https://YOUR_R2_DOMAIN/appcast.xml';

  Future<void> initialize() async {
    if (kIsWeb) return;
    
    // Auto updater saat ini mendukung macOS dan Windows
    if (!Platform.isMacOS && !Platform.isWindows) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      String feedUrl = _feedUrl;
      // Opsional: Anda bisa mengirimkan versi saat ini ke URL feed
      // jika server Anda membutuhkan untuk analitik atau hal lain.
      // feedUrl = '$_feedUrl?v=$currentVersion';

      await autoUpdater.setFeedURL(feedUrl);
      
      debugPrint('UpdateService initialized with Feed URL: $feedUrl (Current Version: $currentVersion)');
    } catch (e) {
      debugPrint('UpdateService initialization failed: $e');
    }
  }

  /// Cek pembaruan di latar belakang tanpa menghentikan aktivitas pengguna (Non-blocking).
  /// Hanya akan memunculkan dialog/jendela (WinSparkle) jika ada versi baru, 
  /// atau jika update ditandai sebagai critical.
  Future<void> checkInBackground() async {
    if (kIsWeb) return;
    if (!Platform.isMacOS && !Platform.isWindows) return;

    try {
      debugPrint('UpdateService: Checking for updates in background...');
      await autoUpdater.checkForUpdatesWithoutUI();
    } catch (e) {
      debugPrint('UpdateService background check failed: $e');
    }
  }

  /// Cek pembaruan secara manual. Akan memunculkan dialog WinSparkle 
  /// meskipun tidak ada update (misal: "You are up to date!").
  Future<void> checkManually() async {
    if (kIsWeb) return;
    if (!Platform.isMacOS && !Platform.isWindows) return;

    try {
      debugPrint('UpdateService: Checking for updates manually...');
      await autoUpdater.checkForUpdates();
    } catch (e) {
      debugPrint('UpdateService manual check failed: $e');
    }
  }
}
