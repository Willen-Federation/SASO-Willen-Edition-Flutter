import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/entities/category.dart';
import 'package:saso_willen_edition/domain/entities/feature.dart';
import 'package:saso_willen_edition/domain/entities/item.dart';
import 'package:saso_willen_edition/domain/repositories/item_repository.dart';
import 'package:saso_willen_edition/domain/value_objects/feature_code.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';
import 'package:saso_willen_edition/presentation/pages/item/item_detail_page.dart';
import 'package:saso_willen_edition/presentation/providers/api_client_provider.dart';

class _StubItemRepository implements ItemRepository {
  final Item item;

  const _StubItemRepository({required this.item});

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

Widget _buildPage({required String itemId}) => ProviderScope(
  overrides: [
    itemRepositoryProvider.overrideWith(
      (_) => _StubItemRepository(item: _testItem),
    ),
  ],
  child: const MaterialApp(home: ItemDetailPage(itemId: '24010001')),
);

void main() {
  group('ItemDetailPage', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows item name after load', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      await tester.pumpAndSettle();
      expect(find.text('テスト商品'), findsOneWidget);
    });

    testWidgets('item name widget has correct key', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('item_name')), findsOneWidget);
    });

    testWidgets('shows item ID', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      await tester.pumpAndSettle();
      expect(find.text('24010001'), findsWidgets);
    });

    testWidgets('shows feature variant', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      await tester.pumpAndSettle();
      expect(find.text('レッド / M'), findsOneWidget);
    });

    testWidgets('shows stock count badge', (tester) async {
      await tester.pumpWidget(_buildPage(itemId: '24010001'));
      await tester.pumpAndSettle();
      expect(find.text('在庫 5'), findsOneWidget);
    });
  });
}
