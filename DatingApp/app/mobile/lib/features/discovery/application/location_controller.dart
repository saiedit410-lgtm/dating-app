import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/user_location.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_controller.g.dart';

enum LocationStatus { initial, checking, ready, denied, error }

/// UI-facing state for the location feature. Holds the permission outcome,
/// the most recent [UserLocation] (if any), and a user-friendly error
/// message — controllers elsewhere just observe this and react.
class LocationState {
  const LocationState({
    this.status = LocationStatus.initial,
    this.permission = LocationPermissionState.unknown,
    this.location,
    this.errorMessage,
  });

  final LocationStatus status;
  final LocationPermissionState permission;
  final UserLocation? location;
  final String? errorMessage;

  LocationState copyWith({
    LocationStatus? status,
    LocationPermissionState? permission,
    UserLocation? location,
    String? errorMessage,
    bool clearError = false,
    bool clearLocation = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      location: clearLocation ? null : (location ?? this.location),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Owns the location permission flow + the "refresh my location" action.
/// The nearby tab listens here to decide whether to render the prompt
/// screen or the results.
@riverpod
class LocationController extends _$LocationController {
  @override
  LocationState build() => const LocationState();

  /// Probes the current permission state without prompting. Safe to call
  /// from `initState`; never throws.
  Future<void> checkStatus() async {
    state = state.copyWith(status: LocationStatus.checking, clearError: true);
    final repo = ref.read(locationRepositoryProvider);
    final permission = await repo.currentPermission();
    state = state.copyWith(
      permission: permission,
      status: _statusFor(permission),
      clearError: true,
    );
  }

  /// Requests permission from the OS and reads a position on success.
  Future<void> requestAndCapture() async {
    state = state.copyWith(status: LocationStatus.checking, clearError: true);
    final repo = ref.read(locationRepositoryProvider);
    try {
      final permission = await repo.requestPermission();
      state = state.copyWith(permission: permission);
      if (permission != LocationPermissionState.granted) {
        state = state.copyWith(status: _statusFor(permission));
        return;
      }
      await _capture();
    } on Object catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Re-reads the current device position and persists it. Used by the
  /// "Refresh" action on the nearby tab.
  Future<void> refresh() async {
    if (state.permission != LocationPermissionState.granted) {
      await checkStatus();
      return;
    }
    state = state.copyWith(status: LocationStatus.checking, clearError: true);
    try {
      await _capture();
    } on Object catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _capture() async {
    final repo = ref.read(locationRepositoryProvider);
    final UserLocation loc = await repo.getCurrentLocation();
    final me = ref.read(authStateChangesProvider).value?.uid;
    if (me != null) {
      await repo.saveLocation(me, loc);
    }
    state = state.copyWith(
      location: loc,
      status: LocationStatus.ready,
      clearError: true,
    );
  }

  LocationStatus _statusFor(LocationPermissionState p) {
    switch (p) {
      case LocationPermissionState.granted:
        return LocationStatus.ready;
      case LocationPermissionState.permanentlyDenied:
      case LocationPermissionState.denied:
      case LocationPermissionState.serviceDisabled:
      case LocationPermissionState.notDetermined:
        return LocationStatus.denied;
      case LocationPermissionState.unknown:
        return LocationStatus.initial;
    }
  }
}
