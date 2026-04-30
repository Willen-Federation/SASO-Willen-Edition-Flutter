import 'package:sqflite/sqflite.dart';

import '../../models/pending_registration.dart';

/// DAO for the [pending_registrations] outbox table.
class PendingRegistrationDao {
  const PendingRegistrationDao(this._db);

  final Database _db;

  static const _table = 'pending_registrations';

  Future<int> insert(PendingRegistration reg) =>
      _db.insert(_table, reg.toMap());

  Future<void> updateStatus(
    int id,
    String status, {
    String? errorMessage,
    DateTime? syncedAt,
  }) => _db.update(
    _table,
    <String, dynamic>{
      'status': status,
      'error_message': errorMessage,
      'synced_at': syncedAt?.toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );

  /// Returns all records with status 'pending' or 'failed'.
  Future<List<PendingRegistration>> getPending() async {
    final rows = await _db.query(
      _table,
      where: "status IN ('pending', 'failed')",
      orderBy: 'created_at ASC',
    );
    return rows.map(PendingRegistration.fromMap).toList();
  }

  /// Returns the most recent [limit] records regardless of status.
  Future<List<PendingRegistration>> getAll({int limit = 50}) async {
    final rows = await _db.query(
      _table,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(PendingRegistration.fromMap).toList();
  }

  Future<int> countPending() async {
    final result = await _db.rawQuery(
      "SELECT COUNT(*) AS c FROM $_table WHERE status IN ('pending', 'failed')",
    );
    return (result.first['c'] as int?) ?? 0;
  }
}
