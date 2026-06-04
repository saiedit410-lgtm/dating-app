import 'package:dating_app/core/routing/app_routes.dart';
import 'package:dating_app/features/chat/application/chat_providers.dart';
import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lists the user's conversations, sorted by latest activity.
class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Conversation>> async = ref.watch(
      conversationsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            const Center(child: Text('Could not load conversations.')),
        data: (List<Conversation> conversations) {
          if (conversations.isEmpty) {
            return _empty(context);
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Conversation c = conversations[index];
              return ConversationTile(
                conversation: c,
                onTap: () => context.pushNamed(
                  AppRoute.chat.routeName,
                  pathParameters: <String, String>{'uid': c.otherUid},
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
            Icons.forum_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No conversations yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Connect with someone, then start chatting here.',
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
