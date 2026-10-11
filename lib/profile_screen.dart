import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  double _budget = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final name = await db.getSetting('name') ?? '';
    final email = await db.getSetting('email') ?? '';
    final budget = double.tryParse(await db.getSetting('budget') ?? '') ?? 0;
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
      _budget = budget;
    });
  }

  Future<void> _editInfo() async {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Thông tin cá nhân'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên')),
          TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (ok == true) {
      final db = DatabaseHelper.instance;
      await db.setSetting('name', nameCtrl.text.trim());
      await db.setSetting('email', emailCtrl.text.trim());
      dataVersion.value++; // để Dashboard cập nhật lời chào
      _load();
    }
  }

  Future<void> _editBudget() async {
    final ctrl = TextEditingController(
        text: _budget > 0 ? _budget.toStringAsFixed(0) : '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ngân sách chi tiêu tháng'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              labelText: 'Số tiền', suffixText: 'đ', helperText: 'Nhập 0 để tắt'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(ctrl.text.trim()) ?? 0;
      await DatabaseHelper.instance.setSetting('budget', v.toStringAsFixed(0));
      dataVersion.value++; // để màn Thống kê cập nhật
      _load();
    }
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text('Tất cả giao dịch sẽ bị xóa và không thể khôi phục.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Xóa', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã xóa dữ liệu')));
      }
    }
  }

  Widget _item(IconData icon, String title, VoidCallback onTap,
      {String? trailing, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailing != null)
          Text(trailing,
              style: const TextStyle(color: Colors.black45, fontSize: 12)),
        const Icon(Icons.chevron_right, color: Colors.black38),
      ]),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Cá nhân',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Row(children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFBBD3FA),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name.isEmpty ? 'Người dùng' : _name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(_email.isEmpty ? 'Chưa có email' : _email,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Container(
            decoration: cardDecoration(),
            child: Column(children: [
              _item(Icons.person_outline, 'Thông tin cá nhân', _editInfo),
              const Divider(height: 1),
              _item(Icons.account_balance_wallet_outlined, 'Cài đặt ngân sách',
                  _editBudget,
                  trailing: _budget > 0 ? fmtMoney(_budget) : null),
              const Divider(height: 1),
              _item(Icons.delete_outline, 'Xóa toàn bộ dữ liệu', _clearAll,
                  color: kRed),
            ]),
          ),
        ],
      ),
    );
  }
}