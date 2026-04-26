import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/datasources/local/item_local_cache.dart';
import 'package:saso_willen_edition/data/models/item_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _item = ItemModel(
  id: '24010001',
  name: 'Test Item',
  categoryId: 'cat001',
  registeredAt: '2024-01-01T00:00:00.000Z',
  features: [
    FeatureModel(
      code: '240100010101',
      colorCode: '01',
      sizeCode: '01',
      stockCount: 5,
    ),
  ],
);

const _itemB = ItemModel(
  id: '24010002',
  name: 'Second Item',
  categoryId: 'cat002',
  registeredAt: '2024-02-01T00:00:00.000Z',
);

Future<Database> _openMemoryDb() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  return factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE items (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category_id TEXT,
            registered_at TEXT NOT NULL,
            updated_at TEXT,
            raw_json TEXT NOT NULL
          )
        ''');
      },
    ),
  );
}

void main() {
  group('InMemoryItemLocalCache', () {
    late InMemoryItemLocalCache cache;

    setUp(() => cache = InMemoryItemLocalCache());

    test('read returns null for unknown id', () async {
      expect(await cache.read('missing'), isNull);
    });

    test('write then read returns the same item', () async {
      await cache.write(_item);
      final out = await cache.read(_item.id);
      expect(out, isNotNull);
      expect(out!.id, _item.id);
      expect(out.name, _item.name);
    });

    test('writeAll persists every item', () async {
      await cache.writeAll([_item, _itemB]);
      expect((await cache.read(_item.id))!.id, _item.id);
      expect((await cache.read(_itemB.id))!.id, _itemB.id);
    });

    test('clear empties the cache', () async {
      await cache.write(_item);
      await cache.clear();
      expect(await cache.read(_item.id), isNull);
    });
  });

  group('SqliteItemLocalCache', () {
    late Database db;
    late SqliteItemLocalCache cache;

    setUp(() async {
      db = await _openMemoryDb();
      cache = SqliteItemLocalCache(db);
    });

    tearDown(() => db.close());

    test('read returns null for unknown id', () async {
      expect(await cache.read('missing'), isNull);
    });

    test('write persists and round-trips ItemModel via raw_json', () async {
      await cache.write(_item);
      final out = await cache.read(_item.id);
      expect(out, isNotNull);
      expect(out!.id, _item.id);
      expect(out.name, _item.name);
      expect(out.features.length, 1);
      expect(out.features.first.code, '240100010101');
    });

    test('write replaces existing row on conflict', () async {
      await cache.write(_item);
      const renamed = ItemModel(
        id: '24010001',
        name: 'Renamed',
        categoryId: 'cat001',
        registeredAt: '2024-01-01T00:00:00.000Z',
      );
      await cache.write(renamed);
      final out = await cache.read('24010001');
      expect(out!.name, 'Renamed');
    });

    test('writeAll batches without partial state on success', () async {
      await cache.writeAll([_item, _itemB]);
      expect((await cache.read(_item.id))!.name, _item.name);
      expect((await cache.read(_itemB.id))!.name, _itemB.name);
    });

    test('clear deletes every row', () async {
      await cache.writeAll([_item, _itemB]);
      await cache.clear();
      expect(await cache.read(_item.id), isNull);
      expect(await cache.read(_itemB.id), isNull);
    });
  });
}
