import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._internal();

  DatabaseProvider._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'herd_management.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animals(
        earTagNumber TEXT PRIMARY KEY,
        birthDate TEXT,
        breed TEXT,
        weight REAL,
        origin TEXT,
        notes TEXT,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE treatments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        earTagNumber TEXT,
        date TEXT,
        type TEXT,
        doctor TEXT,
        notes TEXT,
        FOREIGN KEY (earTagNumber) REFERENCES animals (earTagNumber) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        earTagNumber TEXT UNIQUE,
        saleDate TEXT,
        weight REAL,
        price REAL,
        notes TEXT,
        FOREIGN KEY (earTagNumber) REFERENCES animals (earTagNumber) ON DELETE CASCADE
      )
    ''');
  }
}
