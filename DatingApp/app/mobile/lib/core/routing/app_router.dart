import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:dating_app/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:dating_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:dating_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The application's [GoRouter] with auth-aware route guards.
///
/// Reacts to [authStateChangesProvider]:
///  * session still resolving  -> Splash
///  * signed out               -> Login (and the OTP step)
///  * signed in                -> Home
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      final bool inAuthFlow =
          location == AppRoute.login.path || location == AppRoute.otp.path;

      // Persisted session is still being restored: hold on the splash screen.
      if (authState.isLoading) {
        return location == AppRoute.splash.path ? null : AppRoute.splash.path;
      }

      final bool loggedIn = authState.value != null;

      if (!loggedIn) {
        return inAuthFlow ? null : AppRoute.login.path;
      }

      // Signed in: keep users out of the splash/auth screens.
      if (location == AppRoute.splash.path || inAuthFlow) {
        return AppRoute.home.path;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
    ],
  );
}
