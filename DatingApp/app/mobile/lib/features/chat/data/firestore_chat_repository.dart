import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/chat/domain/chat_repository.dart';
import 'package:dating_app/features/chat/domain/conversation.dart';
import 'package:dating_app/features/chat/domain/message.dart';

/// Firestore implementation over `conversations/{id}` and the
/// `conversations/{id}/messages` subcollection.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) =>
      _conversations.doc(conversationId).collection('messages');

  @override
  Stream<List<Conversation>> watchConversations(String me) => _conversations
      .where('participants', arrayContains: me)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  _toConversation(d, me),
            )
            .toList(),
      );

  @override
  Future<void> ensureConversation({
    required String me,
    required String otherUid,
  }) async {
    final String id = ConversationId.between(me, otherUid);
    final DocumentReference<Map<String, dynamic>> ref = _conversations.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    if (snap.exists) return;
    await ref.set(<String, Object?>{
      'participants': <String>[me, otherUid]..sort(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageText': null,
      'lastMessageSenderId': null,
    });
  }

  @override
  Stream<List<Message>> watchMessages(
    String conversationId, {
    int limit = 30,
  }) => _messages(conversationId)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) =>
            snap.docs.map(_toMessage).toList(),
      );

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final DocumentReference<Map<String, dynamic>> conversationRef =
        _conversations.doc(conversationId);
    final DocumentReference<Map<String, dynamic>> messageRef =
        _messages(conversationId).doc();

    final WriteBatch batch = _firestore.batch();
    batch.set(messageRef, <String, Object?>{
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'editedAt': null,
      'deletedAt': null,
    });
    batch.update(conversationRef, <String, Object?>{
      'lastMessageText': text,
      'lastMessageSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Conversation _toConversation(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String me,
  ) {
    final Map<String, dynamic> data = doc.data();
    final List<String> participants =
        ((data['participants'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toList();
    return Conversation(
      id: doc.id,
      otherUid: participants.firstWhere(
        (String u) => u != me,
        orElse: () => '',
      ),
      lastMessageText: data['lastMessageText'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  Message _toMessage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return Message(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }
}
