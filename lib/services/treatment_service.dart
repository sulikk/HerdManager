import '../database/database_provider.dart';
import '../models/treatment_model.dart';

class TreatmentService {
  final DatabaseProvider _dbProvider = DatabaseProvider.instance;

  Future<void> insert(Treatment treatment) async {
    final db = await _dbProvider.database;
    await db.insert('treatments', treatment.toMap());
  }

  Future<List<Treatment>> getAll() async {
    final db = await _dbProvider.database;
    final maps = await db.query('treatments', orderBy: 'date DESC');
    return maps.map((e) => Treatment.fromMap(e)).toList();
  }

  Future<void> update(Treatment treatment) async {
    final db = await _dbProvider.database;
    await db.update(
      'treatments',
      treatment.toMap(),
      where: 'id = ?',
      whereArgs: [treatment.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbProvider.database;
    await db.delete('treatments', where: 'id = ?', whereArgs: [id]);
  }
}
