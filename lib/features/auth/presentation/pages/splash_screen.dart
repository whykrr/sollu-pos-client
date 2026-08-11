import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the auth state to determine routing
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        context.go('/dashboard');
      } else if (next == AuthState.unauthenticated || next == AuthState.error) {
        context.go('/login');
      }
    });

    return Scaffold(
      backgroundColor: SolluColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'img/logo-white.png',
              width: 200,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
