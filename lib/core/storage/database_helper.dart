import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'database_helper.g.dart';

@riverpod
Future<DatabaseHelper> databaseHelper(DatabaseHelperRef ref) async {
  final helper = DatabaseHelper();
  await helper.initialize();
  return helper;
}

class DatabaseHelper {
  static const _dbName = 'saso.db';
  static const _dbVersion = 2;

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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createPriceHistoryTable(db);
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

  Future<void> close() async => _db?.close();
}
