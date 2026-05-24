import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saso_willen_edition/domain/entities/category.dart';
import 'package:saso_willen_edition/presentation/pages/category/category_browser_page.dart';
import 'package:saso_willen_edition/presentation/providers/category_provider.dart';

/// Builds a deeply nested category chain of [depth] levels. The leaf-most
/// category has no children; every other node has exactly one child.
Category _buildDeepChain(int depth, {String prefix = 'cat'}) {
  Category current = Category(
    id: '$prefix-$depth',
    name: 'カテゴリ$depth',
    depth: depth,
  );
  for (var i = depth - 1; i >= 0; i--) {
    current = Category(
      id: '$prefix-$i',
      name: 'カテゴリ$i',
      parentId: i == 0 ? null : '$prefix-${i - 1}',
      depth: i,
      children: [current],
    );
  }
  return current;
}

Widget _buildApp(List<Category> categories) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const CategoryBrowserPage()),
      GoRoute(path: '/items/search', builder: (_, __) => const Scaffold()),
    ],
  );
  return ProviderScope(
    overrides: [
      categoriesProvider.overrideWith((ref) async => categories),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('CategoryBrowserPage depth-padding overflow guard', () {
    testWidgets('depth=10 chain renders every label without exceptions on '
        'iPhone SE width', (tester) async {
      // iPhone SE width / logical pixels.
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp([_buildDeepChain(10)]));
      await tester.pumpAndSettle();

      // Every node label remains in the tree and renders.
      for (var i = 0; i <= 10; i++) {
        expect(
          find.text('カテゴリ$i'),
          findsOneWidget,
          reason: 'depth=$i label should render',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('depth=20 chain still renders without overflow exceptions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp([_buildDeepChain(20)]));
      await tester.pumpAndSettle();

      for (var i = 0; i <= 20; i++) {
        expect(
          find.text('カテゴリ$i'),
          findsOneWidget,
          reason: 'depth=$i label should render',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'left content padding is capped at depth=5 so deep labels keep '
      'usable horizontal space',
      (tester) async {
        await tester.pumpWidget(_buildApp([_buildDeepChain(20)]));
        await tester.pumpAndSettle();

        const expectedCap = 16.0 + 5 * 16; // _kBaseIndent + _kMaxIndentDepth*step

        // Inspect a few deep tiles (depth 6, 10, 20) — all share the cap.
        for (final depth in [6, 10, 20]) {
          final tileFinder = find.ancestor(
            of: find.text('カテゴリ$depth'),
            matching: find.byType(ListTile),
          );
          expect(tileFinder, findsOneWidget, reason: 'tile depth=$depth');
          final tile = tester.widget<ListTile>(tileFinder);
          final padding = tile.contentPadding as EdgeInsets;
          expect(
            padding.left,
            expectedCap,
            reason: 'left padding capped at depth=$depth',
          );
        }
      },
    );

    testWidgets('long labels use ellipsis + maxLines=1', (tester) async {
      const longName =
          'とても長いカテゴリ名カテゴリ名カテゴリ名カテゴリ名カテゴリ名カテゴリ名カテゴリ名カテゴリ名';
      await tester.pumpWidget(
        _buildApp([
          const Category(id: 'c0', name: longName),
        ]),
      );
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(find.text(longName));
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  });
}
