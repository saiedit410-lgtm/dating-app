// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application's [GoRouter], exposed as a keep-alive provider so route
/// guards (added in later milestones) can react to auth/session providers.
///
/// The initial route is the [SplashScreen].

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The application's [GoRouter], exposed as a keep-alive provider so route
/// guards (added in later milestones) can react to auth/session providers.
///
/// The initial route is the [SplashScreen].

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application's [GoRouter], exposed as a keep-alive provider so route
  /// guards (added in later milestones) can react to auth/session providers.
  ///
  /// The initial route is the [SplashScreen].
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'44738e55f8b0d7f75d4b03c031b3a1d4dd160f57';
