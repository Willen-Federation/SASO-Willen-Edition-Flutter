import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/entities/category.dart';
import 'package:saso_willen_edition/domain/entities/feature.dart';
import 'package:saso_willen_edition/domain/entities/item.dart';
import 'package:saso_willen_edition/domain/entities/item_status.dart';
import 'package:saso_willen_edition/domain/repositories/item_repository.dart';
import 'package:saso_willen_edition/domain/value_objects/feature_code.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/pages/item/item_detail_page.dart';
import 'package:saso_willen_edition/presentation/providers/api_client_provider.dart';

class _StubItemRepository implements ItemRepository {
  _StubItemRepository({required this.item});

  Item item;
  final List<({ItemId id, ItemStatus status})> statusCalls = [];

  @override
  Future<Item> fetchById(ItemId id) async => item;

  @override
  Future<List<Item>> search({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
    int limit = 20,
  }) async => [item];

  @override
  Future<List<Item>> fetchByShelf(String shelfId) async => [item];

  @override
  Future<void> cacheItem(Item item) async {}

  @override
  Future<Item?> getCached(ItemId id) async => null;

  @override
  Future<Item> updateStatus(ItemId id, ItemStatus status) async {
    statusCalls.add((id: id, status: status));
    item = item.copyWith(status: status);
    return item;
  }

  @override
  Future<Item> updateFields(
    ItemId id, {
    String? name,
    String? note,
    String? janCode,
    String? isbnCode,
    String? labelCode,
  }) async {
    item = item.copyWith(
      name: name ?? item.name,
      note: note ?? item.note,
      janCode: janCode ?? item.janCode,
      isbnCode: isbnCode ?? item.isbnCode,
      labelCode: labelCode ?? item.labelCode,
    );
    return item;
  }
}

final _testItem = Item(
  id: ItemId.parse('24010001'),
  name: 'テスト商品',
  category: const Category(id: 'cat001', name: 'テストカテゴリ'),
  registeredAt: DateTime(2024),
  features: [
    Feature(
      code: FeatureCode.parse('240100010101'),
      colorCode: '01',
      sizeCode: '01',
      colorLabel: 'レッド',
      sizeLabel: 'M',
      stockCount: 5,
    ),
  ],
);

Widget _buildPage({_StubItemRepository? repo}) => ProviderScope(
  overrides: [
    itemRepositoryProvider.overrideWith(
      (_) => repo ?? _StubItemRepository(item: _testItem),
    ),
  ],
  child: const MaterialApp(
    locale: Locale('ja'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('ja'), Locale('en')],
    home: ItemDetailPage(itemId: '24010001'),
  ),
);

void main() {
  group('ItemDetailPage', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(_buildPage());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows item name after load', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.text('テスト商品'), findsOneWidget);
    });

    testWidgets('item name widget has correct key', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('item_name')), findsOneWidget);
    });

    testWidgets('shows item ID', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.text('24010001'), findsWidgets);
    });

    testWidgets('shows feature variant', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.text('レッド / M'), findsOneWidget);
    });

    testWidgets('shows stock count badge', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.text('在庫 5'), findsOneWidget);
    });

    testWidgets('renders status badge with current status', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('item_status_badge_button')), findsOneWidget);
      expect(find.text('アクティブ'), findsOneWidget);
    });

    testWidgets('status badge button meets HIG 44x44 minimum touch target '
        '(issue #134)', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      final size = tester.getSize(
        find.byKey(const Key('item_status_badge_button')),
      );
      expect(
        size.width,
        greaterThanOrEqualTo(44),
        reason: 'Touch target width must be ≥44pt per HIG/WCAG',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(44),
        reason: 'Touch target height must be ≥44pt per HIG/WCAG',
      );
    });

    testWidgets('tapping badge opens picker and selecting a status invokes '
        'repository.updateStatus', (tester) async {
      final repo = _StubItemRepository(item: _testItem);
      await tester.pumpWidget(_buildPage(repo: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('item_status_badge_button')));
      await tester.pumpAndSettle();

      // Confirm the picker actually rendered.
      expect(find.byKey(const Key('status_option_active')), findsOneWidget);

      final option = find.byKey(const Key('status_option_in_storage'));
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(repo.statusCalls, hasLength(1));
      expect(repo.statusCalls.single.status, ItemStatus.inStorage);
    });
  });
}
