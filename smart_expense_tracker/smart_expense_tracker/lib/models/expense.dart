import 'package:flutter/material.dart';

const String currency = 'ر.س'; // غيّر العملة من هنا

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.name, this.icon, this.color);
}

const List<ExpenseCategory> categories = [
  ExpenseCategory('طعام', Icons.restaurant, Colors.orange),
  ExpenseCategory('مواصلات', Icons.directions_car, Colors.blue),
  ExpenseCategory('فواتير', Icons.receipt_long, Colors.red),
  ExpenseCategory('تسوق', Icons.shopping_bag, Colors.purple),
  ExpenseCategory('صحة', Icons.favorite, Colors.pink),
  ExpenseCategory('ترفيه', Icons.movie, Colors.teal),
  ExpenseCategory('تعليم', Icons.school, Colors.indigo),
  ExpenseCategory('أخرى', Icons.category, Colors.grey),
];

ExpenseCategory categoryByName(String name) =>
    categories.firstWhere((c) => c.name == name, orElse: () => categories.last);

class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'] as int?,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?,
      );
}
