import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// A single page of discovery results plus an opaque pagination cursor.
class DiscoveryPage {
  const DiscoveryPage({
    required this.profiles,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<PublicProfile> profiles;

  /// Opaque cursor for the next page (a Firestore DocumentSnapshot under the
  /// hood). Pass back to [DiscoveryRepository.fetchPage]. Null when exhausted.
  final Object? nextCursor;
  final bool hasMore;
}

/// Reads discoverable public profiles. Implemented by Firestore in the data
/// layer. Only returns profiles with `onboardingComplete == true` and
/// `accountStatus == 'active'`.
abstract interface class DiscoveryRepository {
  Future<DiscoveryPage> fetchPage({
    required int minAge,
    required int maxAge,
    Object? cursor,
    int limit,
  });

  /// One public profile by id (for the detail screen / deep links).
  Future<PublicProfile?> fetchProfile(String uid);
}
