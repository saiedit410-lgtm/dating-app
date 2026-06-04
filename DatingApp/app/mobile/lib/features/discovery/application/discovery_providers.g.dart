// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [DiscoveryRepository] (Firestore-backed).

@ProviderFor(discoveryRepository)
final discoveryRepositoryProvider = DiscoveryRepositoryProvider._();

/// The app's [DiscoveryRepository] (Firestore-backed).

final class DiscoveryRepositoryProvider
    extends
        $FunctionalProvider<
          DiscoveryRepository,
          DiscoveryRepository,
          DiscoveryRepository
        >
    with $Provider<DiscoveryRepository> {
  /// The app's [DiscoveryRepository] (Firestore-backed).
  DiscoveryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiscoveryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiscoveryRepository create(Ref ref) {
    return discoveryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryRepository>(value),
    );
  }
}

String _$discoveryRepositoryHash() =>
    r'ff0f4637def6459b33b27239a6209bb5cd7961a4';

/// The set of uids the current user has blocked.
///
/// Blocking ships in a later milestone; this is the seam discovery already
/// honours — any uid emitted here is excluded from the feed and detail views.

@ProviderFor(blockedUids)
final blockedUidsProvider = BlockedUidsProvider._();

/// The set of uids the current user has blocked.
///
/// Blocking ships in a later milestone; this is the seam discovery already
/// honours — any uid emitted here is excluded from the feed and detail views.

final class BlockedUidsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// The set of uids the current user has blocked.
  ///
  /// Blocking ships in a later milestone; this is the seam discovery already
  /// honours — any uid emitted here is excluded from the feed and detail views.
  BlockedUidsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUidsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUidsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return blockedUids(ref);
  }
}

String _$blockedUidsHash() => r'31aacdd5b56c8c7c5e1007dfb9269baaa0220f99';

/// One public profile by id (detail screen / deep links).

@ProviderFor(profileById)
final profileByIdProvider = ProfileByIdFamily._();

/// One public profile by id (detail screen / deep links).

final class ProfileByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicProfile?>,
          PublicProfile?,
          FutureOr<PublicProfile?>
        >
    with $FutureModifier<PublicProfile?>, $FutureProvider<PublicProfile?> {
  /// One public profile by id (detail screen / deep links).
  ProfileByIdProvider._({
    required ProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileByIdHash();

  @override
  String toString() {
    return r'profileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PublicProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublicProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return profileById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileByIdHash() => r'b0879b6dfd9e0847d744922225c99d84d5f74aa6';

/// One public profile by id (detail screen / deep links).

final class ProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PublicProfile?>, String> {
  ProfileByIdFamily._()
    : super(
        retry: null,
        name: r'profileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One public profile by id (detail screen / deep links).

  ProfileByIdProvider call(String uid) =>
      ProfileByIdProvider._(argument: uid, from: this);

  @override
  String toString() => r'profileByIdProvider';
}
