import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/discovery/domain/discovery_repository.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// Firestore-backed discovery queries over the `users` collection.
///
/// Server-side filters (require a composite index — see
/// backend/firestore/firestore.indexes.json):
///   onboardingComplete == true
///   accountStatus      == 'active'
///   age in [minAge, maxAge]   (range → orderBy age)
///
/// Remaining filters (gender / interestedIn / city / state), self-exclusion and
/// block-list exclusion are applied client-side in the controller.
class FirestoreDiscoveryRepository implements DiscoveryRepository {
  FirestoreDiscoveryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<DiscoveryPage> fetchPage({
    required int minAge,
    required int maxAge,
    Object? cursor,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _users
        .where('onboardingComplete', isEqualTo: true)
        .where('accountStatus', isEqualTo: 'active')
        .where('age', isGreaterThanOrEqualTo: minAge)
        .where('age', isLessThanOrEqualTo: maxAge)
        .orderBy('age')
        .limit(limit);

    if (cursor is DocumentSnapshot) {
      query = query.startAfterDocument(cursor);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    final List<PublicProfile> profiles = snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              PublicProfile.fromMap(doc.id, doc.data()),
        )
        .toList();

    return DiscoveryPage(
      profiles: profiles,
      nextCursor: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length == limit,
    );
  }

  @override
  Future<PublicProfile?> fetchProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _users.doc(uid).get();
    final Map<String, dynamic>? data = snap.data();
    if (!snap.exists || data == null) return null;
    return PublicProfile.fromMap(snap.id, data);
  }
}
