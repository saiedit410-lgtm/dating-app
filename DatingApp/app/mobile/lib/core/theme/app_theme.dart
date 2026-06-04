import 'package:dating_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Builds the application's Material 3 themes.
///
/// This is intentionally a thin foundation seeded from the brand color. The
/// full design system (typography scale, spacing tokens, component themes,
/// loading/empty/error patterns) defined in `docs/DesignSystem.md` is layered
/// in during the design-system milestone via `ThemeExtension`s.
abstract final class AppTheme {
  /// Light theme (default).
  static ThemeData light() => _build(Brightness.light);

  /// Dark theme — shipped from day one per the design system.
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandRose,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
