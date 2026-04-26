import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/value_objects/shelf_id.dart';

void main() {
  group('ShelfId', () {
    group('valid IDs', () {
      test('parses single uppercase letter', () {
        expect(ShelfId.parse('A').value, 'A');
      });

      test('parses alphanumeric with hyphen', () {
        expect(ShelfId.parse('A-01').value, 'A-01');
      });

      test('parses 15-character ID (max length)', () {
        expect(ShelfId.parse('ABCDEFGHIJ12345').value, 'ABCDEFGHIJ12345');
      });

      test('converts lowercase to uppercase', () {
        expect(ShelfId.parse('a-01').value, 'A-01');
      });

      test('equality is value-based after normalization', () {
        expect(ShelfId.parse('a-01'), equals(ShelfId.parse('A-01')));
      });
    });

    group('invalid IDs', () {
      test('rejects empty string', () {
        expect(() => ShelfId.parse(''), throwsArgumentError);
      });

      test('rejects 16-character ID (exceeds max)', () {
        expect(() => ShelfId.parse('ABCDEFGHIJ123456'), throwsArgumentError);
      });

      test('rejects special characters', () {
        expect(() => ShelfId.parse('A@01'), throwsArgumentError);
      });

      test('rejects spaces', () {
        expect(() => ShelfId.parse('A 01'), throwsArgumentError);
      });
    });

    group('tryParse', () {
      test('returns ShelfId for valid input', () {
        expect(ShelfId.tryParse('A-01'), isNotNull);
      });

      test('returns null for empty string', () {
        expect(ShelfId.tryParse(''), isNull);
      });

      test('returns null for too-long input', () {
        expect(ShelfId.tryParse('ABCDEFGHIJ123456'), isNull);
      });
    });

    test('isValid returns true for valid ID', () {
      expect(ShelfId.isValid('A-01'), isTrue);
    });

    test('isValid returns false for invalid ID', () {
      expect(ShelfId.isValid(''), isFalse);
    });

    test('toString returns value', () {
      expect(ShelfId.parse('A-01').toString(), 'A-01');
    });
  });
}
