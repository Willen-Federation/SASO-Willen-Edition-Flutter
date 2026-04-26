import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/pages/category/category_browser_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/item/item_detail_page.dart';
import '../presentation/pages/item/item_search_page.dart';
import '../presentation/pages/scanner/barcode_scanner_page.dart';
import '../presentation/pages/settings/server_settings_page.dart';
import '../presentation/pages/shelf/shelf_view_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import 'navigator_key.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) => GoRouter(
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
    GoRoute(path: '/scanner', builder: (_, __) => const BarcodeScannerPage()),
    GoRoute(
      path: '/categories',
      builder: (_, __) => const CategoryBrowserPage(),
    ),
    GoRoute(
      path: '/shelves/:id',
      builder:
          (_, state) => ShelfViewPage(shelfId: state.pathParameters['id']!),
    ),
  ],
);
