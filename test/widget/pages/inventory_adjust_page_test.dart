import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saso_willen_edition/data/models/stock_adjustment_model.dart';
import 'package:saso_willen_edition/presentation/pages/inventory/inventory_adjust_page.dart';
import 'package:saso_willen_edition/presentation/providers/mcp_provider.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

// A minimal router that provides the page under test and a stub scanner route.
GoRouter _buildRouter({String? prefillJanCode, int? prefillItemId}) => GoRouter(
  initialLocation: '/inventory/adjust',
  routes: [
    GoRoute(
      path: '/inventory/adjust',
      builder: (_, __) => InventoryAdjustPage(
        prefillJanCode: prefillJanCode,
        prefillItemId: prefillItemId,
      ),
    ),
    GoRoute(
      path: '/scanner/jan',
      builder: (_, __) => const Scaffold(body: Text('scanner')),
    ),
    GoRoute(
      path: '/scanner',
      builder: (_, __) => const Scaffold(body: Text('scanner')),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const Scaffold(body: Text('home')),
    ),
  ],
);

Widget _buildApp({
  String? prefillJanCode,
  int? prefillItemId,
  bool hasMcp = false,
}) => ProviderScope(
  overrides: [
    // No MCP client unless explicitly requested.
    if (!hasMcp) mcpClientProvider.overrideWithValue(null),
    // Use mock API mode so server config is inert.
    serverConfigNotifierProvider.overrideWith(() => _MockConfig(ApiMode.mock)),
  ],
  child: MaterialApp.router(
    routerConfig: _buildRouter(
      prefillJanCode: prefillJanCode,
      prefillItemId: prefillItemId,
    ),
  ),
);

class _MockConfig extends ServerConfigNotifier {
  _MockConfig(this._mode);
  final ApiMode _mode;

  @override
  ServerConfig build() => ServerConfig(apiMode: _mode);
}

void main() {
  group('InventoryAdjustPage — Phase.shelf (初期)', () {
    testWidgets('shows step 1 shelf scan card', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('棚番号をスキャン'), findsOneWidget);
    });

    testWidgets('shows manual entry button', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('棚番号を手入力'), findsOneWidget);
    });

    testWidgets('submit button is not visible in shelf phase', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('submit_button')), findsNothing);
    });
  });

  group('InventoryAdjustPage — Phase.item (棚確定後)', () {
    // Transition to item phase via manual shelf entry dialog.
    Future<void> pumpAndEnterShelf(WidgetTester tester, String shelf) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Tap manual entry button.
      await tester.tap(find.text('棚番号を手入力'));
      await tester.pumpAndSettle();

      // Fill in the dialog text field.
      await tester.enterText(find.byType(TextField), shelf);
      await tester.tap(find.text('確定'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows confirmed shelf badge after entry', (tester) async {
      await pumpAndEnterShelf(tester, 'A-01');
      expect(find.textContaining('A-01'), findsOneWidget);
    });

    testWidgets('shows step 2 item scan card', (tester) async {
      await pumpAndEnterShelf(tester, 'A-01');
      expect(find.text('商品コードをスキャン'), findsOneWidget);
    });
  });

  group('InventoryAdjustPage — Phase.adjust (両方確定後)', () {
    // Use prefillJanCode to skip phases 1 & 2.
    // With a null MCP client the item stays null but the form is rendered.

    testWidgets('delta defaults to 1', (tester) async {
      await tester.pumpWidget(_buildApp(prefillJanCode: 'test123'));
      await tester.pumpAndSettle();

      final deltaText = tester.widget<Text>(
        find.byKey(const Key('delta_value')),
      );
      expect(deltaText.data, '1');
    });

    testWidgets('tapping + increments delta', (tester) async {
      await tester.pumpWidget(_buildApp(prefillJanCode: 'test123'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delta_increment')));
      await tester.pump();

      final deltaText = tester.widget<Text>(
        find.byKey(const Key('delta_value')),
      );
      expect(deltaText.data, '2');
    });

    testWidgets('tapping − at 1 stays at 1 (button disabled)', (tester) async {
      await tester.pumpWidget(_buildApp(prefillJanCode: 'test123'));
      await tester.pumpAndSettle();

      // The decrement button should be disabled at delta == 1.
      final btn = tester.widget<IconButton>(
        find.byKey(const Key('delta_decrement')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('reason selector shows 3 segments', (tester) async {
      await tester.pumpWidget(_buildApp(prefillJanCode: 'test123'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reason_selector')), findsOneWidget);
      for (final r in AdjustmentReason.values) {
        expect(find.text(r.label), findsOneWidget);
      }
    });

    testWidgets('submit button is present (disabled when item is null)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(prefillJanCode: 'test123'));
      await tester.pumpAndSettle();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('submit_button')),
      );
      // disabled because _item == null (MCP not connected)
      expect(btn.onPressed, isNull);
    });
  });

  group('InventoryAdjustPage — no MCP client', () {
    testWidgets('shows _NoMcpBanner', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('サーバー未接続'), findsOneWidget);
    });
  });
}
