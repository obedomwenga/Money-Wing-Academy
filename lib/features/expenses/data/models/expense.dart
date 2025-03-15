import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String budgetId;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;
  final String? receiptUrl;

  const Expense({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'budgetId': budgetId,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'receiptUrl': receiptUrl,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      userId: map['userId'] as String,
      budgetId: map['budgetId'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'] as String?,
      receiptUrl: map['receiptUrl'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? budgetId,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
} 