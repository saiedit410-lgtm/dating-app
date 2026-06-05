// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picks a selfie, validates it (reusing [PhotoValidator]), and submits a
/// verification request.

@ProviderFor(VerificationController)
final verificationControllerProvider = VerificationControllerProvider._();

/// Picks a selfie, validates it (reusing [PhotoValidator]), and submits a
/// verification request.
final class VerificationControllerProvider
    extends $NotifierProvider<VerificationController, VerificationSubmitState> {
  /// Picks a selfie, validates it (reusing [PhotoValidator]), and submits a
  /// verification request.
  VerificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationControllerHash();

  @$internal
  @override
  VerificationController create() => VerificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationSubmitState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationSubmitState>(value),
    );
  }
}

String _$verificationControllerHash() =>
    r'b80ac8de23c9f01b3de300cfebc626524336a89e';

/// Picks a selfie, validates it (reusing [PhotoValidator]), and submits a
/// verification request.

abstract class _$VerificationController
    extends $Notifier<VerificationSubmitState> {
  VerificationSubmitState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<VerificationSubmitState, VerificationSubmitState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerificationSubmitState, VerificationSubmitState>,
              VerificationSubmitState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
