import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/user_location.dart';

/// Reads the device's current location and writes it to the user's profile.
///
/// Implementations live in the data layer; the contract here is pure Dart so
/// it can be mocked in tests and so the application layer never has to
/// import `package:geolocator/...`.
abstract interface class LocationRepository {
  /// Returns the current device permission state. Does **not** trigger a
  /// system dialog — use [requestPermission] for that.
  Future<LocationPermissionState> currentPermission();

  /// Asks the user (via the OS) for location permission. Returns the new
  /// state. Idempotent: calling again after a grant returns `granted`.
  Future<LocationPermissionState> requestPermission();

  /// Reads the device's current position. Throws / returns a `Failure` if
  /// permission is missing, the service is off, or the platform call fails.
  Future<UserLocation> getCurrentLocation();

  /// Persists [location] on the signed-in user's profile (public geohash +
  /// private exact coords). No-op when signed out.
  Future<void> saveLocation(String uid, UserLocation location);
}

/// Domain exception for any failure in the location flow. Carries the
/// permission state at the time of failure so the UI can decide whether
/// to re-prompt or route to system settings.
class LocationException implements Exception {
  LocationException(this.message, {required this.state, this.cause});

  final String message;
  final LocationPermissionState state;
  final Object? cause;

  @override
  String toString() =>
      cause == null
          ? 'LocationException($state): $message'
          : 'LocationException($state): $message ($cause)';
}
