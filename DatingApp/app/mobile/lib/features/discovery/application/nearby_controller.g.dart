// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads nearby profiles around the current [LocationController] position.
///
/// Reads the auth uid (to exclude self), the blocked-uid set, and the
/// current [LocationState.location] for the search origin.

@ProviderFor(NearbyController)
final nearbyControllerProvider = NearbyControllerProvider._();

/// Loads nearby profiles around the current [LocationController] position.
///
/// Reads the auth uid (to exclude self), the blocked-uid set, and the
/// current [LocationState.location] for the search origin.
final class NearbyControllerProvider
    extends $NotifierProvider<NearbyController, NearbyState> {
  /// Loads nearby profiles around the current [LocationController] position.
  ///
  /// Reads the auth uid (to exclude self), the blocked-uid set, and the
  /// current [LocationState.location] for the search origin.
  NearbyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyControllerHash();

  @$internal
  @override
  NearbyController create() => NearbyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearbyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearbyState>(value),
    );
  }
}

String _$nearbyControllerHash() => r'4e748d6fcdff6180c8ffd6ed43466eea70374638';

/// Loads nearby profiles around the current [LocationController] position.
///
/// Reads the auth uid (to exclude self), the blocked-uid set, and the
/// current [LocationState.location] for the search origin.

abstract class _$NearbyController extends $Notifier<NearbyState> {
  NearbyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NearbyState, NearbyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NearbyState, NearbyState>,
              NearbyState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
