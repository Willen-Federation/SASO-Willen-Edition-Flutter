import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Whether the current platform should use Cupertino-style navigation.
///
/// True on iOS (excluding Flutter Web), false everywhere else. iOS users
/// expect the platform-native left-edge swipe-back gesture, which is
/// provided by [CupertinoPageRoute] / [CupertinoPage]. Other platforms
/// keep the standard Material right-to-left slide transition.
bool get _useCupertino => !kIsWeb && Platform.isIOS;

/// Returns a [Page] that uses platform-native page transitions.
///
/// On iOS, returns a [CupertinoPage] (slides from the right, supports the
/// system-wide left-edge swipe-back gesture). On Android / Web / desktop,
/// returns a [MaterialPage] which keeps the standard Material transition.
///
/// Use this helper from `GoRoute.pageBuilder` so swipe-back works
/// throughout the app on iOS while Android keeps its conventional
/// transitions — see Apple HIG "Navigation and search".
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/home',
///   pageBuilder: (context, state) => adaptivePage(
///     state: state,
///     child: const HomePage(),
///   ),
/// )
/// ```
Page<T> adaptivePage<T>({
  required GoRouterState state,
  required Widget child,
  String? name,
  Object? arguments,
}) {
  final pageName = name ?? state.name ?? state.fullPath;
  if (_useCupertino) {
    return CupertinoPage<T>(
      key: state.pageKey,
      name: pageName,
      arguments: arguments,
      child: child,
    );
  }
  return MaterialPage<T>(
    key: state.pageKey,
    name: pageName,
    arguments: arguments,
    child: child,
  );
}

/// Returns a [PageRoute] that uses platform-native page transitions.
///
/// On iOS, returns a [CupertinoPageRoute] (left-edge swipe-back gesture).
/// On Android / Web / desktop, returns a [MaterialPageRoute].
///
/// Use this helper as a drop-in replacement for `MaterialPageRoute` when
/// imperatively pushing a route via `Navigator.push` so swipe-back works
/// on iOS.
///
/// Example:
/// ```dart
/// Navigator.of(context).push<String?>(
///   adaptivePageRoute(builder: (_) => const SomePage()),
/// );
/// ```
PageRoute<T> adaptivePageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
  bool maintainState = true,
}) {
  if (_useCupertino) {
    return CupertinoPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }
  return MaterialPageRoute<T>(
    builder: builder,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    maintainState: maintainState,
  );
}
