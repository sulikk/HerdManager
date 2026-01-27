import '../database/database_provider.dart';
import '../models/animal_model.dart';

class AnimalService {
  final DatabaseProvider _dbProvider = DatabaseProvider.instance;

  Future<void> insert(Animal animal) async {
    final db = await _dbProvider.database;
    await db.insert('animals', animal.toMap());
  }

  Future<List<Animal>> getAll() async {
    final db = await _dbProvider.database;
    final maps = await db.query('animals');
    return maps.map((e) => Animal.fromMap(e)).toList();
  }

  Future<Animal?> getByEarTag(String earTagNumber) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'animals',
      where: 'earTagNumber = ?',
      whereArgs: [earTagNumber],
      limit: 1,
    );

    return result.isNotEmpty ? Animal.fromMap(result.first) : null;
  }

  Future<void> update(Animal animal) async {
    final db = await _dbProvider.database;
    await db.update(
      'animals',
      animal.toMap(),
      where: 'earTagNumber = ?',
      whereArgs: [animal.earTagNumber],
    );
  }

  Future<void> delete(String earTagNumber) async {
    final db = await _dbProvider.database;
    await db.delete(
      'animals',
      where: 'earTagNumber = ?',
      whereArgs: [earTagNumber],
    );
  }
}
