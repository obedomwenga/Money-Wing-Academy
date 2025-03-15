import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String userId;
  final String title;
  final String category;
  final double targetAmount;
  final double savedAmount;
  final DateTime startDate;
  final DateTime targetDate;
  final String? note;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    required this.startDate,
    required this.targetDate,
    this.note,
  });

  double get progressPercentage => (savedAmount / targetAmount * 100).clamp(0, 100);
  bool get isAchieved => savedAmount >= targetAmount;
  double get remainingAmount => targetAmount - savedAmount;
  
  Duration get remainingTime => targetDate.difference(DateTime.now());
  bool get isOverdue => targetDate.isBefore(DateTime.now()) && !isAchieved;
  
  double get requiredMonthlySavings {
    if (isAchieved) return 0;
    final monthsLeft = remainingTime.inDays / 30;
    if (monthsLeft <= 0) return remainingAmount;
    return remainingAmount / monthsLeft;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'note': note,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    double? targetAmount,
    double? savedAmount,
    DateTime? startDate,
    DateTime? targetDate,
    String? note,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
    );
  }
} 