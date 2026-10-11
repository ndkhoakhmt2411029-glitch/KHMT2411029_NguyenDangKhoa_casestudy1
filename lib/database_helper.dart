import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'transaction_model.dart';

/// Tăng giá trị này mỗi khi dữ liệu đổi; các màn hình lắng nghe để tự reload.
final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'thu_chi.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            is_income INTEGER NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');
        await _createSettings(db);
      },
      // Nâng cấp từ bản cũ (version 1) mà không mất dữ liệu
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE transactions ADD COLUMN note TEXT NOT NULL DEFAULT ''");
          await _createSettings(db);
        }
      },
    );
  }

  Future<void> _createSettings(Database db) => db.execute(
      'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT)');

  // ---------- CRUD ----------

  Future<int> insert(TransactionModel t) async {
    final db = await database;
    final id = await db.insert('transactions', t.toMap()..remove('id'));
    dataVersion.value++;
    return id;
  }

  Future<int> update(TransactionModel t) async {
    final db = await database;
    final n = await db
        .update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
    dataVersion.value++;
    return n;
  }

  Future<int> delete(int id) async {
    final db = await database;
    final n = await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    dataVersion.value++;
    return n;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
    dataVersion.value++;
  }

  // ---------- Truy vấn ----------

  void _dateWhere(
      List<String> where, List<Object?> args, DateTime? from, DateTime? to) {
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('date < ?');
      args.add(to.toIso8601String());
    }
  }

  /// Danh sách giao dịch, có thể tìm kiếm / lọc.
  Future<List<TransactionModel>> query({
    String? keyword,
    bool? isIncome,
    Set<String>? categories,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];

    if (keyword != null && keyword.trim().isNotEmpty) {
      final k = '%${keyword.trim()}%';
      where.add('(title LIKE ? OR note LIKE ? OR category LIKE ?)');
      args.addAll([k, k, k]);
    }
    if (isIncome != null) {
      where.add('is_income = ?');
      args.add(isIncome ? 1 : 0);
    }
    if (categories != null && categories.isNotEmpty) {
      where.add(
          'category IN (${List.filled(categories.length, '?').join(',')})');
      args.addAll(categories);
    }
    _dateWhere(where, args, from, to);

    final rows = await db.query(
      'transactions',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  /// {'income': ..., 'expense': ...}
  Future<Map<String, double>> totals({DateTime? from, DateTime? to}) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    _dateWhere(where, args, from, to);
    final rows = await db.rawQuery(
      'SELECT is_income, SUM(amount) AS total FROM transactions '
          '${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'} '
          'GROUP BY is_income',
      args,
    );
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

  /// Tổng tiền theo danh mục (cho biểu đồ thống kê)
  Future<Map<String, double>> categoryTotals({
    required bool isIncome,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    final where = <String>['is_income = ?'];
    final args = <Object?>[isIncome ? 1 : 0];
    _dateWhere(where, args, from, to);
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) AS total FROM transactions '
          'WHERE ${where.join(' AND ')} GROUP BY category',
      args,
    );
    return {
      for (final r in rows)
        r['category'] as String: (r['total'] as num).toDouble()
    };
  }

  // ---------- Cài đặt (tên, email, ngân sách...) ----------

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows =
    await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}