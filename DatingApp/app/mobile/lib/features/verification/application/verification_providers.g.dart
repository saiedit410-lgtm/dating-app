// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [VerificationRepository] (Firestore + Storage).

@ProviderFor(verificationRepository)
final verificationRepositoryProvider = VerificationRepositoryProvider._();

/// The app's [VerificationRepository] (Firestore + Storage).

final class VerificationRepositoryProvider
    extends
        $FunctionalProvider<
          VerificationRepository,
          VerificationRepository,
          VerificationRepository
        >
    with $Provider<VerificationRepository> {
  /// The app's [VerificationRepository] (Firestore + Storage).
  VerificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VerificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerificationRepository create(Ref ref) {
    return verificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationRepository>(value),
    );
  }
}

String _$verificationRepositoryHash() =>
    r'835a135ff52ea3a710d5e4167e2aeaae1a36648a';

/// Live verification request for the signed-in user.

@ProviderFor(myVerificationRequest)
final myVerificationRequestProvider = MyVerificationRequestProvider._();

/// Live verification request for the signed-in user.

final class MyVerificationRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<VerificationRequest?>,
          VerificationRequest?,
          Stream<VerificationRequest?>
        >
    with
        $FutureModifier<VerificationRequest?>,
        $StreamProvider<VerificationRequest?> {
  /// Live verification request for the signed-in user.
  MyVerificationRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myVerificationRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myVerificationRequestHash();

  @$internal
  @override
  $StreamProviderElement<VerificationRequest?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<VerificationRequest?> create(Ref ref) {
    return myVerificationRequest(ref);
  }
}

String _$myVerificationRequestHash() =>
    r'e0e3915afe652e7904ce626276105e6c8ce7c316';
