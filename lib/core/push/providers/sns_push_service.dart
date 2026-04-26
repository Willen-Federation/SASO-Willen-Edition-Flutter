import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_push_notifications_pinpoint/amplify_push_notifications_pinpoint.dart';
import '../../../amplifyconfiguration.dart';
import '../push_notification_service.dart';

/// Amazon SNS / Pinpoint push service via AWS Amplify.
/// Active when ff_push_sns = true.
/// Infrastructure team sets Pinpoint app ID in lib/amplifyconfiguration.dart
/// (excluded from git for real deployments; stub committed for open-source builds).
class SnsPushService implements PushNotificationService {
  String? _token;

  @override
  Future<void> initialize() async {
    if (!Amplify.isConfigured) {
      try {
        await Amplify.addPlugin(AmplifyPushNotificationsPinpoint());
        await Amplify.configure(amplifyconfig);
      } catch (e) {
        // Amplify not configured (stub credentials) — SNS notifications unavailable.
        // Replace lib/amplifyconfiguration.dart with real config to enable.
        return;
      }
    }
    await requestPermission();

    Amplify.Notifications.Push.onTokenReceived.listen((token) {
      _token = token;
    });
  }

  @override
  Future<String?> getDeviceToken() async => _token;

  @override
  Future<void> requestPermission() async {
    try {
      await Amplify.Notifications.Push.requestPermissions();
    } catch (_) {}
  }

  /// Amplify Pinpoint surfaces the launch notification via onNotificationOpened
  /// on first listen; there is no separate "initial message" API.
  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Stream<PushMessage> get onMessage =>
      Amplify.Notifications.Push.onNotificationReceivedInForeground.map(
        (event) => PushMessage(
          title: event.title ?? '',
          body: event.body ?? '',
          data: Map<String, String>.from(event.data),
        ),
      );

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      Amplify.Notifications.Push.onNotificationOpened.map(
        (event) => PushMessage(
          title: event.title ?? '',
          body: event.body ?? '',
          data: Map<String, String>.from(event.data),
        ),
      );

  @override
  bool get isSupported => true;
}
