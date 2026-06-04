import 'dart:async';

import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/chat/application/chat_providers.dart';
import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/chat/domain/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

enum ChatStatus { loading, loaded, error }

/// State for one conversation's message window.
class ChatState {
  const ChatState({
    this.messages = const <Message>[],
    this.status = ChatStatus.loading,
    this.hasMore = false,
    this.isSending = false,
  });

  /// Newest-first (rendered in a reversed list view).
  final List<Message> messages;
  final ChatStatus status;
  final bool hasMore;
  final bool isSending;

  ChatState copyWith({
    List<Message>? messages,
    ChatStatus? status,
    bool? hasMore,
    bool? isSending,
  }) => ChatState(
    messages: messages ?? this.messages,
    status: status ?? this.status,
    hasMore: hasMore ?? this.hasMore,
    isSending: isSending ?? this.isSending,
  );
}

/// Streams the most-recent message window for a conversation (realtime) and
/// grows the window to page in older messages. Keyed by the other user's uid.
@riverpod
class ChatController extends _$ChatController {
  static const int _page = 30;

  StreamSubscription<List<Message>>? _sub;
  int _limit = _page;
  String _conversationId = '';
  String _me = '';

  @override
  ChatState build(String otherUid) {
    ref.onDispose(() => _sub?.cancel());
    final String? me = ref.read(authStateChangesProvider).value?.uid;
    if (me == null) return const ChatState(status: ChatStatus.error);
    _me = me;
    _conversationId = ConversationId.between(me, otherUid);
    unawaited(_init(otherUid));
    return const ChatState();
  }

  Future<void> _init(String otherUid) async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .ensureConversation(me: _me, otherUid: otherUid);
    } catch (_) {
      // Non-fatal: the message stream below still attaches.
    }
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = ref
        .read(chatRepositoryProvider)
        .watchMessages(_conversationId, limit: _limit)
        .listen(
          (List<Message> messages) {
            state = state.copyWith(
              messages: messages,
              status: ChatStatus.loaded,
              hasMore: messages.length >= _limit,
            );
          },
          onError: (_) => state = state.copyWith(status: ChatStatus.error),
        );
  }

  /// Grows the streamed window to load older messages.
  void loadMore() {
    if (!state.hasMore) return;
    _limit += _page;
    _listen();
  }

  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;
    state = state.copyWith(isSending: true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            conversationId: _conversationId,
            senderId: _me,
            text: trimmed,
          );
    } catch (_) {
      // Surface via the screen if needed; keep state consistent regardless.
    }
    state = state.copyWith(isSending: false);
  }
}
