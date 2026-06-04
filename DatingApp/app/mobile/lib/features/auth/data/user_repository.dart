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
  /// On first login it creates the PUBLIC profile document (no sensitive data)
  /// plus the PRIVATE `users/{uid}/private/data` document holding the phone
  /// number. On subsequent logins it only refreshes `updatedAt`. Runs in a
  /// transaction so the create-once invariant holds even under races.
  Future<void> ensureUserDocument(AuthUser user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final privateRef = userRef.collection('private').doc('data');
    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(userRef);
      if (snapshot.exists) {
        txn.update(userRef, {'updatedAt': FieldValue.serverTimestamp()});
      } else {
        // Public profile document (readable by other signed-in users).
        txn.set(userRef, <String, Object?>{
          'uid': user.uid,
          'accountStatus': 'active',
          'isVerified': false,
          'onboardingComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        // Private document (owner-only) for sensitive data.
        txn.set(privateRef, <String, Object?>{
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
