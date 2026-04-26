import 'package:flutter/material.dart';

/// Root navigator key shared between GoRouter and PushNotificationStartup.
/// Allows push notification tap handlers to navigate without a BuildContext.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
