import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'transaction_model.dart';
import 'transaction_tile.dart';

/// Truyền [transaction] để SỬA, bỏ trống để THÊM.
class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
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
    _amountCtrl =
        TextEditingController(text: t != null ? t.amount.toStringAsFixed(0) : '');
    _noteCtrl = TextEditingController(text: t?.note ?? '');
    _isIncome = t?.isIncome ?? false;
    _category = t?.category ?? _cats.keys.first;
    _date = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
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
      // Tên giao dịch = ghi chú nếu có, ngược lại lấy tên danh mục
      title: _noteCtrl.text.trim().isEmpty
          ? _category
          : _noteCtrl.text.trim().split('\n').first,
      category: _category,
      amount: double.parse(_amountCtrl.text.trim()),
      isIncome: _isIncome,
      date: _date,
      note: _noteCtrl.text.trim(),
    );
    if (_isEdit) {
      await DatabaseHelper.instance.update(t);
    } else {
      await DatabaseHelper.instance.insert(t);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final deleted = await confirmDeleteTransaction(context, widget.transaction!);
    if (deleted && mounted) Navigator.pop(context, true);
  }

  Widget _typeButton(String label, bool income, Color activeColor) {
    final selected = _isIncome == income;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() {
          _isIncome = income;
          _category = _cats.keys.first;
        }),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? activeColor : kBorder),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  InputDecoration _dec({String? hint, Widget? suffix}) => InputDecoration(
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
          if (_isEdit)
            IconButton(
                icon: const Icon(Icons.delete_outline, color: kRed),
                onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              _typeButton('Chi tiêu', false, kRedSoft),
              const SizedBox(width: 10),
              _typeButton('Thu nhập', true, kGreen),
            ]),
            _label('Danh mục'),
            DropdownButtonFormField<String>(
              key: ValueKey(_isIncome), // đổi loại thì dựng lại danh sách
              initialValue: _category,
              decoration: _dec(),
              items: _cats.entries
                  .map((e) => DropdownMenuItem(
                value: e.key,
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: e.value.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(e.value.icon,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(e.key),
                ]),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            _label('Số tiền'),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _dec(
                hint: 'Nhập số tiền',
                suffix: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerRight,
                      child: Text('đ')),
                ),
              ),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Số tiền phải lớn hơn 0';
                return null;
              },
            ),
            _label('Ngày giao dịch'),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: _dec(suffix: const Icon(Icons.calendar_today, size: 18)),
                child: Text(fmtDate(_date)),
              ),
            ),
            _label('Ghi chú'),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: _dec(hint: 'Nhập ghi chú (tùy chọn)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: kBlue,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Lưu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}