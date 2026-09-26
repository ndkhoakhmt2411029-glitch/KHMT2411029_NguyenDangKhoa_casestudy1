import 'package:flutter/material.dart';
import 'models.dart';

// Màn hình dùng chung cho cả THÊM và SỬA giao dịch.
// - Nếu existingTransaction == null  -> chế độ Thêm (tiêu đề "Thêm giao dịch")
// - Nếu existingTransaction != null  -> chế độ Sửa (tiêu đề "Sửa giao dịch", tự điền dữ liệu cũ)
class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddEditTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  late bool _isExpense;
  late Category _selectedCategory;
  late DateTime _selectedDate;

  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;

  bool get _isEditing => widget.existingTransaction != null;

  List<Category> get _currentCategories => CategoryStore.byType(_isExpense);

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    _isExpense = tx?.isExpense ?? true;
    _selectedCategory = tx?.category ?? CategoryStore.byType(_isExpense).first;
    _selectedDate = tx?.date ?? DateTime.now();

    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toStringAsFixed(0) : '',
    );
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _noteController = TextEditingController(text: tx?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  void _onTypeChanged(bool isExpense) {
    if (_isExpense == isExpense) return;
    setState(() {
      _isExpense = isExpense;
      _selectedCategory = CategoryStore.byType(_isExpense).first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _save() {
    final rawText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(rawText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final result = Transaction(
      id: widget.existingTransaction?.id,
      isExpense: _isExpense,
      category: _selectedCategory,
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildLabel('Số tiền'),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration(hint: 'Nhập số tiền', suffix: 'đ'),
              ),
              const SizedBox(height: 16),
              _buildLabel('Ngày giao dịch'),
              const SizedBox(height: 6),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: _fieldDecoration(
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Ghi chú'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: _fieldDecoration(hint: 'Nhập ghi chú (tùy chọn)'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13)),
  );

  InputDecoration _fieldDecoration({String? hint, String? suffix, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onTypeChanged(true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isExpense ? const Color(0xFFFF4D4D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Chi tiêu',
                  style: TextStyle(color: _isExpense ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onTypeChanged(false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isExpense ? const Color(0xFF2ECC71) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Thu nhập',
                  style: TextStyle(color: !_isExpense ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    const addNewValue = '__add_new__';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Danh mục'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedCategory.id,
          decoration: _fieldDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            ..._currentCategories.map(
                  (c) => DropdownMenuItem<String>(
                value: c.id,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(c.icon, size: 16, color: c.color),
                    ),
                    const SizedBox(width: 10),
                    Text(c.name),
                  ],
                ),
              ),
            ),
            const DropdownMenuItem<String>(
              value: addNewValue,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Thêm danh mục mới', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
          onChanged: (value) async {
            if (value == addNewValue) {
              final newCategory = await _showAddCategoryDialog();
              if (newCategory != null) {
                setState(() => _selectedCategory = newCategory);
              }
              return;
            }
            final picked = _currentCategories.firstWhere((c) => c.id == value);
            setState(() => _selectedCategory = picked);
          },
        ),
      ],
    );
  }

  Future<Category?> _showAddCategoryDialog() {
    IconData selectedIcon = pickableIcons.first;
    Color selectedColor = pickableColors.first;
    final nameController = TextEditingController();

    return showDialog<Category>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm danh mục mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên danh mục'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Chọn biểu tượng', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pickableIcons.map((icon) {
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? selectedColor.withValues(alpha: 0.2) : const Color(0xFFF0F0F0),
                              border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                            ),
                            child: Icon(icon, color: isSelected ? selectedColor : Colors.black54),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Chọn màu sắc', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pickableColors.map((color) {
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final newCategory = CategoryStore.addCategory(
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      isExpense: _isExpense,
                    );
                    Navigator.pop(ctx, newCategory);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}