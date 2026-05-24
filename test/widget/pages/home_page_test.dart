import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saso_willen_edition/presentation/pages/home/home_page.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

class _TestServerConfig extends ServerConfigNotifier {
  _TestServerConfig(this._apiMode);
  final ApiMode _apiMode;

  @override
  ServerConfig build() => ServerConfig(apiMode: _apiMode);
}

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/settings', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/items/search', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/scanner', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/categories', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/shelves/:id', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/items/register', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/locations', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/inventory/adjust', builder: (_, __) => const Scaffold()),
    GoRoute(path: '/outbox', builder: (_, __) => const Scaffold()),
  ],
);

Widget _buildApp(ApiMode apiMode) => ProviderScope(
  overrides: [
    serverConfigNotifierProvider.overrideWith(() => _TestServerConfig(apiMode)),
  ],
  child: MaterialApp.router(routerConfig: _buildRouter()),
);

void main() {
  group('HomePage', () {
    testWidgets('shows mock mode banner in mock mode', (tester) async {
      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();
      expect(find.textContaining('モックモード'), findsOneWidget);
    });

    testWidgets('does not show mock banner in legacy mode', (tester) async {
      await tester.pumpWidget(_buildApp(ApiMode.legacy));
      await tester.pumpAndSettle();
      expect(find.textContaining('モックモード'), findsNothing);
    });

    testWidgets('shows search FAB with correct key', (tester) async {
      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search_fab')), findsOneWidget);
    });

    testWidgets('uses 2 columns on mobile viewport', (tester) async {
      // Phone-sized viewport (<600 logical width) -> 2 columns.
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsOneWidget);
      final grid = tester.widget<SliverGrid>(gridFinder);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('uses 3 columns on tablet viewport', (tester) async {
      // Tablet-sized viewport (>=600 and <1200 logical width) -> 3 columns.
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsOneWidget);
      final grid = tester.widget<SliverGrid>(gridFinder);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('uses 4 columns on desktop viewport', (tester) async {
      // Desktop-sized viewport (>=1200 logical width) -> 4 columns.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsOneWidget);
      final grid = tester.widget<SliverGrid>(gridFinder);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
    });

    testWidgets(
      'menu_inventory_scan card is present when viewport tall enough',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildApp(ApiMode.mock));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('menu_inventory_scan')), findsOneWidget);
        expect(find.text('入出庫スキャン'), findsOneWidget);
      },
    );
  });
}
