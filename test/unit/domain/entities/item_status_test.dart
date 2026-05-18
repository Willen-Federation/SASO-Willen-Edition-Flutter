import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/entities/item_status.dart';

void main() {
  group('ItemStatus', () {
    test('jsonValue covers all nine canonical wire values', () {
      expect(ItemStatus.active.jsonValue, 'active');
      expect(ItemStatus.archived.jsonValue, 'archived');
      expect(ItemStatus.discontinued.jsonValue, 'discontinued');
      expect(ItemStatus.pending.jsonValue, 'pending');
      expect(ItemStatus.inStorage.jsonValue, 'in_storage');
      expect(ItemStatus.inUse.jsonValue, 'in_use');
      expect(ItemStatus.forSale.jsonValue, 'for_sale');
      expect(ItemStatus.reserved.jsonValue, 'reserved');
      expect(ItemStatus.shipped.jsonValue, 'shipped');
    });

    test('fromJsonValue round-trips every value', () {
      for (final value in ItemStatus.values) {
        expect(ItemStatus.fromJsonValue(value.jsonValue), value);
      }
    });

    test('fromJsonValue falls back to active for null', () {
      expect(ItemStatus.fromJsonValue(null), ItemStatus.active);
    });

    test('fromJsonValue falls back to active for unknown values', () {
      expect(ItemStatus.fromJsonValue('not_a_real_status'), ItemStatus.active);
      expect(ItemStatus.fromJsonValue(''), ItemStatus.active);
    });
  });
}
