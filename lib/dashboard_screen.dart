import 'package:flutter/material.dart';

// ---------- Model ----------

class TransactionItem {
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isIncome;
  final IconData icon;
  final Color iconBg;

  const TransactionItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconBg,
  });
}

const List<TransactionItem> sampleTransactions = [
  TransactionItem(
    title: 'Ăn trưa',
    category: 'Ăn uống',
    date: '03/09/2024',
    amount: '-50.000 đ',
    isIncome: false,
    icon: Icons.restaurant,
    iconBg: Color(0xFFFF7A45),
  ),
  TransactionItem(
    title: 'Xăng xe',
    category: 'Di chuyển',
    date: '03/09/2024',
    amount: '-100.000 đ',
    isIncome: false,
    icon: Icons.directions_car,
    iconBg: Color(0xFF2F80ED),
  ),
  TransactionItem(
    title: 'Lương tháng 9',
    category: 'Thu nhập',
    date: '01/09/2024',
    amount: '+8.000.000 đ',
    isIncome: true,
    icon: Icons.attach_money,
    iconBg: Color(0xFF27AE60),
  ),
  TransactionItem(
    title: 'Mua sắm',
    category: 'Mua sắm',
    date: '31/08/2024',
    amount: '-300.000 đ',
    isIncome: false,
    icon: Icons.shopping_cart,
    iconBg: Color(0xFF9B51E0),
  ),
  TransactionItem(
    title: 'Học phí',
    category: 'Giáo dục',
    date: '30/08/2024',
    amount: '-500.000 đ',
    isIncome: false,
    icon: Icons.school,
    iconBg: Color(0xFF17A2A2),
  ),
];

// ---------- Screen ----------

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F6FE0),
        shape: const CircleBorder(),
        onPressed: () {
          // TODO: mở màn hình thêm giao dịch
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          const _BalanceCard(),
          const SizedBox(height: 16),
          const _SummaryRow(),
          const SizedBox(height: 20),
          const _RecentTransactionsHeader(),
          const SizedBox(height: 8),
          for (final tx in sampleTransactions) ...[
            _TransactionRow(tx: tx),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () {
          // TODO: mở drawer
        },
      ),
      title: const Text(
        'Quản lý thu chi',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {
                // TODO: mở thông báo
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2F6FE0),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
      ],
    );
  }
}

// ---------- Balance card ----------

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F6FE0), Color(0xFF1E4FB8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'SỐ DƯ HIỆN TẠI',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.visibility, color: Colors.white70, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '5.000.000 đ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(4, (index) {
                  final active = index == 0;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 8 : 6,
                    height: active ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(active ? 1 : 0.5),
                    ),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.25),
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Summary row ----------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'TỔNG THU NHẬP',
            amount: '8.000.000 đ',
            icon: Icons.arrow_downward,
            bg: const Color(0xFFE6F7EC),
            fg: const Color(0xFF27AE60),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'TỔNG CHI TIÊU',
            amount: '3.000.000 đ',
            icon: Icons.arrow_upward,
            bg: const Color(0xFFFDEBEA),
            fg: const Color(0xFFE04B4B),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: fg, size: 16),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}

// ---------- Header ----------

class _RecentTransactionsHeader extends StatelessWidget {
  const _RecentTransactionsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Giao dịch gần đây',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Xem tất cả',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF2F6FE0),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------- Transaction row ----------

class _TransactionRow extends StatelessWidget {
  final TransactionItem tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tx.iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(tx.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category}   ${tx.date}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Text(
            tx.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tx.isIncome ? const Color(0xFF27AE60) : const Color(0xFFE04B4B),
            ),
          ),
        ],
      ),
    );
  }
}