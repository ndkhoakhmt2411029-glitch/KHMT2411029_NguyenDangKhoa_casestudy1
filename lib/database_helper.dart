import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'thu_chi.db');
    return openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          is_income INTEGER NOT NULL,
          date TEXT NOT NULL
        )
      ''');
    });
  }

  Future<int> insert(TransactionModel t) async {
    final db = await database;
    return db.insert('transactions', t.toMap()..remove('id'));
  }

  Future<int> update(TransactionModel t) async {
    final db = await database;
    return db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getAll({int? limit}) async {
    final db = await database;
    final rows =
    await db.query('transactions', orderBy: 'date DESC, id DESC', limit: limit);
    return rows.map(TransactionModel.fromMap).toList();
  }

  /// Trả về {'income': ..., 'expense': ...}
  Future<Map<String, double>> getTotals() async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT is_income, SUM(amount) AS total FROM transactions GROUP BY is_income');
    double income = 0, expense = 0;
    for (final r in rows) {
      final v = (r['total'] as num?)?.toDouble() ?? 0;
      if (r['is_income'] == 1) {
        income = v;
      } else {
        expense = v;
      }
    }
    return {'income': income, 'expense': expense};
  }
}