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

    testWidgets('does not show mock banner in rest mode', (tester) async {
      await tester.pumpWidget(_buildApp(ApiMode.rest));
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

    // ───────────────────────────────────────────────────────────────────
    // TalkBack / VoiceOver accessibility (Issue #151, #132).
    //
    // Verify that every interactive element on the home screen surfaces
    // a semantics node screen readers can announce. Without these, the
    // Google Play Pre-launch report fires an a11y warning and
    // partially-sighted users cannot navigate the app.
    // ───────────────────────────────────────────────────────────────────
    testWidgets('every menu card has a Semantics(button: true) wrapper', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      // Each `_MenuCard` is wrapped in `MergeSemantics > Semantics`.
      // The widget tree also has many *implicit* Semantics nodes (from
      // Card, InkWell etc.), so we filter to the explicit ones that
      // declare a label — these are the ones screen readers announce
      // for the cards.
      const menuLabels = {
        'アイテム検索',
        'バーコードスキャン',
        'アイテム登録',
        '場所管理',
        'カテゴリ',
        '入出庫スキャン',
      };
      final explicitMenuSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => menuLabels.contains(s.properties.label))
          .toList();

      // All six menu cards must be present and announced as buttons.
      expect(
        explicitMenuSemantics.map((s) => s.properties.label).toSet(),
        menuLabels,
      );
      for (final s in explicitMenuSemantics) {
        expect(
          s.properties.button,
          isTrue,
          reason:
              'Menu card "${s.properties.label}" must be announced as a button',
        );
      }
    });

    testWidgets('AppBar settings icon button carries a tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      // IconButton's `tooltip` parameter wires the string into the
      // widget tree as a Tooltip — TalkBack and VoiceOver pick it up
      // through Tooltip's built-in semantics. Asserting the tooltip is
      // present is the unit-test equivalent of confirming the AppBar
      // icon is announced.
      final settingsButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.settings_outlined),
          matching: find.byType(IconButton),
        ),
      );
      expect(settingsButton.tooltip, '設定');
    });

    testWidgets('SASO logo image is excluded from AppBar semantics', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(ApiMode.mock));
      await tester.pumpAndSettle();

      // The adjacent Text('SASO Willen') already conveys the brand name
      // to screen readers, so the logo Image is intentionally wrapped in
      // ExcludeSemantics to avoid VoiceOver reading the brand twice.
      final logoFinder = find.image(
        const AssetImage('assets/images/branding/saso-compact-rounded-256.png'),
      );
      expect(
        find.ancestor(of: logoFinder, matching: find.byType(ExcludeSemantics)),
        findsOneWidget,
      );
    });
  });
}
