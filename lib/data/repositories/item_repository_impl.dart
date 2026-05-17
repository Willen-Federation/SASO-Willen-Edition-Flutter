import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/value_objects/item_id.dart';
import '../datasources/local/item_local_cache.dart';
import '../datasources/remote/saso_api_client.dart';

/// Offline-first item repository.
///
/// Reads consult [ItemLocalCache] first; on miss we go to the remote
/// [SasoApiClient] and write the result back through the cache. If the
/// remote call throws (e.g. the device is offline) we fall back to whatever
/// the cache has — staleness is acceptable when the alternative is no data.
class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._apiClient, {ItemLocalCache? cache})
    : _cache = cache ?? InMemoryItemLocalCache();

  final SasoApiClient _apiClient;
  final ItemLocalCache _cache;

  // Backstop for callers that hand us a domain `Item` directly via
  // [cacheItem]. We can't faithfully round-trip a domain object back into
  // an API-shaped `ItemModel` without losing JSON metadata, so manual caches
  // live here in process memory until the next fetch refreshes the durable
  // cache from the wire.
  final Map<String, Item> _domainCache = {};

  @override
  Future<Item> fetchById(ItemId id) async {
    final domainHit = _domainCache[id.value];
    if (domainHit != null) return domainHit;

    final cached = await _cache.read(id.value);
    if (cached != null) return cached.toDomain();

    try {
      final model = await _apiClient.fetchItem(id.value);
      await _cache.write(model);
      return model.toDomain();
    } catch (_) {
      final fallback = await _cache.read(id.value);
      if (fallback != null) return fallback.toDomain();
      rethrow;
    }
  }

  @override
  Future<List<Item>> search({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
    int limit = 20,
  }) async {
    final models = await _apiClient.searchItems(
      query: query,
      categoryId: categoryId,
      barcode: barcode,
      isbn: isbn,
      labelCode: labelCode,
    );
    await _cache.writeAll(models);
    return models.map((m) => m.toDomain()).take(limit).toList();
  }

  @override
  Future<List<Item>> fetchByShelf(String shelfId) async {
    final models = await _apiClient.fetchItemsByShelf(shelfId);
    await _cache.writeAll(models);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> cacheItem(Item item) async {
    _domainCache[item.id.value] = item;
  }

  @override
  Future<Item?> getCached(ItemId id) async {
    final domainHit = _domainCache[id.value];
    if (domainHit != null) return domainHit;
    final model = await _cache.read(id.value);
    return model?.toDomain();
  }

  Future<void> clearCache() async {
    _domainCache.clear();
    await _cache.clear();
  }
}
