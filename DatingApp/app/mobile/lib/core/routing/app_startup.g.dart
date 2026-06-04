// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Derives the [AppStartupStage] from auth + profile state.

@ProviderFor(appStartupStage)
final appStartupStageProvider = AppStartupStageProvider._();

/// Derives the [AppStartupStage] from auth + profile state.

final class AppStartupStageProvider
    extends
        $FunctionalProvider<AppStartupStage, AppStartupStage, AppStartupStage>
    with $Provider<AppStartupStage> {
  /// Derives the [AppStartupStage] from auth + profile state.
  AppStartupStageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupStageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupStageHash();

  @$internal
  @override
  $ProviderElement<AppStartupStage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppStartupStage create(Ref ref) {
    return appStartupStage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStartupStage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStartupStage>(value),
    );
  }
}

String _$appStartupStageHash() => r'a4d6f0eea95b94a6408c1b17b3d16be44df64ee5';
