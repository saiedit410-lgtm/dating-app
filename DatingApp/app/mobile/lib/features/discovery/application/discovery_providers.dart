import 'package:dating_app/core/firebase/firebase_providers.dart';
import 'package:dating_app/features/discovery/data/firestore_discovery_repository.dart';
import 'package:dating_app/features/discovery/domain/discovery_repository.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_providers.g.dart';

/// The app's [DiscoveryRepository] (Firestore-backed).
@Riverpod(keepAlive: true)
DiscoveryRepository discoveryRepository(Ref ref) =>
    FirestoreDiscoveryRepository(ref.watch(firebaseFirestoreProvider));

/// The set of uids the current user has blocked.
///
/// Blocking ships in a later milestone; this is the seam discovery already
/// honours — any uid emitted here is excluded from the feed and detail views.
@Riverpod(keepAlive: true)
Stream<Set<String>> blockedUids(Ref ref) {
  // TODO(blocking): stream from users/{uid}/private blocklist once it exists.
  return Stream<Set<String>>.value(const <String>{});
}

/// One public profile by id (detail screen / deep links).
@riverpod
Future<PublicProfile?> profileById(Ref ref, String uid) =>
    ref.watch(discoveryRepositoryProvider).fetchProfile(uid);
