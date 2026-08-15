import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sollu_pos_client/core/config/app_config.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/routing/app_router.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:ui';
import 'package:sollu_pos_client/core/providers/error_logging_provider.dart';

import 'package:sollu_pos_client/core/services/window_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  final sharedPreferences = await SharedPreferences.getInstance();
  
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  // Inisialisasi Window Manager pada Desktop (Windows/macOS/Linux)
  final isKiosk = container.read(fullscreenKioskProvider);
  await WindowService.initialize(isKiosk: isKiosk);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    container.read(errorLoggingServiceProvider).logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    container.read(errorLoggingServiceProvider).logError(error, stack);
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SolluPosApp(),
    ),
  );
}

class SolluPosApp extends ConsumerWidget {
  const SolluPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return _GlobalShortcutWrapper(
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: SolluColors.primary,
            primary: SolluColors.primary,
            secondary: SolluColors.secondary,
            surface: SolluColors.background,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          scaffoldBackgroundColor: SolluColors.background,
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SolluColors.neutral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SolluColors.primary, width: 2),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            actionsPadding: const EdgeInsets.all(24),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: SolluColors.textDark,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _GlobalShortcutWrapper extends ConsumerWidget {
  final Widget child;

  const _GlobalShortcutWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          final primaryFocus = FocusManager.instance.primaryFocus;
          final isTextFieldFocused = primaryFocus?.context?.widget is EditableText;
          
          if (isTextFieldFocused) {
            return KeyEventResult.ignored;
          }

          final logicalKey = event.logicalKey;
          
          if (logicalKey == LogicalKeyboardKey.f1) {
            ref.read(shortcutProvider.notifier).trigger('F1');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f2) {
            ref.read(shortcutProvider.notifier).trigger('F2');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f3) {
            ref.read(shortcutProvider.notifier).trigger('F3');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f4) {
            ref.read(shortcutProvider.notifier).trigger('F4');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f5) {
            ref.read(shortcutProvider.notifier).trigger('F5');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f6) {
            ref.read(shortcutProvider.notifier).trigger('F6');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f7) {
            ref.read(shortcutProvider.notifier).trigger('F7');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f8) {
            ref.read(shortcutProvider.notifier).trigger('F8');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f9) {
            ref.read(shortcutProvider.notifier).trigger('F9');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f10) {
            ref.read(shortcutProvider.notifier).trigger('F10');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f11) {
            if (WindowService.isDesktop) {
              WindowService.toggleFullScreen().then((isFullScreen) {
                ref.read(fullscreenKioskProvider.notifier).toggleKiosk(isFullScreen);
              });
              return KeyEventResult.handled;
            }
          } else if (logicalKey == LogicalKeyboardKey.f12) {
            ref.read(shortcutProvider.notifier).trigger('F12');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.escape) {
            ref.read(shortcutProvider.notifier).trigger('ESC');
            return KeyEventResult.ignored; // Let dialogs handle escape naturally
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
