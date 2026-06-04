import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/auth/domain/auth_failure.dart';
import 'package:dating_app/features/auth/domain/auth_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_auth_controller.g.dart';

/// Stages of the phone-OTP flow.
enum PhoneAuthStatus { initial, sendingCode, codeSent, verifying, verified, error }

/// Immutable state for the phone-OTP flow.
class PhoneAuthState {
  const PhoneAuthState({
    this.status = PhoneAuthStatus.initial,
    this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.failure,
  });

  final PhoneAuthStatus status;
  final String? phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final AuthFailure? failure;

  bool get isSendingCode => status == PhoneAuthStatus.sendingCode;
  bool get isVerifying => status == PhoneAuthStatus.verifying;
  bool get isBusy => isSendingCode || isVerifying;
  bool get hasError => status == PhoneAuthStatus.error;
  bool get codeSent =>
      status == PhoneAuthStatus.codeSent ||
      status == PhoneAuthStatus.verifying;
}

/// Drives phone-number verification and OTP confirmation, and creates the
/// `users/{uid}` document on first successful login.
@riverpod
class PhoneAuthController extends _$PhoneAuthController {
  @override
  PhoneAuthState build() => const PhoneAuthState();

  /// Sends an OTP to [phoneNumber] (expected in E.164, e.g. `+919999999999`).
  Future<void> sendCode(String phoneNumber) =>
      _startVerification(phoneNumber, resendToken: null);

  /// Resends the OTP to the same number using the stored resend token.
  Future<void> resendCode() {
    final phone = state.phoneNumber;
    if (phone == null) return Future<void>.value();
    return _startVerification(phone, resendToken: state.resendToken);
  }

  Future<void> _startVerification(String phone, {int? resendToken}) async {
    state = PhoneAuthState(
      status: PhoneAuthStatus.sendingCode,
      phoneNumber: phone,
    );
    await ref.read(authRepositoryProvider).verifyPhoneNumber(
      phoneNumber: phone,
      resendToken: resendToken,
      onCodeSent: (verificationId, token) {
        state = PhoneAuthState(
          status: PhoneAuthStatus.codeSent,
          phoneNumber: phone,
          verificationId: verificationId,
          resendToken: token,
        );
      },
      onFailed: (error) {
        state = PhoneAuthState(
          status: PhoneAuthStatus.error,
          phoneNumber: phone,
          failure: error.failure,
        );
      },
      onAutoVerified: (user) async {
        await _ensureUserDocument(user);
        state = const PhoneAuthState(status: PhoneAuthStatus.verified);
      },
    );
  }

  /// Confirms the entered [smsCode] and signs in.
  Future<void> verifyCode(String smsCode) async {
    final verificationId = state.verificationId;
    final phone = state.phoneNumber;
    final resendToken = state.resendToken;
    if (verificationId == null) return;

    state = PhoneAuthState(
      status: PhoneAuthStatus.verifying,
      phoneNumber: phone,
      verificationId: verificationId,
      resendToken: resendToken,
    );
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .confirmOtp(verificationId: verificationId, smsCode: smsCode);
      await _ensureUserDocument(user);
      state = const PhoneAuthState(status: PhoneAuthStatus.verified);
    } on AuthException catch (e) {
      state = PhoneAuthState(
        status: PhoneAuthStatus.error,
        phoneNumber: phone,
        verificationId: verificationId,
        resendToken: resendToken,
        failure: e.failure,
      );
    }
  }

  Future<void> _ensureUserDocument(AuthUser user) =>
      ref.read(userRepositoryProvider).ensureUserDocument(user);

  /// Resets the flow (e.g. when the user edits their phone number).
  void reset() => state = const PhoneAuthState();
}
