import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/models/item_model.dart';
import 'package:saso_willen_edition/domain/entities/item_status.dart';

void main() {
  group('ItemModel status field', () {
    test('parses a snake_case status from JSON', () {
      final model = ItemModel.fromJson(<String, dynamic>{
        'id': '24010001',
        'name': 'テスト商品',
        'categoryId': '1',
        'registeredAt': '2024-01-01T00:00:00.000',
        'status': 'in_storage',
      });

      expect(model.status, 'in_storage');
      expect(model.toDomain().status, ItemStatus.inStorage);
    });

    test('defaults to active when JSON omits status', () {
      final model = ItemModel.fromJson(<String, dynamic>{
        'id': '24010001',
        'name': 'テスト商品',
        'categoryId': '1',
        'registeredAt': '2024-01-01T00:00:00.000',
      });

      expect(model.status, 'active');
      expect(model.toDomain().status, ItemStatus.active);
    });

    test('preserves unknown values through round-trip while domain falls back '
        'to active', () {
      final model = ItemModel.fromJson(<String, dynamic>{
        'id': '24010001',
        'name': 'テスト商品',
        'categoryId': '1',
        'registeredAt': '2024-01-01T00:00:00.000',
        'status': 'future_status',
      });

      // The raw model retains the wire value (forward compatibility) ...
      expect(model.status, 'future_status');
      // ... but the domain projection falls back to a safe default.
      expect(model.toDomain().status, ItemStatus.active);
    });

    test('toJson emits the status field', () {
      final model = ItemModel.fromJson(<String, dynamic>{
        'id': '24010001',
        'name': 'テスト商品',
        'categoryId': '1',
        'registeredAt': '2024-01-01T00:00:00.000',
        'status': 'for_sale',
      });

      expect(model.toJson()['status'], 'for_sale');
    });
  });
}
