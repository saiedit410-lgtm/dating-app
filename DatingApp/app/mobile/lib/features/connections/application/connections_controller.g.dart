// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connections_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the signed-in user's accepted connections with cursor pagination.

@ProviderFor(ConnectionsController)
final connectionsControllerProvider = ConnectionsControllerProvider._();

/// Loads the signed-in user's accepted connections with cursor pagination.
final class ConnectionsControllerProvider
    extends $NotifierProvider<ConnectionsController, ConnectionsState> {
  /// Loads the signed-in user's accepted connections with cursor pagination.
  ConnectionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsControllerHash();

  @$internal
  @override
  ConnectionsController create() => ConnectionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionsState>(value),
    );
  }
}

String _$connectionsControllerHash() =>
    r'12ad986b97c9d0f1451a2fe160cceda517283916';

/// Loads the signed-in user's accepted connections with cursor pagination.

abstract class _$ConnectionsController extends $Notifier<ConnectionsState> {
  ConnectionsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectionsState, ConnectionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionsState, ConnectionsState>,
              ConnectionsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
