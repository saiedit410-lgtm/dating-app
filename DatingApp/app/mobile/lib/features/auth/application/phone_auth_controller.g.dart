// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives phone-number verification and OTP confirmation, and creates the
/// `users/{uid}` document on first successful login.

@ProviderFor(PhoneAuthController)
final phoneAuthControllerProvider = PhoneAuthControllerProvider._();

/// Drives phone-number verification and OTP confirmation, and creates the
/// `users/{uid}` document on first successful login.
final class PhoneAuthControllerProvider
    extends $NotifierProvider<PhoneAuthController, PhoneAuthState> {
  /// Drives phone-number verification and OTP confirmation, and creates the
  /// `users/{uid}` document on first successful login.
  PhoneAuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneAuthControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneAuthControllerHash();

  @$internal
  @override
  PhoneAuthController create() => PhoneAuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhoneAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhoneAuthState>(value),
    );
  }
}

String _$phoneAuthControllerHash() =>
    r'202d40e86b44872ff11452d1048116dd22a1ccaa';

/// Drives phone-number verification and OTP confirmation, and creates the
/// `users/{uid}` document on first successful login.

abstract class _$PhoneAuthController extends $Notifier<PhoneAuthState> {
  PhoneAuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PhoneAuthState, PhoneAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhoneAuthState, PhoneAuthState>,
              PhoneAuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
