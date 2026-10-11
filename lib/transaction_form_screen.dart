import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'transaction_model.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late bool _isIncome;
  late String _category;
  late DateTime _date;

  bool get _isEdit => widget.transaction != null;
  Map<String, CategoryInfo> get _cats =>
      _isIncome ? kIncomeCategories : kExpenseCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _amountCtrl =
        TextEditingController(text: t != null ? t.amount.toStringAsFixed(0) : '');
    _isIncome = t?.isIncome ?? false;
    _category = t?.category ?? _cats.keys.first;
    _date = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = TransactionModel(
      id: widget.transaction?.id,
      title: _titleCtrl.text.trim(),
      category: _category,
      amount: double.parse(_amountCtrl.text.trim()),
      isIncome: _isIncome,
      date: _date,
    );
    if (_isEdit) {
      await DatabaseHelper.instance.update(t);
    } else {
      await DatabaseHelper.instance.insert(t);
    }
    if (mounted) Navigator.pop(context, true); // true => Dashboard reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Chi tiêu'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: true, label: Text('Thu nhập'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() {
                _isIncome = s.first;
                _category = _cats.keys.first;
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Tên giao dịch', border: OutlineInputBorder()),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Số tiền (₫)', border: OutlineInputBorder()),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Số tiền phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                  labelText: 'Danh mục', border: OutlineInputBorder()),
              items: _cats.entries
                  .map((e) => DropdownMenuItem(
                value: e.key,
                child: Row(children: [
                  Icon(e.value.icon, color: e.value.color, size: 20),
                  const SizedBox(width: 8),
                  Text(e.key),
                ]),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Ngày', border: OutlineInputBorder()),
                child: Text(DateFormat('dd/MM/yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEdit ? 'Cập nhật' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}