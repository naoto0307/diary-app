import '../models/entry.dart';
import 'database_helper.dart';

class EntryRepository {
  EntryRepository({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<void> insert(Entry entry) async {
    final db = await _dbHelper.database;
    await db.insert('entries', entry.toMap());
  }

  Future<List<Entry>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('entries', orderBy: 'created_at DESC');
    return rows.map(Entry.fromMap).toList();
  }

  Future<Entry?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Entry.fromMap(rows.first);
  }

  Future<void> update(Entry entry) async {
    final db = await _dbHelper.database;
    await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
