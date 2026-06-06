import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_repository.dart';

/// Firestore-backed [MatchRepository].
///
/// `MatchPreferences` live on the **private** sub-doc
/// `users/{uid}/private/matchPrefs` so they are readable only by
/// the owner and admins (server-enforced by `firestore.rules`).
/// The matcher's hard filters run client-side; the public profile
/// never carries preferences.
class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _prefsDoc(String uid) =>
      _firestore.collection('users').doc(uid).collection('private').doc('matchPrefs');

  @override
  Stream<MatchPreferences?> watchMatchPreferences(String uid) =>
      _prefsDoc(uid)
          .snapshots()
          .map((DocumentSnapshot<Map<String, dynamic>> s) =>
              MatchPreferences.fromMap(s.data()));

  @override
  Future<MatchPreferences?> fetchMatchPreferences(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _prefsDoc(uid).get();
    return MatchPreferences.fromMap(snap.data());
  }

  @override
  Future<void> saveMatchPreferences(String uid, MatchPreferences prefs) =>
      _prefsDoc(uid).set(
        <String, Object?>{
          'matchPrefs': prefs.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
}
