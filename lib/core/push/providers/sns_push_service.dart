import 'package:amplify_flutter/amplify_flutter.dart';

import '../../logging/app_logger.dart';
import '../push_notification_service.dart';

/// Amazon SNS / Pinpoint push service via AWS Amplify.
/// Active when ff_push_sns = true.
/// Infrastructure team sets Pinpoint app ID in lib/amplifyconfiguration.dart
/// (excluded from git for real deployments; stub committed for open-source builds).
class SnsPushService implements PushNotificationService {
  String? _token;
  bool _ready = false;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize() async {
    if (!Amplify.isConfigured) {
      return;
    }
    _ready = true;
    await requestPermission();

    Amplify.Notifications.Push.onTokenReceived.listen((token) {
      _token = token;
      AppLogger.info(
        'Push',
        'SNS Pinpoint token received (${_tokenShape(token)})',
      );
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
  Stream<PushMessage> get onMessage {
    if (!_ready) return const Stream<PushMessage>.empty();
    return Amplify.Notifications.Push.onNotificationReceivedInForeground.map(
      (event) => PushMessage(
        title: event.title ?? '',
        body: event.body ?? '',
        data: Map<String, String>.from(event.data),
      ),
    );
  }

  @override
  Stream<PushMessage> get onMessageOpenedApp {
    if (!_ready) return const Stream<PushMessage>.empty();
    return Amplify.Notifications.Push.onNotificationOpened.map(
      (event) => PushMessage(
        title: event.title ?? '',
        body: event.body ?? '',
        data: Map<String, String>.from(event.data),
      ),
    );
  }

  String _tokenShape(String token) {
    final prefix = token.substring(0, token.length < 6 ? token.length : 6);
    return 'len=${token.length}, prefix=$prefix…';
  }
}
