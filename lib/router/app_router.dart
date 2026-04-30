import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
import 'navigator_key.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/settings', builder: (_, __) => const ServerSettingsPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/items/search', builder: (_, __) => const ItemSearchPage()),
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
      builder: (_, __) => const BarcodeScannerPage(mode: ScannerMode.register),
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
