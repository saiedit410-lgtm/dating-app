// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'likes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [LikeRepository] (Firestore-backed).

@ProviderFor(likeRepository)
final likeRepositoryProvider = LikeRepositoryProvider._();

/// The app's [LikeRepository] (Firestore-backed).

final class LikeRepositoryProvider
    extends $FunctionalProvider<LikeRepository, LikeRepository, LikeRepository>
    with $Provider<LikeRepository> {
  /// The app's [LikeRepository] (Firestore-backed).
  LikeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likeRepositoryHash();

  @$internal
  @override
  $ProviderElement<LikeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LikeRepository create(Ref ref) {
    return likeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LikeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LikeRepository>(value),
    );
  }
}

String _$likeRepositoryHash() => r'3c48aab2d4210628e03736fb760863aafab574b4';

/// The app's [ProfileVisitorRepository] (Firestore-backed).

@ProviderFor(profileVisitorRepository)
final profileVisitorRepositoryProvider = ProfileVisitorRepositoryProvider._();

/// The app's [ProfileVisitorRepository] (Firestore-backed).

final class ProfileVisitorRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileVisitorRepository,
          ProfileVisitorRepository,
          ProfileVisitorRepository
        >
    with $Provider<ProfileVisitorRepository> {
  /// The app's [ProfileVisitorRepository] (Firestore-backed).
  ProfileVisitorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileVisitorRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileVisitorRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileVisitorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileVisitorRepository create(Ref ref) {
    return profileVisitorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileVisitorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileVisitorRepository>(value),
    );
  }
}

String _$profileVisitorRepositoryHash() =>
    r'0850c54edeb3bb02b26049b4a2b871989f4142cc';

/// Live likes the signed-in user has sent.

@ProviderFor(sentLikes)
final sentLikesProvider = SentLikesProvider._();

/// Live likes the signed-in user has sent.

final class SentLikesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Like>>,
          List<Like>,
          Stream<List<Like>>
        >
    with $FutureModifier<List<Like>>, $StreamProvider<List<Like>> {
  /// Live likes the signed-in user has sent.
  SentLikesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentLikesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentLikesHash();

  @$internal
  @override
  $StreamProviderElement<List<Like>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Like>> create(Ref ref) {
    return sentLikes(ref);
  }
}

String _$sentLikesHash() => r'3e6c547bb9be82e9872b703c1ea57f148e9afa10';

/// Live likes the signed-in user has received.

@ProviderFor(receivedLikes)
final receivedLikesProvider = ReceivedLikesProvider._();

/// Live likes the signed-in user has received.

final class ReceivedLikesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Like>>,
          List<Like>,
          Stream<List<Like>>
        >
    with $FutureModifier<List<Like>>, $StreamProvider<List<Like>> {
  /// Live likes the signed-in user has received.
  ReceivedLikesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivedLikesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivedLikesHash();

  @$internal
  @override
  $StreamProviderElement<List<Like>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Like>> create(Ref ref) {
    return receivedLikes(ref);
  }
}

String _$receivedLikesHash() => r'ec720886a41b91047a2f136ff82c6796222e2b3e';

/// True when the signed-in user has liked [otherUid]. Live.

@ProviderFor(hasLikedOther)
final hasLikedOtherProvider = HasLikedOtherFamily._();

/// True when the signed-in user has liked [otherUid]. Live.

final class HasLikedOtherProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// True when the signed-in user has liked [otherUid]. Live.
  HasLikedOtherProvider._({
    required HasLikedOtherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasLikedOtherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasLikedOtherHash();

  @override
  String toString() {
    return r'hasLikedOtherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return hasLikedOther(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasLikedOtherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasLikedOtherHash() => r'e668c3dc9e44760fc57a9dabcd8204074a0e881d';

/// True when the signed-in user has liked [otherUid]. Live.

final class HasLikedOtherFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  HasLikedOtherFamily._()
    : super(
        retry: null,
        name: r'hasLikedOtherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// True when the signed-in user has liked [otherUid]. Live.

  HasLikedOtherProvider call(String otherUid) =>
      HasLikedOtherProvider._(argument: otherUid, from: this);

  @override
  String toString() => r'hasLikedOtherProvider';
}

/// Live list of recent visitors to the signed-in user's profile.

@ProviderFor(recentVisitors)
final recentVisitorsProvider = RecentVisitorsProvider._();

/// Live list of recent visitors to the signed-in user's profile.

final class RecentVisitorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileVisitor>>,
          List<ProfileVisitor>,
          Stream<List<ProfileVisitor>>
        >
    with
        $FutureModifier<List<ProfileVisitor>>,
        $StreamProvider<List<ProfileVisitor>> {
  /// Live list of recent visitors to the signed-in user's profile.
  RecentVisitorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentVisitorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentVisitorsHash();

  @$internal
  @override
  $StreamProviderElement<List<ProfileVisitor>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProfileVisitor>> create(Ref ref) {
    return recentVisitors(ref);
  }
}

String _$recentVisitorsHash() => r'adeb37e67ab26971d44ac06cf2cd1582594b5247';
