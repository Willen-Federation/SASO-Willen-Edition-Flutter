import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncValue, Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
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
  String? barcode,
  String? isbn,
  String? labelCode,
}) async {
  final hasInput =
      (query != null && query.isNotEmpty) ||
      categoryId != null ||
      (barcode != null && barcode.isNotEmpty) ||
      (isbn != null && isbn.isNotEmpty) ||
      (labelCode != null && labelCode.isNotEmpty);
  if (!hasInput) return [];
  final repo = await ref.watch(itemRepositoryProvider.future);
  return repo.search(
    query: query,
    categoryId: categoryId,
    barcode: barcode,
    isbn: isbn,
    labelCode: labelCode,
  );
}

/// AsyncNotifier that performs status updates on the server and refreshes
/// the affected [itemByIdProvider]. The notifier itself holds no domain
/// state — its `AsyncValue<void>` simply mirrors the in-flight request so
/// callers can react to loading/error transitions.
@riverpod
class ItemStatusUpdater extends _$ItemStatusUpdater {
  @override
  Future<void> build() async {}

  Future<void> changeStatus(String itemId, ItemStatus newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(itemRepositoryProvider.future);
      await repo.updateStatus(ItemId.parse(itemId), newStatus);
      ref.invalidate(itemByIdProvider(itemId));
    });
  }
}

/// AsyncNotifier that performs general field patches (name, note, codes) and
/// refreshes [itemByIdProvider] on success.
@riverpod
class ItemFieldUpdater extends _$ItemFieldUpdater {
  @override
  Future<void> build() async {}

  Future<void> updateFields(
    String itemId, {
    String? name,
    String? note,
    String? janCode,
    String? isbnCode,
    String? labelCode,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(itemRepositoryProvider.future);
      await repo.updateFields(
        ItemId.parse(itemId),
        name: name,
        note: note,
        janCode: janCode,
        isbnCode: isbnCode,
        labelCode: labelCode,
      );
      ref.invalidate(itemByIdProvider(itemId));
    });
  }
}
