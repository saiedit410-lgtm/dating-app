/// A chat message (`conversations/{id}/messages/{messageId}`).
///
/// Text-only for this phase. `editedAt`/`deletedAt` exist in the schema for
/// later edit/delete support but are not yet written by the UI.
class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.editedAt,
    this.deletedAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
}
