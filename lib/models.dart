import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });
}

class Transaction {
  final String? id;
  final bool isExpense;
  final Category category;
  final double amount;
  final DateTime date;
  final String note;

  Transaction({
    this.id,
    required this.isExpense,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
}

class CategoryStore {
  CategoryStore._();

  static final List<Category> _expenseCategories = [
    Category(id: 'e1', name: 'Ăn uống', icon: Icons.restaurant, color: Colors.redAccent, isExpense: true),
    Category(id: 'e2', name: 'Mua sắm', icon: Icons.shopping_bag, color: Colors.orange, isExpense: true),
    Category(id: 'e3', name: 'Di chuyển', icon: Icons.directions_car, color: Colors.blue, isExpense: true),
    Category(id: 'e4', name: 'Giải trí', icon: Icons.movie, color: Colors.purple, isExpense: true),
    Category(id: 'e5', name: 'Hóa đơn', icon: Icons.receipt_long, color: Colors.brown, isExpense: true),
  ];

  static final List<Category> _incomeCategories = [
    Category(id: 'i1', name: 'Lương', icon: Icons.attach_money, color: Colors.green, isExpense: false),
    Category(id: 'i2', name: 'Thưởng', icon: Icons.card_giftcard, color: Colors.teal, isExpense: false),
    Category(id: 'i3', name: 'Đầu tư', icon: Icons.trending_up, color: Colors.indigo, isExpense: false),
    Category(id: 'i4', name: 'Khác', icon: Icons.more_horiz, color: Colors.grey, isExpense: false),
  ];

  static List<Category> byType(bool isExpense) =>
      isExpense ? List.unmodifiable(_expenseCategories) : List.unmodifiable(_incomeCategories);

  static Category addCategory({
    required String name,
    required IconData icon,
    required Color color,
    required bool isExpense,
  }) {
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      color: color,
      isExpense: isExpense,
    );
    if (isExpense) {
      _expenseCategories.add(newCategory);
    } else {
      _incomeCategories.add(newCategory);
    }
    return newCategory;
  }
}

const List<IconData> pickableIcons = [
  Icons.category,
  Icons.fastfood,
  Icons.local_cafe,
  Icons.school,
  Icons.pets,
  Icons.flight,
  Icons.medical_services,
  Icons.sports_soccer,
  Icons.home,
  Icons.phone_android,
];

const List<Color> pickableColors = [
  Colors.red,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.teal,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.pink,
  Colors.brown,
];