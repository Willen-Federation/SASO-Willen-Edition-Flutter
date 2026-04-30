import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/item.dart';
import '../../domain/value_objects/item_id.dart';
import 'api_client_provider.dart';

part 'item_provider.g.dart';

@riverpod
Future<Item> itemById(Ref ref, String id) async {
  final repo = await ref.watch(itemRepositoryProvider.future);
  final itemId = ItemId.parse(id);
  return repo.fetchById(itemId);
}

@riverpod
Future<List<Item>> itemSearch(
  Ref ref, {
  String? query,
  String? categoryId,
}) async {
  if ((query == null || query.isEmpty) && categoryId == null) return [];
  final repo = await ref.watch(itemRepositoryProvider.future);
  return repo.search(query: query, categoryId: categoryId);
}
