/// Device location permission state as surfaced to the UI.
///
/// Maps onto `geolocator`'s [LocationPermission] (denied / deniedForever /
/// whileInUse / always) plus a separate flag for whether location **services**
/// are turned on (a user can grant permission but have GPS off).
enum LocationPermissionState {
  /// User has not been asked yet (first launch).
  unknown,

  /// Service is on, but the user has not granted the app permission.
  notDetermined,

  /// User explicitly denied the permission once.
  denied,

  /// User picked "Don't ask again" or has denied twice on Android — they
  /// must go to system settings to re-enable it.
  permanentlyDenied,

  /// Permission granted (whileInUse or always).
  granted,

  /// GPS / network location is disabled at the device level.
  serviceDisabled,
}

extension LocationPermissionStateX on LocationPermissionState {
  /// True when we can call `Geolocator.getCurrentPosition()`.
  bool get canRequestPosition =>
      this == LocationPermissionState.granted;

  /// True when the user needs to go to system Settings to recover.
  bool get requiresSystemSettings =>
      this == LocationPermissionState.permanentlyDenied ||
      this == LocationPermissionState.serviceDisabled;
}
