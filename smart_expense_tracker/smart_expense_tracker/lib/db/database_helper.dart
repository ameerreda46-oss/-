import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'expenses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT
        )
      '''),
    );
  }

  (String, String) _range(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return (start.toIso8601String(), end.toIso8601String());
  }

  Future<int> insert(Expense e) async =>
      (await database).insert('expenses', e.toMap()..remove('id'));

  Future<int> update(Expense e) async => (await database)
      .update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);

  Future<int> delete(int id) async =>
      (await database).delete('expenses', where: 'id = ?', whereArgs: [id]);

  Future<List<Expense>> getByMonth(DateTime month) async {
    final (s, e) = _range(month);
    final rows = await (await database).query('expenses',
        where: 'date >= ? AND date < ?',
        whereArgs: [s, e],
        orderBy: 'date DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<Map<String, double>> totalsByCategory(DateTime month) async {
    final (s, e) = _range(month);
    final rows = await (await database).rawQuery(
        'SELECT category, SUM(amount) AS total FROM expenses '
        'WHERE date >= ? AND date < ? GROUP BY category ORDER BY total DESC',
        [s, e]);
    return {
      for (final r in rows) r['category'] as String: (r['total'] as num).toDouble()
    };
  }

  Future<double> totalForMonth(DateTime month) async {
    final (s, e) = _range(month);
    final rows = await (await database).rawQuery(
        'SELECT SUM(amount) AS total FROM expenses WHERE date >= ? AND date < ?',
        [s, e]);
    return ((rows.first['total'] ?? 0) as num).toDouble();
  }

  /// إجمالي آخر [count] أشهر (الأقدم أولاً)
  Future<List<MapEntry<DateTime, double>>> lastMonthsTotals(int count) async {
    final now = DateTime.now();
    final result = <MapEntry<DateTime, double>>[];
    for (var i = count - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      result.add(MapEntry(m, await totalForMonth(m)));
    }
    return result;
  }
}
