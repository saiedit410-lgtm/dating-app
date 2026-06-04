import 'package:flutter/material.dart';

/// Brand seed colors sourced from `docs/DesignSystem.md`.
///
/// Only the seeds needed to generate the Material 3 [ColorScheme] live here.
/// The full token set (neutrals, status, spacing, typography) is integrated in
/// a dedicated design-system milestone.
abstract final class AppColors {
  /// Primary brand color — warm rose (`brand/primary`).
  static const Color brandRose = Color(0xFFE94E77);

  /// Secondary accent — violet (`brand/secondary`).
  static const Color brandViolet = Color(0xFF6C5CE7);

  /// Reserved exclusively for the verified badge (`trust/verified`).
  static const Color trustBlue = Color(0xFF1E88E5);
}
