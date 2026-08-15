import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sollu_pos_client/features/auth/presentation/pages/splash_screen.dart';
import 'package:sollu_pos_client/features/auth/presentation/pages/login_screen.dart';
import 'package:sollu_pos_client/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sollu_pos_client/features/pos/presentation/pages/pos_layout.dart';
import 'package:sollu_pos_client/features/history/presentation/pages/history_screen.dart';

import 'package:sollu_pos_client/features/settings/presentation/pages/settings_screen.dart';
import 'package:sollu_pos_client/features/settings/presentation/pages/printer_settings_screen.dart';
import 'package:sollu_pos_client/features/settings/presentation/pages/payment_method_settings_screen.dart';
import 'package:sollu_pos_client/features/pos/presentation/pages/products_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/pos',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PosLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        routes: [
          GoRoute(
            path: 'printer',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PrinterSettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: 'payment-methods',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PaymentMethodSettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProductsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
});
