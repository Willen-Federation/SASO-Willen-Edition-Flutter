import '../../models/category_model.dart';
import '../../models/item_model.dart';
import '../../models/shelf_model.dart';

/// Common interface every SASO backend adapter must implement.
///
/// Migration path:
///   v0.1 → MockApiClient (no server)
///   v0.2 → LegacyApiClient (/item/start, /category/list.json)
///   v1.0 → RestV1ApiClient (/api/v1/*)
abstract interface class SasoApiClient {
  Future<ItemModel> fetchItem(String itemId);
  Future<List<ItemModel>> searchItems({String? query, String? categoryId});
  Future<List<CategoryModel>> fetchCategories();
  Future<ShelfModel> fetchShelf(String shelfId);
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId);
  bool get isMock;
}
