import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/datasources/remote/saso_api_client.dart';
import 'package:saso_willen_edition/data/models/category_model.dart';
import 'package:saso_willen_edition/data/models/item_model.dart';
import 'package:saso_willen_edition/data/models/shelf_model.dart';
import 'package:saso_willen_edition/data/repositories/item_repository_impl.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';

class _FakeApiClient implements SasoApiClient {
  int fetchCallCount = 0;
  int searchCallCount = 0;

  static const _item = ItemModel(
    id: '24010001',
    name: 'Test Item',
    categoryId: 'cat001',
    registeredAt: '2024-01-01T00:00:00.000Z',
    features: [
      FeatureModel(
        code: '240100010101',
        colorCode: '01',
        sizeCode: '01',
        stockCount: 5,
      ),
    ],
  );

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    fetchCallCount++;
    return _item;
  }

  @override
  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
  }) async {
    searchCallCount++;
    return [_item];
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async => [];

  @override
  Future<ShelfModel> fetchShelf(String shelfId) async =>
      const ShelfModel(id: 'A-01', label: 'Shelf A-01');

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async => [];

  @override
  Future<ItemModel> createItem(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<ItemModel> updateItem(
    String itemId,
    Map<String, dynamic> patch, {
    String? idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  bool get isMock => true;
}

void main() {
  late _FakeApiClient fakeClient;
  late ItemRepositoryImpl repo;

  setUp(() {
    fakeClient = _FakeApiClient();
    repo = ItemRepositoryImpl(fakeClient);
  });

  group('fetchById — offline-first caching', () {
    test('fetches from API on first call', () async {
      final id = ItemId.parse('24010001');
      await repo.fetchById(id);
      expect(fakeClient.fetchCallCount, 1);
    });

    test('returns cached item on second call without calling API', () async {
      final id = ItemId.parse('24010001');
      await repo.fetchById(id);
      await repo.fetchById(id);
      expect(fakeClient.fetchCallCount, 1);
    });

    test('returned item has correct ID', () async {
      final id = ItemId.parse('24010001');
      final item = await repo.fetchById(id);
      expect(item.id.value, '24010001');
    });

    test('returned item has correct name', () async {
      final id = ItemId.parse('24010001');
      final item = await repo.fetchById(id);
      expect(item.name, 'Test Item');
    });
  });

  group('search', () {
    test('calls API and returns results', () async {
      final results = await repo.search(query: 'test');
      expect(fakeClient.searchCallCount, 1);
      expect(results.length, 1);
    });

    test('caches items found via search', () async {
      await repo.search(query: 'test');
      final id = ItemId.parse('24010001');
      final cached = await repo.getCached(id);
      expect(cached, isNotNull);
    });

    test('respects limit parameter', () async {
      final results = await repo.search(limit: 1);
      expect(results.length, lessThanOrEqualTo(1));
    });
  });

  group('manual cache operations', () {
    test('cacheItem stores item', () async {
      final id = ItemId.parse('24010001');
      final item = await repo.fetchById(id);
      repo.clearCache();

      await repo.cacheItem(item);
      final cached = await repo.getCached(id);
      expect(cached, isNotNull);
      expect(cached!.id.value, '24010001');
    });

    test('getCached returns null for uncached ID', () async {
      final id = ItemId.parse('24020001');
      final cached = await repo.getCached(id);
      expect(cached, isNull);
    });
  });
}
