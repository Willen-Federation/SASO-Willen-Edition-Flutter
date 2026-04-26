import '../../models/category_model.dart';
import '../../models/item_model.dart';
import '../../models/shelf_model.dart';
import '../remote/saso_api_client.dart';
import 'mock_data.dart';

/// In-memory mock API client — no server required.
/// Used in debug builds, CI, and integration tests.
class MockApiClient implements SasoApiClient {
  static const _delay = Duration(milliseconds: 300);

  @override
  bool get isMock => true;

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    await Future<void>.delayed(_delay);
    final item = MockData.items.where((i) => i.id == itemId).firstOrNull;
    if (item == null) {
      throw Exception('Item not found: $itemId');
    }
    return item;
  }

  @override
  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
  }) async {
    await Future<void>.delayed(_delay);
    var results = MockData.items;

    if (categoryId != null) {
      results =
          results
              .where(
                (i) =>
                    i.categoryId == categoryId ||
                    i.categoryId.startsWith('$categoryId-'),
              )
              .toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results =
          results
              .where(
                (i) =>
                    i.id.contains(q) ||
                    i.name.toLowerCase().contains(q) ||
                    (i.description?.toLowerCase().contains(q) ?? false),
              )
              .toList();
    }

    return results;
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    await Future<void>.delayed(_delay);
    return MockData.categories;
  }

  @override
  Future<ShelfModel> fetchShelf(String shelfId) async {
    await Future<void>.delayed(_delay);
    final shelf = MockData.shelves.where((s) => s.id == shelfId).firstOrNull;
    if (shelf == null) {
      throw Exception('Shelf not found: $shelfId');
    }
    return shelf;
  }

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async {
    await Future<void>.delayed(_delay);
    final shelf = MockData.shelves.where((s) => s.id == shelfId).firstOrNull;
    if (shelf == null) return [];
    return MockData.items.where((i) => shelf.itemIds.contains(i.id)).toList();
  }
}
