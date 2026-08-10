import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/pos/presentation/pos_layout.dart';

void main() {
  runApp(const ProviderScope(child: SolluPosApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PosLayout(),
    ),
  ],
);

class SolluPosApp extends ConsumerWidget {
  const SolluPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Sollu POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) {
        return _GlobalShortcutWrapper(child: child!);
      },
    );
  }
}

class _GlobalShortcutWrapper extends StatelessWidget {
  final Widget child;

  const _GlobalShortcutWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f1): const PosIntent('F1'),
        LogicalKeySet(LogicalKeyboardKey.f2): const PosIntent('F2'),
        LogicalKeySet(LogicalKeyboardKey.f3): const PosIntent('F3'),
        LogicalKeySet(LogicalKeyboardKey.f4): const PosIntent('F4'),
        LogicalKeySet(LogicalKeyboardKey.f8): const PosIntent('F8'),
        LogicalKeySet(LogicalKeyboardKey.f12): const PosIntent('F12'),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PosIntent: CallbackAction<PosIntent>(
            onInvoke: (PosIntent intent) {
              debugPrint('Shortcut trigger: ${intent.shortcut}');
              // TODO: dispatch shortcut actions via Riverpod or global keys
              return null;
            },
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

class PosIntent extends Intent {
  final String shortcut;
  const PosIntent(this.shortcut);
}
