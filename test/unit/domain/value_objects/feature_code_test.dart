import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/value_objects/feature_code.dart';

void main() {
  group('FeatureCode', () {
    group('valid codes', () {
      test('parses 12-digit code', () {
        final code = FeatureCode.parse('240100010101');
        expect(code.value, '240100010101');
      });

      test('extracts itemId part (first 8 digits)', () {
        final code = FeatureCode.parse('240100010101');
        expect(code.itemIdPart, '24010001');
      });

      test('extracts color part (digits 9-10)', () {
        final code = FeatureCode.parse('240100010101');
        expect(code.colorPart, '01');
      });

      test('extracts size part (digits 11-12)', () {
        final code = FeatureCode.parse('240100010101');
        expect(code.sizePart, '01');
      });

      test('equality is value-based', () {
        expect(
          FeatureCode.parse('240100010101'),
          equals(FeatureCode.parse('240100010101')),
        );
      });
    });

    group('invalid codes', () {
      test('rejects 11-digit input', () {
        expect(() => FeatureCode.parse('24010001010'), throwsArgumentError);
      });

      test('rejects 13-digit input', () {
        expect(() => FeatureCode.parse('2401000101010'), throwsArgumentError);
      });

      test('rejects non-numeric characters', () {
        expect(() => FeatureCode.parse('2401000101AB'), throwsArgumentError);
      });

      test('rejects empty string', () {
        expect(() => FeatureCode.parse(''), throwsArgumentError);
      });
    });

    group('tryParse', () {
      test('returns FeatureCode for valid input', () {
        expect(FeatureCode.tryParse('240100010101'), isNotNull);
      });

      test('returns null for invalid input', () {
        expect(FeatureCode.tryParse('short'), isNull);
      });
    });

    test('isValid returns true for valid 12-digit code', () {
      expect(FeatureCode.isValid('240100010101'), isTrue);
    });

    test('isValid returns false for invalid code', () {
      expect(FeatureCode.isValid('invalid'), isFalse);
    });

    test('toString returns value', () {
      expect(FeatureCode.parse('240100010101').toString(), '240100010101');
    });
  });
}
