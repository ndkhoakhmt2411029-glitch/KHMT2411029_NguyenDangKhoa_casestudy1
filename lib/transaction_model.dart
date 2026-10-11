import 'package:flutter/material.dart';

class CategoryInfo {
  final IconData icon;
  final Color color;
  const CategoryInfo(this.icon, this.color);
}

const Map<String, CategoryInfo> kExpenseCategories = {
  'Ăn uống': CategoryInfo(Icons.restaurant, Color(0xFFFF6B6B)),
  'Di chuyển': CategoryInfo(Icons.directions_car, Color(0xFF4C8DF6)),
  'Mua sắm': CategoryInfo(Icons.shopping_cart, Color(0xFF3FA9F5)),
  'Giáo dục': CategoryInfo(Icons.menu_book, Color(0xFF9B6CF2)),
  'Giải trí': CategoryInfo(Icons.sports_esports, Color(0xFFF5A623)),
  'Khác': CategoryInfo(Icons.more_horiz, Color(0xFF9AA5B1)),
};

const Map<String, CategoryInfo> kIncomeCategories = {
  'Lương': CategoryInfo(Icons.payments, Color(0xFF34C77B)),
  'Thu nhập': CategoryInfo(Icons.attach_money, Color(0xFF2EA043)),
  'Thưởng': CategoryInfo(Icons.card_giftcard, Color(0xFFE95FA0)),
  'Khác': CategoryInfo(Icons.more_horiz, Color(0xFF9AA5B1)),
};

/// Tất cả tên danh mục (dùng cho màn hình bộ lọc)
List<String> get kAllCategoryNames =>
    {...kExpenseCategories.keys, ...kIncomeCategories.keys}.toList();

class TransactionModel {
  final int? id;
  final String title;
  final String category;
  final double amount; // luôn dương
  final bool isIncome;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.note = '',
  });

  CategoryInfo get info =>
      (isIncome ? kIncomeCategories : kExpenseCategories)[category] ??
          const CategoryInfo(Icons.help_outline, Colors.grey);

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'is_income': isIncome ? 1 : 0,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int,
    title: m['title'] as String,
    category: m['category'] as String,
    amount: (m['amount'] as num).toDouble(),
    isIncome: m['is_income'] == 1,
    date: DateTime.parse(m['date'] as String),
    note: (m['note'] as String?) ?? '',
  );
}