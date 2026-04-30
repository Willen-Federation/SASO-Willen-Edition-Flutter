import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'database_helper.g.dart';

@riverpod
Future<DatabaseHelper> databaseHelper(Ref ref) async {
  final helper = DatabaseHelper();
  await helper.initialize();
  return helper;
}

class DatabaseHelper {
  static const _dbName = 'saso.db';
  static const _dbVersion = 3;

  Database? _db;

  Future<void> initialize() async {
    final path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Database get db {
    assert(_db != null, 'DatabaseHelper not initialized');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        raw_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shelves (
        id TEXT PRIMARY KEY,
        label TEXT,
        raw_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_meta (
        key TEXT PRIMARY KEY,
        fetched_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_items_category ON items(category_id)');
    await db.execute(
      'CREATE INDEX idx_categories_parent ON categories(parent_id)',
    );
    await _createPriceHistoryTable(db);
    await _createOutboxTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createPriceHistoryTable(db);
    if (oldVersion < 3) await _createOutboxTables(db);
  }

  Future<void> _createPriceHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isbn TEXT NOT NULL,
        price INTEGER NOT NULL,
        currency TEXT NOT NULL DEFAULT 'JPY',
        source TEXT NOT NULL,
        fetched_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_price_history_isbn ON price_history(isbn)',
    );
  }

  Future<void> _createOutboxTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL DEFAULT 0,
        jan_code TEXT,
        price INTEGER NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        image_path TEXT,
        draft_id TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        error_message TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_adjustments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL DEFAULT '',
        delta INTEGER NOT NULL,
        reason TEXT NOT NULL,
        shelf_id TEXT,
        location_id INTEGER,
        status TEXT NOT NULL DEFAULT 'pending',
        error_message TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pending_reg_status '
      'ON pending_registrations(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pending_adj_status '
      'ON pending_adjustments(status)',
    );
  }

  Future<void> close() async => _db?.close();
}
