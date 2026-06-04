// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the resolved [EnvConfig] to the rest of the app.

@ProviderFor(envConfig)
final envConfigProvider = EnvConfigProvider._();

/// Provides the resolved [EnvConfig] to the rest of the app.

final class EnvConfigProvider
    extends $FunctionalProvider<EnvConfig, EnvConfig, EnvConfig>
    with $Provider<EnvConfig> {
  /// Provides the resolved [EnvConfig] to the rest of the app.
  EnvConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envConfigHash();

  @$internal
  @override
  $ProviderElement<EnvConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EnvConfig create(Ref ref) {
    return envConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvConfig>(value),
    );
  }
}

String _$envConfigHash() => r'92b0f20d6b6129bb0d9d0c626b4800f4638f2b3f';
