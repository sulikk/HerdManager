import '../database/database_provider.dart';
import '../models/sale_model.dart';

class SaleService {
  final _dbProvider = DatabaseProvider.instance;

  Future<void> insert(Sale sale) async {
    final db = await _dbProvider.database;
    await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getAll() async {
    final db = await _dbProvider.database;
    final maps = await db.query('sales', orderBy: 'saleDate DESC');
    return maps.map((e) => Sale.fromMap(e)).toList();
  }

  Future<void> delete(int id) async {
    final db = await _dbProvider.database;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Sale sale) async {
    final db = await _dbProvider.database;
    await db.update(
      'sales',
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }
}
