import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores FCM device tokens privately under
/// `users/{uid}/deviceTokens/{token}` (doc id == token), supporting multiple
/// devices per user. Owner-only via security rules.
class DeviceTokenRepository {
  DeviceTokenRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tokens(String uid) =>
      _firestore.collection('users').doc(uid).collection('deviceTokens');

  Future<void> saveToken(
    String uid,
    String token, {
    required String platform,
  }) => _tokens(uid).doc(token).set(<String, Object?>{
    'token': token,
    'platform': platform,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> deleteToken(String uid, String token) =>
      _tokens(uid).doc(token).delete();
}
