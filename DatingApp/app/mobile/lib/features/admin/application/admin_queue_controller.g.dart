// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminQueueController)
final adminQueueControllerProvider = AdminQueueControllerProvider._();

final class AdminQueueControllerProvider
    extends $NotifierProvider<AdminQueueController, AdminQueueState> {
  AdminQueueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminQueueControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminQueueControllerHash();

  @$internal
  @override
  AdminQueueController create() => AdminQueueController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminQueueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminQueueState>(value),
    );
  }
}

String _$adminQueueControllerHash() =>
    r'b7e44de00641dbb6a0a589c795a5c0bc376698c7';

abstract class _$AdminQueueController extends $Notifier<AdminQueueState> {
  AdminQueueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AdminQueueState, AdminQueueState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminQueueState, AdminQueueState>,
              AdminQueueState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
