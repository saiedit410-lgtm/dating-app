import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/connections/domain/connection.dart';
import 'package:dating_app/features/connections/domain/connection_repository.dart';
import 'package:dating_app/features/connections/domain/friend_request.dart';

/// Firestore implementation over `friendRequests/{from}_{to}` and
/// `connections/{sortedPair}`.
class FirestoreConnectionRepository implements ConnectionRepository {
  FirestoreConnectionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('friendRequests');
  CollectionReference<Map<String, dynamic>> get _connections =>
      _firestore.collection('connections');

  @override
  Future<RelationshipState> relationshipBetween(String me, String other) async {
    final DocumentSnapshot<Map<String, dynamic>> connection = await _connections
        .doc(ConnectionIds.connection(me, other))
        .get();
    if (connection.exists) return RelationshipState.connected;

    final DocumentSnapshot<Map<String, dynamic>> sent = await _requests
        .doc(ConnectionIds.request(me, other))
        .get();
    final RequestStatus? sentStatus = RequestStatus.fromName(
      sent.data()?['status'] as String?,
    );
    if (sentStatus == RequestStatus.accepted) return RelationshipState.connected;
    if (sentStatus == RequestStatus.pending) {
      return RelationshipState.requestSent;
    }

    final DocumentSnapshot<Map<String, dynamic>> received = await _requests
        .doc(ConnectionIds.request(other, me))
        .get();
    final RequestStatus? receivedStatus = RequestStatus.fromName(
      received.data()?['status'] as String?,
    );
    if (receivedStatus == RequestStatus.accepted) {
      return RelationshipState.connected;
    }
    if (receivedStatus == RequestStatus.pending) {
      return RelationshipState.requestReceived;
    }

    return RelationshipState.notConnected;
  }

  @override
  Future<void> sendRequest({
    required String fromUid,
    required String toUid,
  }) {
    // set() handles both first send (create) and re-send after reject/cancel
    // (update) — governed by the corresponding security rules.
    return _requests.doc(ConnectionIds.request(fromUid, toUid)).set(
      <String, Object?>{
        'fromUid': fromUid,
        'toUid': toUid,
        'status': RequestStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
      },
    );
  }

  @override
  Future<void> cancelRequest({
    required String fromUid,
    required String toUid,
  }) => _requests.doc(ConnectionIds.request(fromUid, toUid)).update(
    <String, Object?>{
      'status': RequestStatus.cancelled.name,
      'respondedAt': FieldValue.serverTimestamp(),
    },
  );

  @override
  Future<void> rejectRequest({
    required String fromUid,
    required String toUid,
  }) => _requests.doc(ConnectionIds.request(fromUid, toUid)).update(
    <String, Object?>{
      'status': RequestStatus.rejected.name,
      'respondedAt': FieldValue.serverTimestamp(),
    },
  );

  @override
  Future<void> acceptRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final String requestId = ConnectionIds.request(fromUid, toUid);
    final WriteBatch batch = _firestore.batch();
    batch.update(_requests.doc(requestId), <String, Object?>{
      'status': RequestStatus.accepted.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
    final String pairId = ConnectionIds.connection(fromUid, toUid);
    batch.set(_connections.doc(pairId), <String, Object?>{
      'users': <String>[fromUid, toUid]..sort(),
      'requestId': requestId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Auto-create the conversation (deterministic id == connection id) so the
    // pair can chat immediately. Verified in rules via the pending request.
    batch.set(
      _firestore.collection('conversations').doc(pairId),
      <String, Object?>{
        'participants': <String>[fromUid, toUid]..sort(),
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageText': null,
        'lastMessageSenderId': null,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Stream<List<FriendRequest>> watchIncomingRequests(String me) => _requests
      .where('toUid', isEqualTo: me)
      .where('status', isEqualTo: RequestStatus.pending.name)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  FriendRequest.fromMap(d.id, d.data()),
            )
            .toList(),
      );

  @override
  Future<ConnectionPage> fetchConnections({
    required String me,
    Object? cursor,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _connections
        .where('users', arrayContains: me)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (cursor is DocumentSnapshot) {
      query = query.startAfterDocument(cursor);
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    final List<Connection> connections = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              Connection.fromMap(d.id, d.data(), me),
        )
        .toList();
    return ConnectionPage(
      connections: connections,
      nextCursor: snap.docs.isEmpty ? null : snap.docs.last,
      hasMore: snap.docs.length == limit,
    );
  }
}
