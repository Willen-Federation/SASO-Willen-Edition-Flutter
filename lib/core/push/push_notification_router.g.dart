// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushNotificationServiceHash() =>
    r'eb3cab1bfd0659df11aaab8965158bb18d8eaeeb';

/// Selects the active push notification service based on feature flags.
/// SNS takes precedence over FCM when both are enabled.
///
/// Copied from [pushNotificationService].
@ProviderFor(pushNotificationService)
final pushNotificationServiceProvider =
    AutoDisposeProvider<PushNotificationService>.internal(
      pushNotificationService,
      name: r'pushNotificationServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$pushNotificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushNotificationServiceRef =
    AutoDisposeProviderRef<PushNotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
