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
import '../presentation/pages/item/item_register_page.dart';
import '../presentation/pages/item/item_search_page.dart';
import '../presentation/pages/location/location_list_page.dart';
import '../presentation/pages/outbox/outbox_page.dart';
import '../presentation/pages/scanner/barcode_scanner_page.dart';
import '../presentation/pages/settings/server_settings_page.dart';
import '../presentation/pages/shelf/shelf_view_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/providers/auth_state_provider.dart';
import '../presentation/providers/server_config_provider.dart';
import 'navigator_key.dart';

part 'app_router.g.dart';

/// Routes that are always accessible regardless of auth state.
const _publicPrefixes = ['/splash', '/auth/', '/settings'];

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

      // No server URL configured → force settings.
      if (serverConfig.baseUrl.isEmpty) return '/settings';

      // Not authenticated → login.
      final authState = ref.read(authStateNotifierProvider);
      if (!authState.isAuthenticated) return '/auth/login';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/auth/qr', builder: (_, __) => const QrPairingPage()),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const ServerSettingsPage(),
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/items/search',
        builder: (_, __) => const ItemSearchPage(),
      ),
      GoRoute(
        path: '/items/:id',
        builder:
            (_, state) => ItemDetailPage(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scanner',
        builder: (_, state) {
          final mode = switch (state.uri.queryParameters['mode']) {
            'register' => ScannerMode.register,
            'inventory' => ScannerMode.inventory,
            _ => ScannerMode.search,
          };
          return BarcodeScannerPage(mode: mode);
        },
      ),
      // Legacy route kept for backward compatibility.
      GoRoute(
        path: '/scanner/jan',
        builder:
            (_, __) => const BarcodeScannerPage(mode: ScannerMode.register),
      ),
      GoRoute(
        path: '/categories',
        builder: (_, __) => const CategoryBrowserPage(),
      ),
      GoRoute(
        path: '/shelves/:id',
        builder:
            (_, state) => ShelfViewPage(shelfId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/items/register',
        builder: (_, state) {
          final janCode = state.uri.queryParameters['janCode'];
          return ItemRegisterPage(prefillJanCode: janCode);
        },
      ),
      GoRoute(
        path: '/inventory/adjust',
        builder:
            (_, state) => InventoryAdjustPage(
              prefillJanCode: state.uri.queryParameters['janCode'],
              prefillItemId: int.tryParse(
                state.uri.queryParameters['itemId'] ?? '',
              ),
            ),
      ),
      GoRoute(
        path: '/locations',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LocationListPage(
            parentId: extra?['parentId'] as int?,
            parentName: extra?['parentName'] as String?,
          );
        },
      ),
      GoRoute(path: '/outbox', builder: (_, __) => const OutboxPage()),
    ],
  );
}
