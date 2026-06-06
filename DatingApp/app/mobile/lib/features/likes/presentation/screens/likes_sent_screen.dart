import 'package:dating_app/features/connections/presentation/widgets/user_list_tile.dart';
import 'package:dating_app/features/likes/application/likes_providers.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Likes the signed-in user has sent. Read-only feed.
class LikesSentScreen extends ConsumerWidget {
  const LikesSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<dynamic>> async = ref.watch(sentLikesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Likes sent')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load likes.')),
        data: (List<dynamic> likes) {
          if (likes.isEmpty) return _empty(context);
          return ListView.separated(
            itemCount: likes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) =>
                UserListTile(uid: likes[index].toUid as String),
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
          Text('No likes sent yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap Like on a profile to break the ice.',
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
