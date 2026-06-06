// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single Nearby feed controller.
///
/// Phase 2.2: replaces both the legacy `NearbyController` and the
/// `RankedNearbyController` with a single controller that emits
/// [RankedFeedState] over [ScoredProfile]. When the
/// [matchingEngineEnabled] feature flag is off, scoring is skipped
/// and distance is the only sort key (legacy behavior).

@ProviderFor(NearbyController)
final nearbyControllerProvider = NearbyControllerProvider._();

/// The single Nearby feed controller.
///
/// Phase 2.2: replaces both the legacy `NearbyController` and the
/// `RankedNearbyController` with a single controller that emits
/// [RankedFeedState] over [ScoredProfile]. When the
/// [matchingEngineEnabled] feature flag is off, scoring is skipped
/// and distance is the only sort key (legacy behavior).
final class NearbyControllerProvider
    extends
        $NotifierProvider<NearbyController, RankedFeedState<ScoredProfile>> {
  /// The single Nearby feed controller.
  ///
  /// Phase 2.2: replaces both the legacy `NearbyController` and the
  /// `RankedNearbyController` with a single controller that emits
  /// [RankedFeedState] over [ScoredProfile]. When the
  /// [matchingEngineEnabled] feature flag is off, scoring is skipped
  /// and distance is the only sort key (legacy behavior).
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
  Override overrideWithValue(RankedFeedState<ScoredProfile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RankedFeedState<ScoredProfile>>(
        value,
      ),
    );
  }
}

String _$nearbyControllerHash() => r'809773e77f6e5f2da4a2bc279d627ca9745b5335';

/// The single Nearby feed controller.
///
/// Phase 2.2: replaces both the legacy `NearbyController` and the
/// `RankedNearbyController` with a single controller that emits
/// [RankedFeedState] over [ScoredProfile]. When the
/// [matchingEngineEnabled] feature flag is off, scoring is skipped
/// and distance is the only sort key (legacy behavior).

abstract class _$NearbyController
    extends $Notifier<RankedFeedState<ScoredProfile>> {
  RankedFeedState<ScoredProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              RankedFeedState<ScoredProfile>,
              RankedFeedState<ScoredProfile>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RankedFeedState<ScoredProfile>,
                RankedFeedState<ScoredProfile>
              >,
              RankedFeedState<ScoredProfile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The active radius chip on the nearby tab. Lives outside the
/// controller so [setRadius] can be a pure read of the next
/// value, and so the UI can `ref.watch` it without owning it.

@ProviderFor(NearbyRadiusController)
final nearbyRadiusControllerProvider = NearbyRadiusControllerProvider._();

/// The active radius chip on the nearby tab. Lives outside the
/// controller so [setRadius] can be a pure read of the next
/// value, and so the UI can `ref.watch` it without owning it.
final class NearbyRadiusControllerProvider
    extends $NotifierProvider<NearbyRadiusController, NearbyRadius> {
  /// The active radius chip on the nearby tab. Lives outside the
  /// controller so [setRadius] can be a pure read of the next
  /// value, and so the UI can `ref.watch` it without owning it.
  NearbyRadiusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyRadiusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyRadiusControllerHash();

  @$internal
  @override
  NearbyRadiusController create() => NearbyRadiusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NearbyRadius value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NearbyRadius>(value),
    );
  }
}

String _$nearbyRadiusControllerHash() =>
    r'3589ec23aea8a7c08fc52081311b11dac6b06d64';

/// The active radius chip on the nearby tab. Lives outside the
/// controller so [setRadius] can be a pure read of the next
/// value, and so the UI can `ref.watch` it without owning it.

abstract class _$NearbyRadiusController extends $Notifier<NearbyRadius> {
  NearbyRadius build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NearbyRadius, NearbyRadius>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NearbyRadius, NearbyRadius>,
              NearbyRadius,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
