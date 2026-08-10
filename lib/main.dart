import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/routing/app_router.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/shortcut_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SolluPosApp()));
}

class SolluPosApp extends ConsumerWidget {
  const SolluPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return _GlobalShortcutWrapper(
      child: MaterialApp.router(
        title: 'Sollu POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: SolluColors.primary,
            primary: SolluColors.primary,
            secondary: SolluColors.secondary,
            background: SolluColors.background,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          scaffoldBackgroundColor: SolluColors.background,
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          } else if (logicalKey == LogicalKeyboardKey.f8) {
            ref.read(shortcutProvider.notifier).trigger('F8');
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.f10) {
            ref.read(shortcutProvider.notifier).trigger('F10');
            return KeyEventResult.handled;
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
