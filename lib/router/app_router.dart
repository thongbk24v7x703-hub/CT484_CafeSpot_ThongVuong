import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cafe.dart';
import '../screens/cafe_detail_screen.dart';
import '../screens/cafe_form_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shell_scaffold.dart';
import '../screens/splash_screen.dart';

CustomTransitionPage<T> _fadeSlide<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.04, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeSlide(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => _fadeSlide(
                  context: context,
                  state: state,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                pageBuilder: (context, state) => _fadeSlide(
                  context: context,
                  state: state,
                  child: const FavoritesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reviews',
                pageBuilder: (context, state) => _fadeSlide(
                  context: context,
                  state: state,
                  child: const MyReviewsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => _fadeSlide(
                  context: context,
                  state: state,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) {
          final initial = state.uri.queryParameters['q'] ?? '';
          return _fadeSlide(
            context: context,
            state: state,
            child: SearchScreen(initialQuery: initial),
          );
        },
      ),
      GoRoute(
        path: '/cafe/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _fadeSlide(
            context: context,
            state: state,
            child: CafeDetailScreen(cafeId: id),
          );
        },
      ),
      GoRoute(
        path: '/cafe-form',
        pageBuilder: (context, state) {
          final cafe = state.extra as Cafe?;
          return _fadeSlide(
            context: context,
            state: state,
            child: CafeFormScreen(cafe: cafe),
          );
        },
      ),
    ],
  );
}
