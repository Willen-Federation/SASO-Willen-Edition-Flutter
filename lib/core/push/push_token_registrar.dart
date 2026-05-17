import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../feature_flags/feature_flag_service.dart';
import 'providers/sns_push_service.dart';
import 'push_notification_service.dart';

/// Endpoint the Flutter app calls to register a push token.
/// Matches the SASO API contract from issue #19:
///
///   POST /api/v1/mobile/devices/push-token
///   { "platform": "fcm" | "sns", "token": "<device-token>" }
typedef PushTokenSender =
    Future<void> Function({required String platform, required String token});

/// Registers and refreshes the active platform push token with the backend
/// after a successful pairing. Designed to be called once per session.
class PushTokenRegistrar {
  PushTokenRegistrar({
    required this.send,
    required this.pushService,
    FeatureFlagService? flagService,
  }) : _flags = flagService ?? FeatureFlagService.instance;

  final PushTokenSender send;
  final PushNotificationService pushService;
  final FeatureFlagService _flags;

  StreamSubscription<String>? _refreshSub;
  bool _started = false;

  /// Registers the current FCM/SNS token with the backend and listens for
  /// token rotation events to re-register automatically. Safe to call more
  /// than once — subsequent calls are no-ops.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    if (!pushService.isSupported) return;

    final platform = _activePlatform();
    if (platform == null) return;

    final token = await pushService.getDeviceToken();
    if (token != null && token.isNotEmpty) {
      try {
        await send(platform: platform, token: token);
      } catch (e, st) {
        // Non-fatal — backend will retry on next pairing.
        debugPrint('Push token registration failed: $e\n$st');
      }
    }

    // Subscribe to token-refresh events so we re-register on rotation.
    if (platform == 'fcm') {
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        if (t.isEmpty) return;
        try {
          await send(platform: 'fcm', token: t);
        } catch (e, st) {
          debugPrint('Push token refresh registration failed: $e\n$st');
        }
      });
    }
    // SNS rotation flows through Amplify; SnsPushService keeps the latest
    // token in memory so the next start() call sends it. A long-running
    // listener is not exposed by Amplify's public API.
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    _started = false;
  }

  /// Returns the platform identifier the backend expects, or null when push
  /// notifications are disabled by flag.
  String? _activePlatform() {
    if (_flags.getBool(FeatureFlags.pushSns)) return 'sns';
    if (_flags.getBool(FeatureFlags.pushFcm)) return 'fcm';
    return null;
  }
}

/// Trivial type-check guard so the registrar can adjust behaviour for SNS.
bool isSnsService(PushNotificationService s) => s is SnsPushService;
