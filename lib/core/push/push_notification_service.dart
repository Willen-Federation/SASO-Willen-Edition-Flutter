import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_service.freezed.dart';

@freezed
abstract class PushMessage with _$PushMessage {
  const factory PushMessage({
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) = _PushMessage;
}

/// Abstract push notification service — implementation selected by feature flags.
abstract interface class PushNotificationService {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  Future<void> requestPermission();

  /// Returns the notification that launched the app from terminated state, or null.
  Future<PushMessage?> getInitialMessage();

  Stream<PushMessage> get onMessage;
  Stream<PushMessage> get onMessageOpenedApp;
  bool get isSupported;
}

/// No-op implementation used when all push flags are disabled.
class NoOpPushService implements PushNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Stream<PushMessage> get onMessage => const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  bool get isSupported => false;
}
