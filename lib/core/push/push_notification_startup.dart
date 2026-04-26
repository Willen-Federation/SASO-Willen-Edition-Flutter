import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/navigator_key.dart';
import 'push_notification_router.dart';
import 'push_notification_service.dart';

/// Initialises the active push service on startup and routes notification taps
/// to the correct screen without requiring a BuildContext at call time.
///
/// Wrap SasoApp with this widget in main.dart so the push service is alive for
/// the entire application lifecycle.
class PushNotificationStartup extends ConsumerStatefulWidget {
  const PushNotificationStartup({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushNotificationStartup> createState() =>
      _PushNotificationStartupState();
}

class _PushNotificationStartupState
    extends ConsumerState<PushNotificationStartup> {
  StreamSubscription<PushMessage>? _openedSub;

  @override
  void initState() {
    super.initState();
    // Defer until the first frame so GoRouter is initialised and the
    // rootNavigatorKey has a valid context.
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final service = ref.read(pushNotificationServiceProvider);
    if (!service.isSupported) return;

    await service.initialize();

    // Handle notification tap that launched the app from terminated state.
    final initial = await service.getInitialMessage();
    if (initial != null) _routeFromMessage(initial);

    // Handle notification tap when app was backgrounded.
    _openedSub = service.onMessageOpenedApp.listen(_routeFromMessage);
  }

  void _routeFromMessage(PushMessage message) {
    final route = message.data?['route'];
    if (route == null) return;

    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.go(route);
    }
  }

  @override
  void dispose() {
    _openedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
