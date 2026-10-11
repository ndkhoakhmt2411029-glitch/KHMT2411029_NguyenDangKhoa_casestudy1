import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'transaction_model.dart';

class TxFilter {
  final bool? isIncome; // null = tất cả
  final Set<String> categories;
  final DateTimeRange? range;

  const TxFilter({this.isIncome, this.categories = const {}, this.range});

  bool get isActive =>
      isIncome != null || categories.isNotEmpty || range != null;

  DateTime? get from => range?.start;
  // +1 ngày để bao gồm cả ngày cuối
  DateTime? get to =>
      range == null ? null : range!.end.add(const Duration(days: 1));
}

class FilterScreen extends StatefulWidget {
  final TxFilter initial;
  const FilterScreen({super.key, required this.initial});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late bool? _type;
  late Set<String> _cats;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.isIncome;
    _cats = {...widget.initial.categories};
    _range = widget.initial.range;
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  Widget _typeBox(String label, bool? value) {
    return CheckboxListTile(
      value: _type == value,
      onChanged: (_) => setState(() => _type = value),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: kBlue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bộ lọc')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Loại giao dịch',
              style: TextStyle(fontWeight: FontWeight.bold)),
          _typeBox('Tất cả', null),
          _typeBox('Thu nhập', true),
          _typeBox('Chi tiêu', false),
          const SizedBox(height: 12),
          const Text('Danh mục',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final c in kAllCategoryNames)
                FilterChip(
                  label: Text(c),
                  selected: _cats.contains(c),
                  onSelected: (v) =>
                      setState(() => v ? _cats.add(c) : _cats.remove(c)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Khoảng thời gian',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickRange,
            child: InputDecorator(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 18)),
              child: Text(_range == null
                  ? 'Tất cả thời gian'
                  : '${fmtDate(_range!.start)} - ${fmtDate(_range!.end)}'),
            ),
          ),
          if (_range != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () => setState(() => _range = null),
                  child: const Text('Xóa khoảng thời gian')),
            ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, const TxFilter()),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Đặt lại'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(
                    context,
                    TxFilter(isIncome: _type, categories: _cats, range: _range)),
                style: FilledButton.styleFrom(
                    backgroundColor: kBlue,
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Áp dụng'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}