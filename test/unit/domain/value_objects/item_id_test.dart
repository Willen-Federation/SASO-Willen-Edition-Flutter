import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';

void main() {
  group('ItemId', () {
    group('valid IDs', () {
      test('parses standard 8-digit YYMMNNNN format', () {
        final id = ItemId.parse('24010001');
        expect(id.value, '24010001');
      });

      test('parses January (month 01)', () {
        expect(() => ItemId.parse('24010001'), returnsNormally);
      });

      test('parses December (month 12)', () {
        expect(() => ItemId.parse('24120001'), returnsNormally);
      });

      test('parses sequence 0001', () {
        expect(ItemId.parse('24060001').value, '24060001');
      });

      test('parses sequence 9999', () {
        expect(ItemId.parse('24069999').value, '24069999');
      });

      test('equality is value-based', () {
        expect(ItemId.parse('24010001'), equals(ItemId.parse('24010001')));
      });

      test('different values are not equal', () {
        expect(
          ItemId.parse('24010001'),
          isNot(equals(ItemId.parse('24010002'))),
        );
      });
    });

    group('invalid IDs', () {
      test('rejects month 00', () {
        expect(() => ItemId.parse('24000001'), throwsArgumentError);
      });

      test('rejects month 13', () {
        expect(() => ItemId.parse('24130001'), throwsArgumentError);
      });

      test('rejects 7-digit input', () {
        expect(() => ItemId.parse('2401001'), throwsArgumentError);
      });

      test('rejects 9-digit input', () {
        expect(() => ItemId.parse('240100011'), throwsArgumentError);
      });

      test('rejects non-numeric characters', () {
        expect(() => ItemId.parse('2401000A'), throwsArgumentError);
      });

      test('rejects empty string', () {
        expect(() => ItemId.parse(''), throwsArgumentError);
      });
    });

    group('tryParse', () {
      test('returns ItemId for valid input', () {
        expect(ItemId.tryParse('24010001'), isNotNull);
      });

      test('returns null for invalid input', () {
        expect(ItemId.tryParse('invalid'), isNull);
      });

      test('returns null for month 13', () {
        expect(ItemId.tryParse('24130001'), isNull);
      });
    });

    test('isValid returns true for valid format', () {
      expect(ItemId.isValid('24010001'), isTrue);
    });

    test('isValid returns false for invalid format', () {
      expect(ItemId.isValid('invalid'), isFalse);
    });

    test('toString returns value', () {
      expect(ItemId.parse('24010001').toString(), '24010001');
    });
  });
}
