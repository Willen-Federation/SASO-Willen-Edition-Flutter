import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/storage/database_helper.dart';
import '../../models/item_model.dart';

/// Persists `ItemModel` snapshots so the app can serve cached data when the
/// network is unavailable. The repository layer treats this as a write-through
/// cache — every successful API read is mirrored here, and reads check this
/// first when offline.
abstract interface class ItemLocalCache {
  Future<ItemModel?> read(String itemId);
  Future<void> write(ItemModel item);
  Future<void> writeAll(Iterable<ItemModel> items);
  Future<void> clear();
}

/// Volatile cache. Lost on app restart — used as a default for tests and as
/// a fast in-process layer in front of the durable cache.
class InMemoryItemLocalCache implements ItemLocalCache {
  final Map<String, ItemModel> _cache = {};

  @override
  Future<ItemModel?> read(String itemId) async => _cache[itemId];

  @override
  Future<void> write(ItemModel item) async {
    _cache[item.id] = item;
  }

  @override
  Future<void> writeAll(Iterable<ItemModel> items) async {
    for (final item in items) {
      _cache[item.id] = item;
    }
  }

  @override
  Future<void> clear() async => _cache.clear();
}

/// Durable cache backed by the `items` table in [DatabaseHelper]. Stores the
/// full model JSON in `raw_json` so we can round-trip without losing fields
/// the schema doesn't break out into columns.
class SqliteItemLocalCache implements ItemLocalCache {
  SqliteItemLocalCache(this._database);

  final Database _database;

  static const _table = 'items';

  @override
  Future<ItemModel?> read(String itemId) async {
    final rows = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['raw_json'] as String;
    return ItemModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(ItemModel item) async {
    await _database.insert(
      _table,
      _toRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> writeAll(Iterable<ItemModel> items) async {
    final batch = _database.batch();
    for (final item in items) {
      batch.insert(
        _table,
        _toRow(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clear() async => _database.delete(_table);

  Map<String, Object?> _toRow(ItemModel item) => {
    'id': item.id,
    'name': item.name,
    'category_id': item.categoryId,
    'registered_at': item.registeredAt,
    'updated_at': item.updatedAt,
    'raw_json': jsonEncode(item.toJson()),
  };
}
