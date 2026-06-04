/// Deterministic conversation id for a pair of users (sorted, symmetric).
/// Intentionally identical to the connection id so the two line up 1:1.
class ConversationId {
  const ConversationId._();

  static String between(String uidA, String uidB) {
    final List<String> ids = <String>[uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}

/// A 1:1 conversation (`conversations/{conversationId}`). Stores participant
/// uid references + a denormalized last-message summary for the list screen.
/// Firestore mapping lives in the data layer (this stays Firebase-free).
class Conversation {
  const Conversation({
    required this.id,
    required this.otherUid,
    this.lastMessageText,
    this.lastMessageAt,
  });

  final String id;
  final String otherUid;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
}
