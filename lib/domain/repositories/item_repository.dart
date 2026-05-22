import '../entities/item.dart';
import '../entities/item_status.dart';
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

  /// Updates the operational status of an item and returns the refreshed
  /// domain entity. Implementations are expected to keep the local cache
  /// in sync (or invalidate it) so subsequent reads observe the new value.
  Future<Item> updateStatus(ItemId id, ItemStatus status);

  /// Patches editable item fields (name, note, JAN/ISBN/label codes) and
  /// returns the refreshed domain entity. Null arguments are omitted from the
  /// PATCH body so callers can update one field at a time.
  Future<Item> updateFields(
    ItemId id, {
    String? name,
    String? note,
    String? janCode,
    String? isbnCode,
    String? labelCode,
  });
}
