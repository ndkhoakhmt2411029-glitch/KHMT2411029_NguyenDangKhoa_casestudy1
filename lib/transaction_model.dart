import 'package:flutter/material.dart';

class CategoryInfo {
  final IconData icon;
  final Color color;
  const CategoryInfo(this.icon, this.color);
}

const Map<String, CategoryInfo> kExpenseCategories = {
  'Ăn uống': CategoryInfo(Icons.restaurant, Colors.orange),
  'Di chuyển': CategoryInfo(Icons.directions_car, Colors.blue),
  'Mua sắm': CategoryInfo(Icons.shopping_cart, Colors.purple),
  'Giáo dục': CategoryInfo(Icons.school, Colors.teal),
  'Khác': CategoryInfo(Icons.more_horiz, Colors.grey),
};

const Map<String, CategoryInfo> kIncomeCategories = {
  'Thu nhập': CategoryInfo(Icons.attach_money, Colors.green),
  'Thưởng': CategoryInfo(Icons.card_giftcard, Colors.pink),
  'Khác': CategoryInfo(Icons.more_horiz, Colors.grey),
};

class TransactionModel {
  final int? id;
  final String title;
  final String category;
  final double amount; // luôn dương
  final bool isIncome;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
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
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int,
    title: m['title'] as String,
    category: m['category'] as String,
    amount: (m['amount'] as num).toDouble(),
    isIncome: m['is_income'] == 1,
    date: DateTime.parse(m['date'] as String),
  );
}