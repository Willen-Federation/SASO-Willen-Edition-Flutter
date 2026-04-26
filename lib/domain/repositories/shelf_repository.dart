import '../entities/shelf.dart';
import '../value_objects/shelf_id.dart';

abstract interface class ShelfRepository {
  Future<Shelf> fetchById(ShelfId id);
  Future<List<Shelf>> fetchAll();
}
