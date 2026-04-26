import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/item.dart';
import '../../domain/value_objects/item_id.dart';
import 'api_client_provider.dart';

part 'item_provider.g.dart';

@riverpod
Future<Item> itemById(ItemByIdRef ref, String id) async {
  final repo = ref.watch(itemRepositoryProvider);
  final itemId = ItemId.parse(id);
  return repo.fetchById(itemId);
}

@riverpod
Future<List<Item>> itemSearch(
  ItemSearchRef ref, {
  String? query,
  String? categoryId,
}) async {
  if ((query == null || query.isEmpty) && categoryId == null) return [];
  final repo = ref.watch(itemRepositoryProvider);
  return repo.search(query: query, categoryId: categoryId);
}
