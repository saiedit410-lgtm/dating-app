import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/likes/domain/profile_visitor.dart';
import 'package:dating_app/features/likes/domain/profile_visitor_repository.dart';

/// Firestore implementation over `profileVisitors/{viewer}_{profile}`.
///
/// The watcher caps the result at the most recent 50 visitors to keep
/// the profile-owner's read cost bounded.
class FirestoreProfileVisitorRepository implements ProfileVisitorRepository {
  FirestoreProfileVisitorRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const int _recentLimit = 50;

  CollectionReference<Map<String, dynamic>> get _visitors =>
      _firestore.collection('profileVisitors');

  @override
  Future<void> recordView({
    required String viewerUid,
    required String profileUid,
  }) => _visitors
      .doc(VisitorIds.visit(viewerUid, profileUid))
      // Idempotent on doc id — re-opening a profile refreshes the
      // viewedAt timestamp. Set (not update) so the first view creates
      // the doc even if the prior batch never wrote it.
      .set(<String, Object?>{
        'viewerUid': viewerUid,
        'profileUid': profileUid,
        'viewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  @override
  Stream<List<ProfileVisitor>> watchRecentVisitors(String me) => _visitors
      .where('profileUid', isEqualTo: me)
      .orderBy('viewedAt', descending: true)
      .limit(_recentLimit)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  ProfileVisitor.fromMap(d.id, d.data()),
            )
            .toList(),
      );
}
