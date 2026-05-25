import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_state_provider.dart';
import '../../router/app_router.dart';
import '../../router/navigator_key.dart';
import '../auth/auth_provider_config.dart';
import '../logging/app_logger.dart';
import 'providers/amplify_configurator.dart';
import 'providers/sns_push_service.dart';
import 'push_notification_router.dart';
import 'push_notification_service.dart';

/// State provider to hold any push notification deep link route received
/// during app startup (e.g. while SplashPage is active).
final pendingPushRouteProvider = StateProvider<String?>((ref) => null);

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
  StreamSubscription<PushMessage>? _messageSub;
  bool _serviceInitialized = false;

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

    if (service is SnsPushService) {
      if (Amplify.isConfigured) {
        await _setupPushService(service);
        return;
      }
      final discovery = ref.read(serverAuthDiscoveryNotifierProvider);
      if (discovery.providers.isNotEmpty) {
        await AmplifyConfigurator.configure(discovery);
        await _setupPushService(service);
      }
    } else {
      await _setupPushService(service);
    }
  }

  Future<void> _setupPushService(PushNotificationService service) async {
    if (_serviceInitialized) return;

    // Push initialisation is best-effort: APNs may be unavailable in
    // simulators, FirebaseApp may not be configured for non-prod builds,
    // and Amplify may fail to bootstrap when running offline. None of
    // these conditions should block the rest of the app.
    try {
      await service.initialize();
      if (service is SnsPushService && !Amplify.isConfigured) {
        return;
      }

      final initial = await service.getInitialMessage();
      if (initial != null) _routeFromMessage(initial);

      _openedSub?.cancel();
      _openedSub = service.onMessageOpenedApp.listen(_routeFromMessage);

      _messageSub?.cancel();
      _messageSub = service.onMessage.listen(_showForegroundNotification);

      final token = await service.getDeviceToken();
      if (token != null) {
        AppLogger.info('Push', 'Push device token available (${_tokenShape(token)})');
      }
      _serviceInitialized = true;
    } catch (e, stack) {
      _serviceInitialized = false;
      AppLogger.error('Push', 'Push notifications unavailable', e, stack);
    }
  }

  void _routeFromMessage(PushMessage message) {
    final route = message.data?['route'];
    if (route == null) return;

    final router = ref.read(appRouterProvider);
    final currentRoute = router.routerDelegate.currentConfiguration.uri.toString();

    // If the app is currently at the splash screen, we store it as pending
    // so the splash screen redirects to it instead of '/home' upon authentication.
    if (currentRoute == '/splash') {
      ref.read(pendingPushRouteProvider.notifier).state = route;
      return;
    }

    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.go(route);
    }
  }

  void _showForegroundNotification(PushMessage message) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final theme = Theme.of(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
            if (message.body.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                message.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
            ],
          ],
        ),
        action: message.data?['route'] != null
            ? SnackBarAction(
                label: '開く',
                onPressed: () => _routeFromMessage(message),
              )
            : null,
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _openedSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }

  String _tokenShape(String token) {
    final prefix = token.substring(0, token.length < 6 ? token.length : 6);
    return 'len=${token.length}, prefix=$prefix…';
  }

  @override
  Widget build(BuildContext context) {
    // Listen for server discovery updates to configure Amplify on-the-fly
    ref.listen<ServerAuthDiscovery>(
      serverAuthDiscoveryNotifierProvider,
      (previous, next) {
        if (next.providers.isNotEmpty) {
          unawaited(_handleDiscoveryUpdate(next));
        }
      },
    );

    return widget.child;
  }

  Future<void> _handleDiscoveryUpdate(ServerAuthDiscovery discovery) async {
    final service = ref.read(pushNotificationServiceProvider);
    if (service is! SnsPushService || Amplify.isConfigured) {
      return;
    }
    try {
      await AmplifyConfigurator.configure(discovery);
      await _setupPushService(service);
    } catch (e, stack) {
      AppLogger.error('Push', 'Amplify configure failed on discovery update', e, stack);
    }
  }
}
