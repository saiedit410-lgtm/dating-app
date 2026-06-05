import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/chat/application/chat_controller.dart';
import 'package:dating_app/features/chat/domain/message.dart';
import 'package:dating_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/safety/application/safety_providers.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Realtime 1:1 chat with a connected user.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.otherUid});

  final String otherUid;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _input.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Reversed list: the top (older messages) is at maxScrollExtent.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(chatControllerProvider(widget.otherUid).notifier).loadMore();
    }
  }

  void _send() {
    final String text = _input.text;
    if (text.trim().isEmpty) return;
    ref.read(chatControllerProvider(widget.otherUid).notifier).send(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String? me = ref.watch(authStateChangesProvider).value?.uid;
    final ChatState state = ref.watch(chatControllerProvider(widget.otherUid));
    final String title =
        ref.watch(profileByIdProvider(widget.otherUid)).value?.displayName ??
        'Chat';

    final bool isBlocked = (ref
            .watch(blockedUidsProvider)
            .value ??
        const <String>{}).contains(widget.otherUid);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _messages(state, me)),
            if (isBlocked) _blockedBar() else _composer(state),
          ],
        ),
      ),
    );
  }

  Widget _blockedBar() => Material(
    color: context.colorScheme.surfaceContainerHighest,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Icon(Icons.block, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This conversation is unavailable.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _messages(ChatState state, String? me) {
    if (state.status == ChatStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ChatStatus.error) {
      return const Center(child: Text('Could not load this conversation.'));
    }
    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          'Say hi 👋',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.messages.length + (state.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final Message message = state.messages[index];
        return MessageBubble(message: message, isMine: message.senderId == me);
      },
    );
  }

  Widget _composer(ChatState state) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: state.isSending ? null : _send,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
