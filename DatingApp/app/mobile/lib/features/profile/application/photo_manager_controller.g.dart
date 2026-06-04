// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_manager_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Handles picking, validating, uploading, reordering and deleting photos.

@ProviderFor(PhotoManagerController)
final photoManagerControllerProvider = PhotoManagerControllerProvider._();

/// Handles picking, validating, uploading, reordering and deleting photos.
final class PhotoManagerControllerProvider
    extends $NotifierProvider<PhotoManagerController, PhotoManagerState> {
  /// Handles picking, validating, uploading, reordering and deleting photos.
  PhotoManagerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoManagerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoManagerControllerHash();

  @$internal
  @override
  PhotoManagerController create() => PhotoManagerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoManagerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoManagerState>(value),
    );
  }
}

String _$photoManagerControllerHash() =>
    r'4215181f6c94801cf9b579b666f349bef19844ed';

/// Handles picking, validating, uploading, reordering and deleting photos.

abstract class _$PhotoManagerController extends $Notifier<PhotoManagerState> {
  PhotoManagerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PhotoManagerState, PhotoManagerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhotoManagerState, PhotoManagerState>,
              PhotoManagerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
