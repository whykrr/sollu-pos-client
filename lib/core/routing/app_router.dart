import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sollu_pos_app/features/auth/presentation/pages/login_screen.dart';
import 'package:sollu_pos_app/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:sollu_pos_app/features/pos/presentation/pages/pos_layout.dart';
import 'package:sollu_pos_app/features/history/presentation/pages/history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
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
    ],
  );
});
