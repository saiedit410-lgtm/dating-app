import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/location_repository.dart';
import 'package:dating_app/features/discovery/domain/user_location.dart';
import 'package:geolocator/geolocator.dart';

/// `geolocator` + Firestore backed [LocationRepository].
///
/// The implementation is split into two responsibilities by design:
///   1. **Read the device** via `Geolocator.*` and translate permission /
///      service states into the domain enum.
///   2. **Persist the result** on the public profile + the private subdoc.
class GeolocatorLocationRepository implements LocationRepository {
  GeolocatorLocationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // ---------- Permission ----------

  @override
  Future<LocationPermissionState> currentPermission() async {
    final bool serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return LocationPermissionState.serviceDisabled;
    return _mapPermission(await Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    final bool serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return LocationPermissionState.serviceDisabled;
    return _mapPermission(await Geolocator.requestPermission());
  }

  // ---------- Position ----------

  @override
  Future<UserLocation> getCurrentLocation() async {
    // Re-check permission/service at read time — the user may have changed
    // either via system Settings between requests.
    final LocationPermissionState state = await currentPermission();
    if (state == LocationPermissionState.serviceDisabled) {
      throw LocationException(
        'Location services are turned off on this device.',
        state: state,
      );
    }
    if (state != LocationPermissionState.granted) {
      throw LocationException(
        'Location permission is required to find people nearby.',
        state: state,
      );
    }
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return UserLocation.fromLatLng(
        latitude: pos.latitude,
        longitude: pos.longitude,
        updatedAt: DateTime.now(),
      );
    } on LocationServiceDisabledException {
      throw LocationException(
        'Location services are turned off on this device.',
        state: LocationPermissionState.serviceDisabled,
      );
    } catch (e) {
      throw LocationException(
        'Could not read your location. Please try again.',
        state: state,
        cause: e,
      );
    }
  }

  // ---------- Persist ----------

  @override
  Future<void> saveLocation(String uid, UserLocation location) async {
    final DocumentReference<Map<String, dynamic>> userDoc =
        _firestore.collection('users').doc(uid);
    final DocumentReference<Map<String, dynamic>> privateDoc =
        userDoc.collection('private').doc('data');

    // Public side: only the geohash and a coarse timestamp. Exact coords
    // never live on the public doc.
    await userDoc.set(<String, Object?>{
      'geohash': location.geohash,
      'geohashPrefixes': location.geohashPrefixes,
      'locationUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Private side: exact lat/lng (owner + admin only via rules).
    await privateDoc.set(<String, Object?>{
      'exactLat': location.latitude,
      'exactLng': location.longitude,
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------- Helpers ----------

  LocationPermissionState _mapPermission(LocationPermission p) {
    switch (p) {
      case LocationPermission.denied:
        return LocationPermissionState.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionState.permanentlyDenied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        return LocationPermissionState.granted;
    }
  }
}
