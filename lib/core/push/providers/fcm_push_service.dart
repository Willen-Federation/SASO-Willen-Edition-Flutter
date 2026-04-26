import 'package:firebase_messaging/firebase_messaging.dart';
import '../push_notification_service.dart';

/// Firebase Cloud Messaging push service.
/// Active when ff_push_fcm = true (default ON).
class FcmPushService implements PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    await requestPermission();

    // Show banner + badge + sound when app is in foreground (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background message handler — must be registered before app is launched
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Keep token fresh — backend should be notified on each refresh
    _messaging.onTokenRefresh.listen((token) {
      // Token updates are forwarded to backend by the calling layer
    });
  }

  @override
  Future<String?> getDeviceToken() => _messaging.getToken();

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  /// Returns the notification that opened the app from a terminated state.
  @override
  Future<PushMessage?> getInitialMessage() async {
    final msg = await _messaging.getInitialMessage();
    if (msg == null) return null;
    return PushMessage(
      title: msg.notification?.title ?? '',
      body: msg.notification?.body ?? '',
      data: msg.data.cast<String, String>(),
    );
  }

  @override
  Stream<PushMessage> get onMessage => FirebaseMessaging.onMessage.map(
    (msg) => PushMessage(
      title: msg.notification?.title ?? '',
      body: msg.notification?.body ?? '',
      data: msg.data.cast<String, String>(),
    ),
  );

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(
        (msg) => PushMessage(
          title: msg.notification?.title ?? '',
          body: msg.notification?.body ?? '',
          data: msg.data.cast<String, String>(),
        ),
      );

  @override
  bool get isSupported => true;
}

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Background message handler — must be top-level function.
  // Add Firebase.initializeApp() here if additional Firebase APIs are needed
  // in the background isolate (e.g., Firestore writes).
}
