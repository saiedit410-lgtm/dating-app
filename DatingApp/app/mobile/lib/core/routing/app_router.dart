import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The application's [GoRouter], exposed as a keep-alive provider so route
/// guards (added in later milestones) can react to auth/session providers.
///
/// The initial route is the [SplashScreen].
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
    ],
  );
}
