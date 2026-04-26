import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/value_objects/item_id.dart';
import '../datasources/remote/saso_api_client.dart';

/// Offline-first item repository.
/// Cache hit → return cached without network.
/// Cache miss → fetch from API, cache result.
class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._apiClient);

  final SasoApiClient _apiClient;

  final Map<String, Item> _cache = {};

  @override
  Future<Item> fetchById(ItemId id) async {
    final cached = _cache[id.value];
    if (cached != null) return cached;

    final model = await _apiClient.fetchItem(id.value);
    final item = model.toDomain();
    _cache[id.value] = item;
    return item;
  }

  @override
  Future<List<Item>> search({
    String? query,
    String? categoryId,
    int limit = 20,
  }) async {
    final models = await _apiClient.searchItems(
      query: query,
      categoryId: categoryId,
    );
    final items = models.map((m) => m.toDomain()).toList();
    for (final item in items) {
      _cache[item.id.value] = item;
    }
    return items.take(limit).toList();
  }

  @override
  Future<List<Item>> fetchByShelf(String shelfId) async {
    final models = await _apiClient.fetchItemsByShelf(shelfId);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> cacheItem(Item item) async {
    _cache[item.id.value] = item;
  }

  @override
  Future<Item?> getCached(ItemId id) async => _cache[id.value];

  void clearCache() => _cache.clear();
}
