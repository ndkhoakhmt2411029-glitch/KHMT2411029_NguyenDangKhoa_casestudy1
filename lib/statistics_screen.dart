import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'transaction_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _periods = ['Tháng này', 'Tháng trước', 'Năm nay'];
  int _period = 0;
  List<MapEntry<String, double>> _byCategory = [];
  double _income = 0, _expense = 0, _budget = 0;

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

  (DateTime, DateTime) _range() {
    final n = DateTime.now();
    switch (_period) {
      case 1:
        return (DateTime(n.year, n.month - 1, 1), DateTime(n.year, n.month, 1));
      case 2:
        return (DateTime(n.year, 1, 1), DateTime(n.year + 1, 1, 1));
      default:
        return (DateTime(n.year, n.month, 1), DateTime(n.year, n.month + 1, 1));
    }
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final (from, to) = _range();
    final cats = await db.categoryTotals(isIncome: false, from: from, to: to);
    final totals = await db.totals(from: from, to: to);
    final budget = double.tryParse(await db.getSetting('budget') ?? '') ?? 0;
    if (!mounted) return;
    setState(() {
      _byCategory = cats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _income = totals['income']!;
      _expense = totals['expense']!;
      _budget = budget;
    });
  }

  Color _color(String name) =>
      kExpenseCategories[name]?.color ?? const Color(0xFF9AA5B1);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Thống kê',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(children: [
              for (int i = 0; i < _periods.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(_periods[i]),
                    selected: _period == i,
                    showCheckmark: false,
                    selectedColor: kBlue,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                        color: _period == i ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: _period == i ? kBlue : kBorder),
                    ),
                    onSelected: (_) {
                      setState(() => _period = i);
                      _load();
                    },
                  ),
                ),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: cardDecoration(),
              child: Column(children: [
                SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(
                      size: const Size(210, 210),
                      painter: _DonutPainter(
                        values: _byCategory.map((e) => e.value).toList(),
                        colors: _byCategory.map((e) => _color(e.key)).toList(),
                      ),
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(fmtMoney(_expense),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('Tổng chi tiêu',
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _mini('Thu nhập', _income, kGreen)),
                  Expanded(child: _mini('Chi tiêu', _expense, kRed)),
                ]),
              ]),
            ),
            if (_period == 0 && _budget > 0) ...[
              const SizedBox(height: 16),
              _budgetCard(),
            ],
            const SizedBox(height: 16),
            const Text('Chi tiêu theo danh mục',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: cardDecoration(),
              child: _byCategory.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Chưa có chi tiêu trong kỳ này')),
              )
                  : Column(children: [
                for (final e in _byCategory)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _color(e.key),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                          kExpenseCategories[e.key]?.icon ?? Icons.help,
                          color: Colors.white,
                          size: 20),
                    ),
                    title: Text(e.key,
                        style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${_expense == 0 ? 0 : (e.value / _expense * 100).toStringAsFixed(1)}%'),
                    trailing: Text(fmtMoney(e.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
              ]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, double v, Color c) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    const SizedBox(height: 2),
    FittedBox(
      child: Text(fmtMoney(v),
          style: TextStyle(color: c, fontWeight: FontWeight.bold)),
    ),
  ]);

  Widget _budgetCard() {
    final ratio = (_expense / _budget).clamp(0.0, 1.0);
    final over = _expense > _budget;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Ngân sách tháng',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${fmtMoney(_expense)} / ${fmtMoney(_budget)}',
              style: TextStyle(
                  fontSize: 12, color: over ? kRed : Colors.black54)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: const Color(0xFFE9EEF7),
            color: over ? kRed : kBlue,
          ),
        ),
        if (over)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Bạn đã chi vượt ngân sách tháng này',
                style: TextStyle(color: kRed, fontSize: 12)),
          ),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final total = values.fold<double>(0, (a, b) => a + b);

    if (total <= 0) {
      paint.color = const Color(0xFFE9EEF7);
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }
    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}