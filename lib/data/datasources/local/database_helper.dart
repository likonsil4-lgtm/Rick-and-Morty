import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@singleton
class DatabaseHelper {
  static const String _databaseName = 'rick_morty.db';
  static const int _databaseVersion = 1;

  static const String tableFavorites = 'favorites';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnStatus = 'status';
  static const String columnSpecies = 'species';
  static const String columnType = 'type';
  static const String columnGender = 'gender';
  static const String columnImage = 'image';
  static const String columnLocation = 'location';
  static const String columnOrigin = 'origin';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFavorites (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnSpecies TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnGender TEXT NOT NULL,
        $columnImage TEXT NOT NULL,
        $columnLocation TEXT NOT NULL,
        $columnOrigin TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertFavorite(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(tableFavorites, row);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query(tableFavorites);
  }

  Future<int> deleteFavorite(int id) async {
    final db = await database;
    return await db.delete(
      tableFavorites,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final result = await db.query(
      tableFavorites,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}