// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [SafetyRepository] (Firestore-backed).

@ProviderFor(safetyRepository)
final safetyRepositoryProvider = SafetyRepositoryProvider._();

/// The app's [SafetyRepository] (Firestore-backed).

final class SafetyRepositoryProvider
    extends
        $FunctionalProvider<
          SafetyRepository,
          SafetyRepository,
          SafetyRepository
        >
    with $Provider<SafetyRepository> {
  /// The app's [SafetyRepository] (Firestore-backed).
  SafetyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRepository>(value),
    );
  }
}

String _$safetyRepositoryHash() => r'b1d7c47fac02b989d24d874efc856c694909c9f3';

/// Uids hidden from the current user (mutual blocks). Discovery, connections
/// and chat all honour this set. Empty when signed out.

@ProviderFor(blockedUids)
final blockedUidsProvider = BlockedUidsProvider._();

/// Uids hidden from the current user (mutual blocks). Discovery, connections
/// and chat all honour this set. Empty when signed out.

final class BlockedUidsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// Uids hidden from the current user (mutual blocks). Discovery, connections
  /// and chat all honour this set. Empty when signed out.
  BlockedUidsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUidsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUidsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return blockedUids(ref);
  }
}

String _$blockedUidsHash() => r'd21e446e6f93a205cb6ac83519bbb0337c329f2c';
