import '../entities/item.dart';
import '../value_objects/item_id.dart';

abstract interface class ItemRepository {
  Future<Item> fetchById(ItemId id);
  Future<List<Item>> search({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
    int limit = 20,
  });
  Future<List<Item>> fetchByShelf(String shelfId);
  Future<void> cacheItem(Item item);
  Future<Item?> getCached(ItemId id);
}
