import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'transaction_form_screen.dart';

const _kBg = Color(0xFFF7F9FD);
const _kBlue = Color(0xFF2B5FE8);
const _kGreen = Color(0xFF2E9E3F);
const _kRed = Color(0xFFE5393E);
const _kBorder = Color(0xFFE8ECF4);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dateFmt = DateFormat('dd/MM/yyyy');

  List<TransactionModel> _items = [];
  double _income = 0, _expense = 0;
  bool _loading = true;
  bool _hideBalance = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Chỉ tự thêm dữ liệu mẫu 1 lần mỗi lần mở app, và chỉ khi database đang trống
  static bool _seeded = false;

  Future<void> _load() async {
    if (!_seeded) {
      _seeded = true;
      final existing = await DatabaseHelper.instance.getAll(limit: 1);
      if (existing.isEmpty) await _insertSamples();
    }
    final items = await DatabaseHelper.instance.getAll(limit: _showAll ? null : 5);
    final totals = await DatabaseHelper.instance.getTotals();
    if (!mounted) return;
    setState(() {
      _items = items;
      _income = totals['income']!;
      _expense = totals['expense']!;
      _loading = false;
    });
  }

  /// 5000000 -> "5.000.000 ₫"
  String _fmt(double v) =>
      '${NumberFormat('#,###', 'en_US').format(v).replaceAll(',', '.')} ₫';

  Future<void> _openForm([TransactionModel? t]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: t)),
    );
    if (changed == true) _load();
  }

  Future<bool> _confirmDelete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text('Bạn muốn xóa "${t.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(t.id!);
      _load();
    }
    return false; // danh sách tự reload bằng _load()
  }

  /// Nhấn giữ vào tiêu đề để thêm 5 giao dịch mẫu (giống ảnh thiết kế)
  Future<void> _insertSamples() async {
    final db = DatabaseHelper.instance;
    final samples = [
      ('Ăn trưa', 'Ăn uống', 50000.0, false, DateTime(2024, 9, 3)),
      ('Xăng xe', 'Di chuyển', 100000.0, false, DateTime(2024, 9, 3)),
      ('Lương tháng 9', 'Thu nhập', 8000000.0, true, DateTime(2024, 9, 1)),
      ('Mua sắm', 'Mua sắm', 300000.0, false, DateTime(2024, 8, 31)),
      ('Học phí', 'Giáo dục', 500000.0, false, DateTime(2024, 8, 30)),
    ];
    for (final s in samples) {
      await db.insert(TransactionModel(
        title: s.$1,
        category: s.$2,
        amount: s.$3,
        isIncome: s.$4,
        date: s.$5,
      ));
    }
  }

  Future<void> _seedSample() async {
    await _insertSamples();
    _load();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expense;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () {}),
        title: GestureDetector(
          onLongPress: _seedSample,
          child: const Text('Quản lý thu chi',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none,
                  size: 28, color: Colors.black87),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2347D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
                color: Color(0x552B5FE8), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 32),
          onPressed: () => _openForm(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: _kBlue,
        unselectedItemColor: Colors.black87,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (i) {
          if (i == 0) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Màn hình này sẽ làm sau')),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _balanceCard(balance),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _summaryCard('TỔNG THU NHẬP', _income, _kGreen,
                    const Color(0xFFEAF7EC), Icons.arrow_downward),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard('TỔNG CHI TIÊU', _expense, _kRed,
                    const Color(0xFFFDEBEB), Icons.arrow_upward),
              ),
            ]),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giao dịch gần đây',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    setState(() => _showAll = !_showAll);
                    _load();
                  },
                  child: Text(_showAll ? 'Thu gọn' : 'Xem tất cả',
                      style: const TextStyle(
                          color: Color(0xFF1F6FEB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _transactionList(),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(double balance) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C84F5), Color(0xFF2B55E3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('SỐ DƯ HIỆN TẠI',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _hideBalance = !_hideBalance),
                            child: Icon(
                              _hideBalance
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _hideBalance ? '••••••• ₫' : _fmt(balance),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                _walletIllustration(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 16 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: i == 0 ? Colors.white : const Color(0x88FFFFFF),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Hình ví + tiền + đồng xu vẽ bằng icon (thay bằng Image.asset nếu có ảnh thật)
  Widget _walletIllustration() {
    return const SizedBox(
      width: 86,
      height: 84,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              right: 8,
              child: Icon(Icons.payments, color: Color(0xFF63C174), size: 56)),
          Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.account_balance_wallet,
                  color: Color(0xFF263B9E), size: 66)),
          Positioned(
              bottom: 0,
              left: 0,
              child: Icon(Icons.monetization_on,
                  color: Color(0xFFFFC107), size: 34)),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String label, double value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.black87)),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_fmt(value),
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _transactionList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: const Center(
            child: Text('Chưa có giao dịch nào\n(nhấn giữ tiêu đề để thêm dữ liệu mẫu)',
                textAlign: TextAlign.center)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            _tile(_items[i]),
            if (i != _items.length - 1)
              const Divider(height: 1, indent: 14, endIndent: 14, color: _kBorder),
          ],
        ],
      ),
    );
  }

  Widget _tile(TransactionModel t) {
    final color = t.isIncome ? _kGreen : _kRed;
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: _kRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(t),
      child: InkWell(
        onTap: () => _openForm(t), // chạm để sửa
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: t.info.color,
              child: Icon(t.info.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text(t.category,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 22),
                    Text(_dateFmt.format(t.date),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black38)),
                  ]),
                ],
              ),
            ),
            Text(
              '${t.isIncome ? '+' : '-'}${_fmt(t.amount)}',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ]),
        ),
      ),
    );
  }
}