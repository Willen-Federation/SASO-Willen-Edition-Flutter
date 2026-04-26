import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../feature_flags/feature_flag_service.dart';
import 'push_notification_service.dart';
import 'providers/fcm_push_service.dart';
import 'providers/sns_push_service.dart';

part 'push_notification_router.g.dart';

/// Selects the active push notification service based on feature flags.
/// SNS takes precedence over FCM when both are enabled.
@riverpod
PushNotificationService pushNotificationService(
  PushNotificationServiceRef ref,
) {
  final flags = FeatureFlagService.instance;
  final useSns = flags.getBool(FeatureFlags.pushSns);
  final useFcm = flags.getBool(FeatureFlags.pushFcm);

  if (useSns) return SnsPushService();
  if (useFcm) return FcmPushService();
  return NoOpPushService();
}
