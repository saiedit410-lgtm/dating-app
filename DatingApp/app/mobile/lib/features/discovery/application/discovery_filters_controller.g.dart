// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the active [DiscoveryFilters], persisted locally via
/// SharedPreferences so they survive app restarts.

@ProviderFor(DiscoveryFiltersController)
final discoveryFiltersControllerProvider =
    DiscoveryFiltersControllerProvider._();

/// Holds the active [DiscoveryFilters], persisted locally via
/// SharedPreferences so they survive app restarts.
final class DiscoveryFiltersControllerProvider
    extends $NotifierProvider<DiscoveryFiltersController, DiscoveryFilters> {
  /// Holds the active [DiscoveryFilters], persisted locally via
  /// SharedPreferences so they survive app restarts.
  DiscoveryFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryFiltersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryFiltersControllerHash();

  @$internal
  @override
  DiscoveryFiltersController create() => DiscoveryFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryFilters>(value),
    );
  }
}

String _$discoveryFiltersControllerHash() =>
    r'40a3571035d066acbd5b655076e9a17c4ea4a9ee';

/// Holds the active [DiscoveryFilters], persisted locally via
/// SharedPreferences so they survive app restarts.

abstract class _$DiscoveryFiltersController
    extends $Notifier<DiscoveryFilters> {
  DiscoveryFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DiscoveryFilters, DiscoveryFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoveryFilters, DiscoveryFilters>,
              DiscoveryFilters,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
