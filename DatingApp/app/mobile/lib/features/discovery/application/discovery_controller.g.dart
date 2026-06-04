// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads discoverable profiles with cursor-based pagination, applying
/// self-exclusion, the block list, and client-side filters per page.

@ProviderFor(DiscoveryController)
final discoveryControllerProvider = DiscoveryControllerProvider._();

/// Loads discoverable profiles with cursor-based pagination, applying
/// self-exclusion, the block list, and client-side filters per page.
final class DiscoveryControllerProvider
    extends $NotifierProvider<DiscoveryController, DiscoveryState> {
  /// Loads discoverable profiles with cursor-based pagination, applying
  /// self-exclusion, the block list, and client-side filters per page.
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
  Override overrideWithValue(DiscoveryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryState>(value),
    );
  }
}

String _$discoveryControllerHash() =>
    r'314523bd5dbb6d085bcfc35b7fbe03beb6df8af6';

/// Loads discoverable profiles with cursor-based pagination, applying
/// self-exclusion, the block list, and client-side filters per page.

abstract class _$DiscoveryController extends $Notifier<DiscoveryState> {
  DiscoveryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DiscoveryState, DiscoveryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoveryState, DiscoveryState>,
              DiscoveryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
