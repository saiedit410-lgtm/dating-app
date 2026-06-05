import 'package:dating_app/features/discovery/application/discovery_providers.dart';
import 'package:dating_app/features/discovery/application/location_controller.dart';
import 'package:dating_app/features/discovery/domain/location_permission_state.dart';
import 'package:dating_app/features/discovery/domain/location_repository.dart';
import 'package:dating_app/features/discovery/domain/user_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [LocationRepository] used to drive the controller in tests.
class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository({
    LocationPermissionState initialPermission =
        LocationPermissionState.notDetermined,
    this.permissionOnRequest = LocationPermissionState.granted,
    this.shouldThrow = false,
  }) : permissionOnCheck = initialPermission;

  LocationPermissionState permissionOnCheck;
  final LocationPermissionState permissionOnRequest;
  final bool shouldThrow;

  String? lastSavedUid;
  UserLocation? lastSavedLocation;

  int requestCount = 0;
  int saveCount = 0;

  @override
  Future<LocationPermissionState> currentPermission() async => permissionOnCheck;

  @override
  Future<LocationPermissionState> requestPermission() async {
    requestCount++;
    permissionOnCheck = permissionOnRequest;
    return permissionOnRequest;
  }

  @override
  Future<UserLocation> getCurrentLocation() async {
    if (shouldThrow) {
      throw LocationException(
        'device error',
        state: permissionOnCheck,
      );
    }
    return UserLocation.fromLatLng(
      latitude: 18.52,
      longitude: 73.85,
      updatedAt: DateTime(2026, 6, 6),
    );
  }

  @override
  Future<void> saveLocation(String uid, UserLocation location) async {
    saveCount++;
    lastSavedUid = uid;
    lastSavedLocation = location;
  }
}

void main() {
  late ProviderContainer container;
  late _FakeLocationRepository fake;

  setUp(() {
    fake = _FakeLocationRepository();
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(fake),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('checkStatus reports the current permission state', () async {
    fake.permissionOnCheck = LocationPermissionState.denied;
    await container.read(locationControllerProvider.notifier).checkStatus();
    final s = container.read(locationControllerProvider);
    expect(s.permission, LocationPermissionState.denied);
    expect(s.status, LocationStatus.denied);
  });

  test('requestAndCapture on grant captures a location and saves it', () async {
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    final s = container.read(locationControllerProvider);
    expect(s.status, LocationStatus.ready);
    expect(s.permission, LocationPermissionState.granted);
    expect(s.location, isNotNull);
    expect(fake.requestCount, 1);
  });

  test('requestAndCapture on permanent denial leaves status denied', () async {
    fake = _FakeLocationRepository(
      permissionOnRequest: LocationPermissionState.permanentlyDenied,
    );
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(fake),
      ],
    );
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    final s = container.read(locationControllerProvider);
    expect(s.permission, LocationPermissionState.permanentlyDenied);
    expect(s.status, LocationStatus.denied);
    expect(s.location, isNull);
  });

  test('getCurrentLocation failure surfaces an error status', () async {
    fake = _FakeLocationRepository(
      permissionOnRequest: LocationPermissionState.granted,
      shouldThrow: true,
    );
    container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(fake),
      ],
    );
    await container
        .read(locationControllerProvider.notifier)
        .requestAndCapture();
    final s = container.read(locationControllerProvider);
    expect(s.status, LocationStatus.error);
    expect(s.errorMessage, contains('device error'));
  });
}
