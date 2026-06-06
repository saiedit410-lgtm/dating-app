import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/likes/domain/like.dart';
import 'package:dating_app/features/likes/domain/like_repository.dart';

/// Firestore implementation over `likes/{from}_{to}`.
///
/// Rules govern the security (see `backend/firestore/firestore.rules`):
/// the doc id is the directional pair, so re-likes are idempotent.
class FirestoreLikeRepository implements LikeRepository {
  FirestoreLikeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('likes');

  @override
  Future<bool> hasLiked({
    required String fromUid,
    required String toUid,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await _likes
        .doc(LikeIds.like(fromUid, toUid))
        .get();
    return snap.exists;
  }

  @override
  Stream<List<Like>> watchSentLikes(String me) => _likes
      .where('fromUid', isEqualTo: me)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  Like.fromMap(d.id, d.data()),
            )
            .toList(),
      );

  @override
  Stream<List<Like>> watchReceivedLikes(String me) => _likes
      .where('toUid', isEqualTo: me)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  Like.fromMap(d.id, d.data()),
            )
            .toList(),
      );

  @override
  Future<void> like({required String fromUid, required String toUid}) =>
      _likes.doc(LikeIds.like(fromUid, toUid)).set(<String, Object?>{
        'fromUid': fromUid,
        'toUid': toUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> unlike({
    required String fromUid,
    required String toUid,
  }) => _likes.doc(LikeIds.like(fromUid, toUid)).delete();
}
