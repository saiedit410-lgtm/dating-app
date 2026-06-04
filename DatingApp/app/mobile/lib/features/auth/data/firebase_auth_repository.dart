import 'package:dating_app/features/auth/domain/auth_failure.dart';
import 'package:dating_app/features/auth/domain/auth_repository.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase-backed [AuthRepository]. Wraps the real `firebase_auth` SDK and
/// maps its types/errors onto the domain ([AuthUser] / [AuthException]).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AuthUser? _toAuthUser(User? user) => user == null
      ? null
      : AuthUser(uid: user.uid, phoneNumber: user.phoneNumber);

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  AuthUser? currentUser() => _toAuthUser(_auth.currentUser);

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthException error) onFailed,
    void Function(AuthUser user)? onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (onAutoVerified == null) return;
        try {
          final result = await _auth.signInWithCredential(credential);
          final user = _toAuthUser(result.user);
          if (user != null) onAutoVerified(user);
        } on FirebaseAuthException catch (e) {
          onFailed(_map(e));
        }
      },
      verificationFailed: (FirebaseAuthException e) => onFailed(_map(e)),
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<AuthUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = _toAuthUser(result.user);
      if (user == null) {
        throw const AuthException(AuthFailure.unknown);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AuthException _map(FirebaseAuthException e) {
    final failure = switch (e.code) {
      'invalid-phone-number' => AuthFailure.invalidPhoneNumber,
      'invalid-verification-code' => AuthFailure.invalidVerificationCode,
      'session-expired' || 'code-expired' => AuthFailure.sessionExpired,
      'too-many-requests' => AuthFailure.tooManyRequests,
      'network-request-failed' => AuthFailure.network,
      'quota-exceeded' => AuthFailure.quotaExceeded,
      _ => AuthFailure.unknown,
    };
    return AuthException(failure, cause: e);
  }
}
