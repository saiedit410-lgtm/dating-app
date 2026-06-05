// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the location permission flow + the "refresh my location" action.
/// The nearby tab listens here to decide whether to render the prompt
/// screen or the results.

@ProviderFor(LocationController)
final locationControllerProvider = LocationControllerProvider._();

/// Owns the location permission flow + the "refresh my location" action.
/// The nearby tab listens here to decide whether to render the prompt
/// screen or the results.
final class LocationControllerProvider
    extends $NotifierProvider<LocationController, LocationState> {
  /// Owns the location permission flow + the "refresh my location" action.
  /// The nearby tab listens here to decide whether to render the prompt
  /// screen or the results.
  LocationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationControllerHash();

  @$internal
  @override
  LocationController create() => LocationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationState>(value),
    );
  }
}

String _$locationControllerHash() =>
    r'8c420935c1af26ba197fcd7aa027e003dea84fcd';

/// Owns the location permission flow + the "refresh my location" action.
/// The nearby tab listens here to decide whether to render the prompt
/// screen or the results.

abstract class _$LocationController extends $Notifier<LocationState> {
  LocationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LocationState, LocationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationState, LocationState>,
              LocationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
