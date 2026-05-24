import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/qr_pairing_page.dart';
import '../presentation/pages/category/category_browser_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/inventory/inventory_adjust_page.dart';
import '../presentation/pages/item/item_detail_page.dart';
import '../presentation/pages/item/item_edit_page.dart';
import '../presentation/pages/item/item_register_page.dart';
import '../presentation/pages/item/item_search_page.dart';
import '../presentation/pages/location/location_list_page.dart';
import '../presentation/pages/onboarding/getting_started_page.dart';
import '../presentation/pages/outbox/outbox_page.dart';
import '../presentation/pages/scanner/barcode_scanner_page.dart';
import '../presentation/pages/settings/server_settings_page.dart';
import '../presentation/pages/shelf/shelf_view_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/providers/auth_state_provider.dart';
import '../presentation/providers/server_config_provider.dart';
import 'adaptive_page.dart';
import 'navigator_key.dart';

part 'app_router.g.dart';

/// Routes that are always accessible regardless of auth state.
const _publicPrefixes = ['/splash', '/auth/', '/settings', '/onboarding'];

/// ChangeNotifier that notifies GoRouter when auth state or server config
/// changes, triggering a re-evaluation of the redirect callback.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateNotifierProvider, (_, __) => notifyListeners());
    ref.listen(serverConfigNotifierProvider, (_, __) => notifyListeners());
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Public routes: splash, /auth/*, /settings — always accessible.
      if (_publicPrefixes.any(location.startsWith)) return null;

      final serverConfig = ref.read(serverConfigNotifierProvider);

      // Mock mode never requires authentication.
      if (serverConfig.apiMode == ApiMode.mock) return null;

      // No server URL configured → show Getting Started onboarding.
      if (serverConfig.baseUrl.isEmpty) return '/onboarding';

      // Not authenticated → login.
      final authState = ref.read(authStateNotifierProvider);
      if (!authState.isAuthenticated) return '/auth/login';

      return null;
    },
    // All routes use `pageBuilder` + `adaptivePage(...)` so iOS gets the
    // platform-native left-edge swipe-back gesture (CupertinoPage) while
    // Android keeps its Material slide transition (MaterialPage). See
    // [adaptivePage] for details. Issue #124.
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const GettingStartedPage()),
      ),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: '/auth/qr',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const QrPairingPage()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const ServerSettingsPage()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const HomePage()),
      ),
      GoRoute(
        path: '/items/search',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const ItemSearchPage()),
      ),
      GoRoute(
        path: '/items/:id/edit',
        pageBuilder: (_, state) => adaptivePage(
          state: state,
          child: ItemEditPage(itemId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/items/:id',
        pageBuilder: (_, state) => adaptivePage(
          state: state,
          child: ItemDetailPage(itemId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/scanner',
        pageBuilder: (_, state) {
          final mode = switch (state.uri.queryParameters['mode']) {
            'register' => ScannerMode.register,
            'inventory' => ScannerMode.inventory,
            _ => ScannerMode.search,
          };
          return adaptivePage(
            state: state,
            child: BarcodeScannerPage(mode: mode),
          );
        },
      ),
      // Legacy route kept for backward compatibility.
      GoRoute(
        path: '/scanner/jan',
        pageBuilder: (_, state) => adaptivePage(
          state: state,
          child: const BarcodeScannerPage(mode: ScannerMode.register),
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const CategoryBrowserPage()),
      ),
      GoRoute(
        path: '/shelves/:id',
        pageBuilder: (_, state) => adaptivePage(
          state: state,
          child: ShelfViewPage(shelfId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/items/register',
        pageBuilder: (_, state) {
          final janCode = state.uri.queryParameters['janCode'];
          return adaptivePage(
            state: state,
            child: ItemRegisterPage(prefillJanCode: janCode),
          );
        },
      ),
      GoRoute(
        path: '/inventory/adjust',
        pageBuilder: (_, state) => adaptivePage(
          state: state,
          child: InventoryAdjustPage(
            prefillJanCode: state.uri.queryParameters['janCode'],
            prefillItemId: int.tryParse(
              state.uri.queryParameters['itemId'] ?? '',
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/locations',
        pageBuilder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return adaptivePage(
            state: state,
            child: LocationListPage(
              parentId: extra?['parentId'] as int?,
              parentName: extra?['parentName'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/outbox',
        pageBuilder: (_, state) =>
            adaptivePage(state: state, child: const OutboxPage()),
      ),
    ],
  );
}
