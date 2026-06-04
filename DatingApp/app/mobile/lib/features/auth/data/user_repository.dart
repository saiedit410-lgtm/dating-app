import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';

/// Reads/creates the minimal `users/{uid}` document.
///
/// The full profile schema is added in the profile milestone; this only
/// guarantees a document exists immediately after first login.
class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Ensures `users/{uid}` exists after a successful login.
  ///
  /// On first login it creates the document with the minimum schema; on
  /// subsequent logins it only refreshes `updatedAt`. Runs in a transaction so
  /// the create-once invariant holds even under races.
  Future<void> ensureUserDocument(AuthUser user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(ref);
      if (snapshot.exists) {
        txn.update(ref, {'updatedAt': FieldValue.serverTimestamp()});
      } else {
        txn.set(ref, <String, Object?>{
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'accountStatus': 'active',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
