// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single Discovery feed controller for the "All" tab.
///
/// Phase 2.2: replaces the legacy pagination-only controller with
/// a scored variant. When the [matchingEngineEnabled] feature flag
/// is off, scoring is skipped and the controller degenerates to the
/// legacy age-ordered feed (same behavior as Phase 2.0/2.1).

@ProviderFor(DiscoveryController)
final discoveryControllerProvider = DiscoveryControllerProvider._();

/// The single Discovery feed controller for the "All" tab.
///
/// Phase 2.2: replaces the legacy pagination-only controller with
/// a scored variant. When the [matchingEngineEnabled] feature flag
/// is off, scoring is skipped and the controller degenerates to the
/// legacy age-ordered feed (same behavior as Phase 2.0/2.1).
final class DiscoveryControllerProvider
    extends
        $NotifierProvider<DiscoveryController, RankedFeedState<ScoredProfile>> {
  /// The single Discovery feed controller for the "All" tab.
  ///
  /// Phase 2.2: replaces the legacy pagination-only controller with
  /// a scored variant. When the [matchingEngineEnabled] feature flag
  /// is off, scoring is skipped and the controller degenerates to the
  /// legacy age-ordered feed (same behavior as Phase 2.0/2.1).
  DiscoveryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryControllerHash();

  @$internal
  @override
  DiscoveryController create() => DiscoveryController();

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

String _$discoveryControllerHash() =>
    r'abd238282b7be8b2ef50038bf8462b5a9025126c';

/// The single Discovery feed controller for the "All" tab.
///
/// Phase 2.2: replaces the legacy pagination-only controller with
/// a scored variant. When the [matchingEngineEnabled] feature flag
/// is off, scoring is skipped and the controller degenerates to the
/// legacy age-ordered feed (same behavior as Phase 2.0/2.1).

abstract class _$DiscoveryController
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
