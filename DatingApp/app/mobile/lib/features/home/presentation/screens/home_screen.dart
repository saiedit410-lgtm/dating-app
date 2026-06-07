import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Authenticated landing screen.
///
/// Temporary home for the authenticated session - replaced by the discovery
/// experience in a later milestone. Confirms the signed-in identity and offers
/// logout so the full auth lifecycle is exercisable end to end.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final isAdmin = ref.watch(isCurrentUserAdminProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spark'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 64,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text("You're signed in", style: context.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                user?.phoneNumber ?? '',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.discovery.routeName),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Discover people'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.requests.routeName),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Requests'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.connections.routeName),
                icon: const Icon(Icons.people_outline),
                label: const Text('Connections'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.chats.routeName),
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Messages'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.pushNamed(AppRoute.photos.routeName),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Manage photos'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.verification.routeName),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Get verified'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.likesReceived.routeName),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Likes received'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.likesSent.routeName),
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Likes sent'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.pushNamed(AppRoute.recentVisitors.routeName),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Recent visitors'),
              ),
              if (isAdmin) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => context.pushNamed(AppRoute.admin.routeName),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Admin console'),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
