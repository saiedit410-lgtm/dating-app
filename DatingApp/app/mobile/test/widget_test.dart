// App boot smoke test.
//
// Verifies the real app boots through GoRouter into the SplashScreen and shows
// a progress indicator. No mocks: the actual providers (env, logger, router)
// run. We use `pump()` (not `pumpAndSettle()`) because the splash spinner
// animates indefinitely.

import 'package:dating_app/app.dart';
import 'package:dating_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots into SplashScreen with a progress indicator', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DatingApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
