import 'package:flutter/material.dart';

/// App-wide messenger key so background services (e.g. foreground push
/// handling) can show an in-app SnackBar without a widget [BuildContext].
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
