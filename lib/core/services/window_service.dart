import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Inisialisasi window manager saat startup jika berjalan di platform Desktop
  static Future<void> initialize({bool isKiosk = false}) async {
    if (!isDesktop) return;

    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(1280, 720),
        minimumSize: Size(1024, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        if (isKiosk) {
          await windowManager.setFullScreen(true);
        }
      });
    } catch (e) {
      debugPrint('[WindowService] Gagal menginisialisasi window manager: $e');
    }
  }

  /// Aktifkan atau nonaktifkan mode Fullscreen Kiosk
  static Future<void> setKioskMode(bool enabled) async {
    if (!isDesktop) return;

    try {
      if (enabled) {
        await windowManager.setFullScreen(true);
      } else {
        await windowManager.setFullScreen(false);
      }
    } catch (e) {
      debugPrint('[WindowService] Gagal mengubah mode kiosk: $e');
    }
  }

  /// Toggle fullscreen
  static Future<bool> toggleFullScreen() async {
    if (!isDesktop) return false;

    try {
      final isFullScreen = await windowManager.isFullScreen();
      await windowManager.setFullScreen(!isFullScreen);
      return !isFullScreen;
    } catch (e) {
      debugPrint('[WindowService] Gagal toggle fullscreen: $e');
      return false;
    }
  }

  /// Cek apakah jendela saat ini dalam mode fullscreen
  static Future<bool> isFullScreen() async {
    if (!isDesktop) return false;
    try {
      return await windowManager.isFullScreen();
    } catch (_) {
      return false;
    }
  }
}
