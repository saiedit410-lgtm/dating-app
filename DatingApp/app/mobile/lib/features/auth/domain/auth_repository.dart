import 'package:dating_app/features/auth/domain/auth_failure.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';

/// Authentication contract. Implemented in the data layer by Firebase, so the
/// domain and presentation layers never depend on `firebase_auth` directly.
abstract interface class AuthRepository {
  /// Emits the current [AuthUser], or null when signed out. Also fires once on
  /// app start after the persisted session is restored.
  Stream<AuthUser?> authStateChanges();

  /// Synchronous snapshot of the currently signed-in user, or null.
  AuthUser? currentUser();

  /// Starts phone-number verification (sends an SMS or uses a configured test
  /// number).
  ///
  /// [onCodeSent] fires with a `verificationId` once the code is dispatched.
  /// [onFailed] reports a typed failure. [onAutoVerified] fires on Android
  /// instant-verification / SMS auto-retrieval (user is already signed in).
  /// Pass [resendToken] to force a resend.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(AuthException error) onFailed,
    void Function(AuthUser user)? onAutoVerified,
    int? resendToken,
  });

  /// Confirms a manually-entered [smsCode] for a [verificationId] and signs in.
  Future<AuthUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Signs the current user out.
  Future<void> signOut();
}
