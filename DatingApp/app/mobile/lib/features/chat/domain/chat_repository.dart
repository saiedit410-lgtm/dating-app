import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/chat/domain/message.dart';

/// Reads/writes conversations and messages. Implemented by Firestore.
abstract interface class ChatRepository {
  /// Live list of the user's conversations, most-recent activity first.
  Stream<List<Conversation>> watchConversations(String me);

  /// Creates the conversation for [me] + [otherUid] if it doesn't exist yet
  /// (idempotent). Safe to call when opening a chat.
  Future<void> ensureConversation({
    required String me,
    required String otherUid,
  });

  /// Live window of the most recent [limit] messages (newest first) for
  /// realtime updates + pagination (grow [limit] to load older).
  Stream<List<Message>> watchMessages(String conversationId, {int limit});

  /// Sends a text message and updates the conversation's last-message summary.
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });
}
