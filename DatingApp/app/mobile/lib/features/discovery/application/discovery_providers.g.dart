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

/// The app's [NearbySearchRepository] (Firestore-backed, geohash-bucketed).

@ProviderFor(nearbySearchRepository)
final nearbySearchRepositoryProvider = NearbySearchRepositoryProvider._();

/// The app's [NearbySearchRepository] (Firestore-backed, geohash-bucketed).

final class NearbySearchRepositoryProvider
    extends
        $FunctionalProvider<
          NearbySearchRepository,
          NearbySearchRepository,
          NearbySearchRepository
        >
    with $Provider<NearbySearchRepository> {
  /// The app's [NearbySearchRepository] (Firestore-backed, geohash-bucketed).
  NearbySearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbySearchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbySearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<NearbySearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NearbySearchRepository create(Ref ref) {
    return nearbySearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearbySearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearbySearchRepository>(value),
    );
  }
}

String _$nearbySearchRepositoryHash() =>
    r'18efbc70f32308b79a5ede3643f7fd92cfd4f8d4';

/// The app's [LocationRepository] (`geolocator` + Firestore-backed).

@ProviderFor(locationRepository)
final locationRepositoryProvider = LocationRepositoryProvider._();

/// The app's [LocationRepository] (`geolocator` + Firestore-backed).

final class LocationRepositoryProvider
    extends
        $FunctionalProvider<
          LocationRepository,
          LocationRepository,
          LocationRepository
        >
    with $Provider<LocationRepository> {
  /// The app's [LocationRepository] (`geolocator` + Firestore-backed).
  LocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationRepository create(Ref ref) {
    return locationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationRepository>(value),
    );
  }
}

String _$locationRepositoryHash() =>
    r'ea84467af35d4e9c05dd5227136e33991b12efd8';
