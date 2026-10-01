import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý thu chi',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tongThu = 0;
  int tongChi = 0;
  List<Map<String, Object?>> giaoDich = [];

  @override
  void initState() {
    super.initState();
    taiDuLieu();
  }

  Future<void> taiDuLieu() async {
    final db = DBHelper.instance;
    final thu = await db.tongTheoLoai(1);
    final chi = await db.tongTheoLoai(0);
    final ds = await db.layGiaoDichGanDay(5);
    setState(() {
      tongThu = thu;
      tongChi = chi;
      giaoDich = ds;
    });
  }

  String tien(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.') + ' đ';

  // Nút + tạm thời thêm 1 giao dịch mẫu để thử
  Future<void> themMau() async {
    await DBHelper.instance.themGiaoDich({
      'tieu_de': 'Ăn trưa',
      'so_tien': 50000,
      'loai': 0,
      'ngay': '2024-09-03',
      'ma_danh_muc': 1,
    });
    await taiDuLieu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thu chi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('SỐ DƯ HIỆN TẠI'),
                Text(tien(tongThu - tongChi),
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Thu: ${tien(tongThu)}',
                        style: const TextStyle(color: Colors.green)),
                    Text('Chi: ${tien(tongChi)}',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: giaoDich.length,
              itemBuilder: (context, i) {
                final g = giaoDich[i];
                final laThu = g['loai'] == 1;
                final soTien = g['so_tien'] as int;
                return ListTile(
                  title: Text(g['tieu_de'] as String),
                  subtitle: Text('${g['ten_danh_muc']} - ${g['ngay']}'),
                  trailing: Text(
                    '${laThu ? '+' : '-'}${tien(soTien)}',
                    style: TextStyle(
                        color: laThu ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  onLongPress: () async {
                    await DBHelper.instance.xoaGiaoDich(g['id'] as int);
                    await taiDuLieu();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themMau,
        child: const Icon(Icons.add),
      ),
    );
  }
}