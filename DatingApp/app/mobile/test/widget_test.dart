// Auth route-guard tests.
//
// These exercise the real GoRouter guard by overriding only the auth state
// stream (no Firebase, no mocks of business logic): signed-out users land on
// the phone login screen; signed-in users land on home.

import 'package:dating_app/app.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:dating_app/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:dating_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester, Stream<AuthUser?> authStream) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateChangesProvider.overrideWith((ref) => authStream),
      ],
      child: const DatingApp(),
    ),
  );
  // Let the stream emit and the guard redirect settle.
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed-out user is routed to the phone login screen', (
    tester,
  ) async {
    await _pumpApp(tester, Stream<AuthUser?>.value(null));
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('signed-in user is routed to the home screen', (tester) async {
    await _pumpApp(
      tester,
      Stream<AuthUser?>.value(
        const AuthUser(uid: 'test-uid', phoneNumber: '+919999999999'),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(PhoneLoginScreen), findsNothing);
  });
}
