import 'package:flutter/material.dart';

/// Convenience accessors on [BuildContext] for the most-used theme objects,
/// reducing `Theme.of(context)` noise across the UI.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
