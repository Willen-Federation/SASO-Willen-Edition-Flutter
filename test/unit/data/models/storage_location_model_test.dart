import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/models/storage_location_model.dart';

void main() {
  group('StorageLocationModel.fromJson', () {
    test('parses MCP-shaped payload (camelCase, integer ids)', () {
      final model = StorageLocationModel.fromJson({
        'id': 5,
        'parentId': 1,
        'code': 'A-01-03',
        'name': 'Aisle 1, Shelf 3',
        'depth': 2,
        'position': 3,
        'locationType': 'shelf',
        'operationalStatus': 'active',
        'canReceive': true,
        'canShip': true,
      });

      expect(model.id, 5);
      expect(model.parentId, 1);
      expect(model.code, 'A-01-03');
      expect(model.locationType, 'shelf');
    });

    test(
      'parses REST-shaped payload (camelCase, stringified ids — per OpenAPI)',
      () {
        final model = StorageLocationModel.fromJson({
          'id': '5',
          'parentId': '1',
          'code': 'A-01-03',
          'name': 'Aisle 1, Shelf 3',
          'depth': 2,
          'position': 3,
          'locationType': 'shelf',
          'operationalStatus': 'active',
          'canReceive': true,
          'canShip': true,
        });

        expect(model.id, 5);
        expect(model.parentId, 1);
      },
    );

    test('accepts null parentId for root locations', () {
      final model = StorageLocationModel.fromJson({
        'id': '1',
        'parentId': null,
        'code': 'ROOT',
        'name': 'Root',
        'depth': 0,
        'position': 0,
        'canReceive': true,
        'canShip': true,
      });

      expect(model.parentId, isNull);
    });

    test('accepts snake_case field names for older MCP payloads', () {
      final model = StorageLocationModel.fromJson({
        'id': 7,
        'parent_id': 2,
        'code': 'B-02',
        'name': 'Bin',
        'depth': 1,
        'position': 0,
        'location_type': 'bin',
        'operational_status': 'active',
        'can_receive': false,
        'can_ship': true,
      });

      expect(model.parentId, 2);
      expect(model.locationType, 'bin');
      expect(model.operationalStatus, 'active');
      expect(model.canReceive, isFalse);
      expect(model.canShip, isTrue);
    });
  });
}
