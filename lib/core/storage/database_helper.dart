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
  static const _dbVersion = 1;

  Database? _db;

  Future<void> initialize() async {
    final path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
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
  }

  Future<void> close() async => _db?.close();
}
