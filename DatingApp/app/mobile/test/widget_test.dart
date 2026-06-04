// Auth + onboarding route-guard tests.
//
// These exercise the real GoRouter guard by overriding the coarse startup
// stage (and the providers each destination screen reads) — no Firebase, no
// business-logic mocks.

import 'package:dating_app/app.dart';
import 'package:dating_app/core/routing/app_startup.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:dating_app/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:dating_app/features/home/presentation/screens/home_screen.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:dating_app/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const AuthUser _user = AuthUser(uid: 'test-uid', phoneNumber: '+919999999999');

Future<void> _pump(WidgetTester tester, ProviderScope app) async {
  await tester.pumpWidget(app);
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed-out user is routed to the phone login screen', (
    tester,
  ) async {
    await _pump(
      tester,
      ProviderScope(
        overrides: [
          appStartupStageProvider.overrideWith(
            (ref) => AppStartupStage.loggedOut,
          ),
        ],
        child: const DatingApp(),
      ),
    );
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
  });

  testWidgets('signed-in user without a complete profile sees onboarding', (
    tester,
  ) async {
    await _pump(
      tester,
      ProviderScope(
        overrides: [
          appStartupStageProvider.overrideWith(
            (ref) => AppStartupStage.onboarding,
          ),
          currentUserProfileProvider.overrideWith(
            (ref) =>
                Stream<UserProfile?>.value(const UserProfile(uid: 'test-uid')),
          ),
        ],
        child: const DatingApp(),
      ),
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Create your profile'), findsOneWidget);
  });

  testWidgets('signed-in user with a complete profile sees home', (
    tester,
  ) async {
    await _pump(
      tester,
      ProviderScope(
        overrides: [
          appStartupStageProvider.overrideWith((ref) => AppStartupStage.ready),
          authStateChangesProvider.overrideWith(
            (ref) => Stream<AuthUser?>.value(_user),
          ),
        ],
        child: const DatingApp(),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
