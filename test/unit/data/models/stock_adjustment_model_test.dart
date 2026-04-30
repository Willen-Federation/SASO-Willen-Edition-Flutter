import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/models/stock_adjustment_model.dart';

void main() {
  group('AdjustmentReason', () {
    test('label returns Japanese', () {
      expect(AdjustmentReason.checkIn.label, '入庫');
      expect(AdjustmentReason.checkOut.label, '出庫');
      expect(AdjustmentReason.audit.label, '棚卸');
    });

    test('mcpValue returns snake_case', () {
      expect(AdjustmentReason.checkIn.mcpValue, 'check_in');
      expect(AdjustmentReason.checkOut.mcpValue, 'check_out');
      expect(AdjustmentReason.audit.mcpValue, 'audit');
    });
  });

  group('StockAdjustmentParams', () {
    test('toArgs without optional fields', () {
      const params = StockAdjustmentParams(
        itemId: 1,
        delta: 5,
        reason: AdjustmentReason.checkIn,
      );
      final args = params.toArgs();
      expect(args['itemId'], 1);
      expect(args['delta'], 5);
      expect(args['reason'], 'check_in');
      expect(args.containsKey('shelfId'), isFalse);
      expect(args.containsKey('locationId'), isFalse);
    });

    test('toArgs includes optional fields when provided', () {
      const params = StockAdjustmentParams(
        itemId: 2,
        delta: -3,
        reason: AdjustmentReason.checkOut,
        shelfId: 'A-01',
        locationId: 99,
      );
      final args = params.toArgs();
      expect(args['reason'], 'check_out');
      expect(args['shelfId'], 'A-01');
      expect(args['locationId'], 99);
    });

    test('negative delta is preserved for checkOut', () {
      const params = StockAdjustmentParams(
        itemId: 3,
        delta: -10,
        reason: AdjustmentReason.checkOut,
      );
      expect(params.toArgs()['delta'], -10);
    });
  });

  group('StockAdjustmentResult', () {
    test('fromJson parses all fields', () {
      final json = {
        'itemId': 10,
        'previousStock': 20,
        'newStock': 25,
        'delta': 5,
      };
      final result = StockAdjustmentResult.fromJson(json);
      expect(result.itemId, 10);
      expect(result.previousStock, 20);
      expect(result.newStock, 25);
      expect(result.delta, 5);
    });
  });
}
