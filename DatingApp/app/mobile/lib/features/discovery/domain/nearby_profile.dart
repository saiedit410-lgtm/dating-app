import 'package:dating_app/features/discovery/domain/public_profile.dart';

/// A [PublicProfile] enriched with the great-circle distance from the
/// signed-in user. The distance is computed **client-side** from the public
/// geohash (so the UI never needs the owner's exact coordinates).
class NearbyProfile {
  const NearbyProfile({required this.profile, required this.distanceKm});

  final PublicProfile profile;
  final double distanceKm;
}
