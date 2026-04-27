import 'package:sqflite/sqflite.dart';

import '../../models/price_history_entry.dart';

/// SQLite DAO for the `price_history` table.
///
/// Call [insertIfChanged] to avoid storing duplicate prices on the same day.
class PriceHistoryDao {
  const PriceHistoryDao(this._db);

  final Database _db;

  static const _table = 'price_history';

  /// Inserts [entry] only when the price is different from the last stored
  /// value for that ISBN (or when there is no prior record at all).
  Future<void> insertIfChanged(PriceHistoryEntry entry) async {
    final last = await _latestEntry(entry.isbn);
    if (last != null && last.price == entry.price) return;
    await _db.insert(_table, entry.toMap());
  }

  /// Always inserts [entry] regardless of prior values.
  Future<void> insert(PriceHistoryEntry entry) async {
    await _db.insert(_table, entry.toMap());
  }

  Future<PriceHistoryEntry?> _latestEntry(String isbn) async {
    final rows = await _db.query(
      _table,
      where: 'isbn = ?',
      whereArgs: [isbn],
      orderBy: 'fetched_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PriceHistoryEntry.fromMap(rows.first);
  }

  Future<List<PriceHistoryEntry>> getHistory(String isbn) async {
    final rows = await _db.query(
      _table,
      where: 'isbn = ?',
      whereArgs: [isbn],
      orderBy: 'fetched_at ASC',
    );
    return rows.map(PriceHistoryEntry.fromMap).toList();
  }

  Future<void> deleteHistory(String isbn) async {
    await _db.delete(_table, where: 'isbn = ?', whereArgs: [isbn]);
  }
}
