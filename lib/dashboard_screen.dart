import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onSeeAll;
  const DashboardScreen({super.key, required this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _items = [];
  double _income = 0, _expense = 0;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _load();
    dataVersion.addListener(_load);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final items = await db.query(limit: 5);
    final totals = await db.totals();
    final name = await db.getSetting('name') ?? '';
    if (!mounted) return;
    setState(() {
      _items = items;
      _income = totals['income']!;
      _expense = totals['expense']!;
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = _income - _expense;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header xanh + thẻ số dư nổi lên
          SizedBox(
            height: 235,
            child: Stack(
              children: [
                Container(
                  height: 170,
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 16, 20, 0),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name.isEmpty ? 'Xin chào!' : 'Xin chào, $_name!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('Hôm nay là một ngày tốt lành!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFBBD3FA),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: MediaQuery.of(context).padding.top + 80,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 12,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Số dư hiện tại',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(fmtMoney(balance),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE8FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: kBlue),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: _summary('Thu nhập', _income, kGreen,
                          const Color(0xFFE3F5E8), Icons.arrow_upward)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _summary('Chi tiêu', _expense, kRed,
                          const Color(0xFFFDE8E8), Icons.arrow_downward)),
                ]),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chi tiêu gần đây',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: widget.onSeeAll,
                      child: const Text('Xem tất cả',
                          style: TextStyle(
                              color: kBlue, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TransactionListCard(items: _items),
                const SizedBox(height: 90), // chừa chỗ cho nút +
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(
      String label, double value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(fmtMoney(value),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}