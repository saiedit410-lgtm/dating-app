import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/shared/widgets/verified_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A conversation row: other user's photo + name, last message, and time.
class ConversationTile extends ConsumerWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PublicProfile?> async = ref.watch(
      profileByIdProvider(conversation.otherUid),
    );
    final PublicProfile? profile = async.value;
    final String name = profile?.displayName ?? 'Someone';
    final String? url = profile?.primaryPhotoUrl;
    final String subtitle = conversation.lastMessageText ?? 'Say hi 👋';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
        child: url == null ? const Icon(Icons.person_outline) : null,
      ),
      title: Row(
        children: <Widget>[
          Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          if (profile?.isVerified ?? false) ...<Widget>[
            const SizedBox(width: 4),
            const VerifiedBadge(size: 16),
          ],
        ],
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: conversation.lastMessageAt == null
          ? null
          : Text(formatClock(conversation.lastMessageAt!)),
      onTap: onTap,
    );
  }
}
