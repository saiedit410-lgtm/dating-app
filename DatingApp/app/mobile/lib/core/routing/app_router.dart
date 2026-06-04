import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/core/routing/app_startup.dart';
import 'package:dating_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:dating_app/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:dating_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:dating_app/features/home/presentation/screens/home_screen.dart';
import 'package:dating_app/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The application's [GoRouter] with auth + onboarding aware route guards.
///
/// Reacts to [appStartupStageProvider] (a coarse enum), so the router only
/// rebuilds when the routing decision changes — not on every profile edit:
///  * loading   -> Splash
///  * loggedOut -> Login / OTP
///  * onboarding-> Onboarding
///  * ready      -> Home
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final AppStartupStage stage = ref.watch(appStartupStageProvider);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final String loc = state.matchedLocation;

      switch (stage) {
        case AppStartupStage.loading:
          return loc == AppRoute.splash.path ? null : AppRoute.splash.path;
        case AppStartupStage.loggedOut:
          final bool inAuthFlow =
              loc == AppRoute.login.path || loc == AppRoute.otp.path;
          return inAuthFlow ? null : AppRoute.login.path;
        case AppStartupStage.onboarding:
          return loc == AppRoute.onboarding.path
              ? null
              : AppRoute.onboarding.path;
        case AppStartupStage.ready:
          return loc == AppRoute.home.path ? null : AppRoute.home.path;
      }
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
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
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
