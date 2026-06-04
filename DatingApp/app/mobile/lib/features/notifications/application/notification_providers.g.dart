// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceTokenRepository)
final deviceTokenRepositoryProvider = DeviceTokenRepositoryProvider._();

final class DeviceTokenRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceTokenRepository,
          DeviceTokenRepository,
          DeviceTokenRepository
        >
    with $Provider<DeviceTokenRepository> {
  DeviceTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTokenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceTokenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceTokenRepository create(Ref ref) {
    return deviceTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceTokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceTokenRepository>(value),
    );
  }
}

String _$deviceTokenRepositoryHash() =>
    r'4044171cb7226a62ac05242699157c6bd0857e1d';

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'8dd02ebd4010334b02eee323235f2b323b8c4cce';
