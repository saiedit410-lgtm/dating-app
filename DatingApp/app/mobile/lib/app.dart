import 'package:dating_app/core/config/env_config.dart';
import 'package:dating_app/core/notifications/root_messenger.dart';
import 'package:dating_app/core/routing/app_router.dart';
import 'package:dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
///
/// Wires the GoRouter configuration and the Material 3 themes. It holds no
/// business logic — feature behaviour lives inside each feature module.
class DatingApp extends ConsumerWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final env = ref.watch(envConfigProvider);

    return MaterialApp.router(
      title: env.appName,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
