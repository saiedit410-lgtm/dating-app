// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [ConnectionRepository] (Firestore-backed).

@ProviderFor(connectionRepository)
final connectionRepositoryProvider = ConnectionRepositoryProvider._();

/// The app's [ConnectionRepository] (Firestore-backed).

final class ConnectionRepositoryProvider
    extends
        $FunctionalProvider<
          ConnectionRepository,
          ConnectionRepository,
          ConnectionRepository
        >
    with $Provider<ConnectionRepository> {
  /// The app's [ConnectionRepository] (Firestore-backed).
  ConnectionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConnectionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionRepository create(Ref ref) {
    return connectionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionRepository>(value),
    );
  }
}

String _$connectionRepositoryHash() =>
    r'9e99351d31a139bfe40e2f72ef467c962109422c';

/// Current relationship between the signed-in user and [otherUid]. Invalidate
/// after an action to refresh the action button.

@ProviderFor(relationship)
final relationshipProvider = RelationshipFamily._();

/// Current relationship between the signed-in user and [otherUid]. Invalidate
/// after an action to refresh the action button.

final class RelationshipProvider
    extends
        $FunctionalProvider<
          AsyncValue<RelationshipState>,
          RelationshipState,
          FutureOr<RelationshipState>
        >
    with
        $FutureModifier<RelationshipState>,
        $FutureProvider<RelationshipState> {
  /// Current relationship between the signed-in user and [otherUid]. Invalidate
  /// after an action to refresh the action button.
  RelationshipProvider._({
    required RelationshipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'relationshipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relationshipHash();

  @override
  String toString() {
    return r'relationshipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RelationshipState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RelationshipState> create(Ref ref) {
    final argument = this.argument as String;
    return relationship(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelationshipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relationshipHash() => r'073327664ea76ecc8fc1be5ed92ac01bc28e1c1b';

/// Current relationship between the signed-in user and [otherUid]. Invalidate
/// after an action to refresh the action button.

final class RelationshipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RelationshipState>, String> {
  RelationshipFamily._()
    : super(
        retry: null,
        name: r'relationshipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Current relationship between the signed-in user and [otherUid]. Invalidate
  /// after an action to refresh the action button.

  RelationshipProvider call(String otherUid) =>
      RelationshipProvider._(argument: otherUid, from: this);

  @override
  String toString() => r'relationshipProvider';
}

/// Live pending requests addressed to the signed-in user.

@ProviderFor(incomingRequests)
final incomingRequestsProvider = IncomingRequestsProvider._();

/// Live pending requests addressed to the signed-in user.

final class IncomingRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FriendRequest>>,
          List<FriendRequest>,
          Stream<List<FriendRequest>>
        >
    with
        $FutureModifier<List<FriendRequest>>,
        $StreamProvider<List<FriendRequest>> {
  /// Live pending requests addressed to the signed-in user.
  IncomingRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<FriendRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FriendRequest>> create(Ref ref) {
    return incomingRequests(ref);
  }
}

String _$incomingRequestsHash() => r'ad8903c1db5595c8c9631c2ef5e2f74a8a92c3cf';
