import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// The first screen shown while the app boots.
///
/// Pure presentation: brand-colored background with a centered progress
/// indicator. Session/auth routing decisions are added in a later milestone —
/// this screen deliberately contains no business or backend logic.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
        ),
      ),
    );
  }
}
