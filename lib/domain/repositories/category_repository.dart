import '../entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> fetchAll();
  Future<Category?> fetchById(String id);
  Future<List<Category>> fetchChildren(String parentId);
}
