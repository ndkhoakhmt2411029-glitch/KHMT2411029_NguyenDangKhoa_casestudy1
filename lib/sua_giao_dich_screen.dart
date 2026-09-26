import 'package:flutter/material.dart';
import 'models.dart';
import 'them_giao_dich_screen.dart';

// Màn hình danh sách giao dịch:
// - Nút "+" -> mở AddEditTransactionScreen() ở chế độ Thêm
// - Bấm vào 1 giao dịch -> mở AddEditTransactionScreen(existingTransaction: ...) ở chế độ Sửa
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final List<Transaction> _transactions = [];

  Future<void> _openAdd() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (result != null) {
      setState(() => _transactions.add(result));
    }
  }

  Future<void> _openEdit(int index) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(existingTransaction: _transactions[index]),
      ),
    );
    if (result != null) {
      setState(() => _transactions[index] = result);
    }
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Giao dịch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('Chưa có giao dịch nào. Bấm + để thêm.'))
          : ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: tx.category.color.withValues(alpha: 0.15),
              child: Icon(tx.category.icon, color: tx.category.color),
            ),
            title: Text(tx.category.name),
            subtitle: Text(
              tx.note.isNotEmpty ? '${_formatDate(tx.date)} • ${tx.note}' : _formatDate(tx.date),
            ),
            trailing: Text(
              '${tx.isExpense ? '-' : '+'}${tx.amount.toStringAsFixed(0)} đ',
              style: TextStyle(
                color: tx.isExpense ? Colors.redAccent : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _openEdit(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        onPressed: _openAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}