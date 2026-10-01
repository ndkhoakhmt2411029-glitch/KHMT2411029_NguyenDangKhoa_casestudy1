import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'thuchi.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE DanhMuc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ten TEXT NOT NULL,
        loai INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE GiaoDich (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tieu_de TEXT NOT NULL,
        so_tien INTEGER NOT NULL,
        loai INTEGER NOT NULL,
        ngay TEXT NOT NULL,
        ma_danh_muc INTEGER,
        FOREIGN KEY (ma_danh_muc) REFERENCES DanhMuc(id)
      )
    ''');

    // Dữ liệu mẫu cho danh mục (loai: 0 = chi, 1 = thu)
    final batch = db.batch();
    batch.insert('DanhMuc', {'ten': 'Ăn uống', 'loai': 0});
    batch.insert('DanhMuc', {'ten': 'Di chuyển', 'loai': 0});
    batch.insert('DanhMuc', {'ten': 'Mua sắm', 'loai': 0});
    batch.insert('DanhMuc', {'ten': 'Giáo dục', 'loai': 0});
    batch.insert('DanhMuc', {'ten': 'Thu nhập', 'loai': 1});
    await batch.commit(noResult: true);
  }

  // ---------- THÊM ----------
  Future<int> themGiaoDich(Map<String, Object?> gd) async {
    final db = await database;
    return db.insert('GiaoDich', gd);
  }

  // ---------- XEM: giao dịch gần đây (kèm tên danh mục) ----------
  Future<List<Map<String, Object?>>> layGiaoDichGanDay(int soLuong) async {
    final db = await database;
    return db.rawQuery('''
      SELECT g.*, d.ten AS ten_danh_muc
      FROM GiaoDich g LEFT JOIN DanhMuc d ON g.ma_danh_muc = d.id
      ORDER BY g.ngay DESC, g.id DESC
      LIMIT ?
    ''', [soLuong]);
  }

  // ---------- SỬA ----------
  Future<int> suaGiaoDich(int id, Map<String, Object?> gd) async {
    final db = await database;
    return db.update('GiaoDich', gd, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- XÓA ----------
  Future<int> xoaGiaoDich(int id) async {
    final db = await database;
    return db.delete('GiaoDich', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- TỔNG THU (loai = 1) / TỔNG CHI (loai = 0) ----------
  Future<int> tongTheoLoai(int loai) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(so_tien), 0) AS tong FROM GiaoDich WHERE loai = ?',
      [loai],
    );
    return (r.first['tong'] as num).toInt();
  }
}