import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'filter_screen.dart';
import 'transaction_model.dart';
import 'transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  TxFilter _filter = const TxFilter();
  List<TransactionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
    dataVersion.addListener(_load);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_load);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.instance.query(
      keyword: _searchCtrl.text,
      isIncome: _filter.isIncome,
      categories: _filter.categories,
      from: _filter.from,
      to: _filter.to,
    );
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<TxFilter>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)),
    );
    if (result != null) {
      _filter = result;
      _load();
    }
  }

  void _setType(bool? isIncome) {
    _filter = TxFilter(
        isIncome: isIncome, categories: _filter.categories, range: _filter.range);
    _load();
  }

  Widget _chip(String label, bool? value) {
    final selected = _filter.isIncome == value;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: kBlue,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? kBlue : kBorder),
        ),
        onSelected: (_) => _setType(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Giao dịch',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm giao dịch...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFE9EEF7),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _openFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _filter.isActive ? kBlue : const Color(0xFFE9EEF7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.filter_alt_outlined,
                      color: _filter.isActive ? Colors.white : Colors.black87),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _chip('Tất cả', null),
              _chip('Thu nhập', true),
              _chip('Chi tiêu', false),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  children: [
                    TransactionListCard(items: _items),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}