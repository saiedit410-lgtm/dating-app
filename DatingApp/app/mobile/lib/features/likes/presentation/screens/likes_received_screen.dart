import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/connections/presentation/widgets/user_list_tile.dart';
import 'package:dating_app/features/likes/application/likes_providers.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Likes the signed-in user has received.
///
/// Renders a leading "match" pill when the like is mutual (the
/// receiver has also liked the sender back). Tapping a row opens
/// the sender's profile.
class LikesReceivedScreen extends ConsumerWidget {
  const LikesReceivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    final AsyncValue<List<dynamic>> async = ref.watch(receivedLikesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Likes received')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load likes.')),
        data: (List<dynamic> likes) {
          if (likes.isEmpty || me == null) return _empty(context);
          final Set<String> blocked =
              ref.watch(blockedUidsProvider).value ?? const <String>{};
          final List<dynamic> visible = likes
              .where((dynamic l) => !blocked.contains(l.fromUid as String))
              .toList();
          if (visible.isEmpty) return _empty(context);
          return ListView.separated(
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final dynamic like = visible[index];
              final String fromUid = like.fromUid as String;
              final bool mutual = ref
                  .watch(hasLikedOtherProvider(fromUid))
                  .value ==
                  true;
              return UserListTile(
                uid: fromUid,
                trailing: mutual
                    ? FilledButton.tonal(
                        onPressed: () => context.pushNamed(
                          AppRoute.chat.routeName,
                          pathParameters: <String, String>{'uid': fromUid},
                        ),
                        child: const Text('Match'),
                      )
                    : const Icon(Icons.favorite, color: Colors.pink),
                onTap: () => context.pushNamed(
                  AppRoute.profileDetail.routeName,
                  pathParameters: <String, String>{'uid': fromUid},
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.favorite_border,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No likes yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "When someone likes you, they'll show up here.",
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
