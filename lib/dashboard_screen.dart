import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _money = NumberFormat('#,###', 'vi_VN');
  final _dateFmt = DateFormat('dd/MM/yyyy');

  List<TransactionModel> _items = [];
  double _income = 0, _expense = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.getAll(limit: 10);
    final totals = await DatabaseHelper.instance.getTotals();
    if (!mounted) return;
    setState(() {
      _items = items;
      _income = totals['income']!;
      _expense = totals['expense']!;
      _loading = false;
    });
  }

  String _fmt(double v) => '${_money.format(v)} ₫';

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
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(t.id!);
      _load();
    }
    return false; // list tự reload bằng _load()
  }

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expense;
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thu chi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thẻ số dư
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1E5BFF), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                const Text('SỐ DƯ HIỆN TẠI',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(_fmt(balance),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 16),
            // Tổng thu / chi
            Row(children: [
              Expanded(child: _summaryCard('TỔNG THU NHẬP', _income,
                  Colors.green, Icons.arrow_downward)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('TỔNG CHI TIÊU', _expense,
                  Colors.red, Icons.arrow_upward)),
            ]),
            const SizedBox(height: 20),
            const Text('Giao dịch gần đây',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Chưa có giao dịch nào')),
              )
            else
              ..._items.map(_tile),
            const SizedBox(height: 80), // chừa chỗ cho FAB
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            FittedBox(
              child: Text(_fmt(value),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(TransactionModel t) {
    final color = t.isIncome ? Colors.green : Colors.red;
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(t),
      child: ListTile(
        onTap: () => _openForm(t), // chạm để sửa
        leading: CircleAvatar(
          backgroundColor: t.info.color,
          child: Icon(t.info.icon, color: Colors.white),
        ),
        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${t.category}   ${_dateFmt.format(t.date)}'),
        trailing: Text(
          '${t.isIncome ? '+' : '-'}${_fmt(t.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}