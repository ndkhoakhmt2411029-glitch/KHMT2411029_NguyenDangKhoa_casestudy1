import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'transaction_form_screen.dart';
import 'transaction_model.dart';

/// Hỏi xác nhận rồi xóa. Trả về true nếu đã xóa.
Future<bool> confirmDeleteTransaction(
    BuildContext context, TransactionModel t) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Xóa giao dịch?'),
      content: Text('Bạn muốn xóa "${t.title}"?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Hủy')),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xóa')),
      ],
    ),
  );
  if (ok == true) {
    await DatabaseHelper.instance.delete(t.id!);
    return true;
  }
  return false;
}

class TransactionTile extends StatelessWidget {
  final TransactionModel t;
  const TransactionTile({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final color = t.isIncome ? kGreen : kRed;
    return Dismissible(
      key: ValueKey('tx_${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: kRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Xóa xong danh sách tự reload (dataVersion), nên luôn trả về false
      confirmDismiss: (_) async {
        await confirmDeleteTransaction(context, t);
        return false;
      },
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TransactionFormScreen(transaction: t)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.info.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(t.info.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(fmtDate(t.date),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            Text(
              '${t.isIncome ? '+' : '-'}${fmtMoney(t.amount)}',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ]),
        ),
      ),
    );
  }
}

/// Khối danh sách giao dịch trong thẻ trắng, có đường kẻ ngăn cách.
class TransactionListCard extends StatelessWidget {
  final List<TransactionModel> items;
  const TransactionListCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: cardDecoration(),
        child: const Center(child: Text('Chưa có giao dịch nào')),
      );
    }
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            TransactionTile(t: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }
}