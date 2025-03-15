import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('expenses');

  // Create a new expense
  Future<Expense> createExpense(Expense expense, {String? imagePath}) async {
    final docRef = _expensesCollection.doc();
    String? receiptUrl;

    if (imagePath != null) {
      final storageRef = _storage
          .ref()
          .child('receipts')
          .child(_userId)
          .child('${docRef.id}.jpg');
      await storageRef.putFile(File(imagePath));
      receiptUrl = await storageRef.getDownloadURL();
    }

    final newExpense = expense.copyWith(
      id: docRef.id,
      userId: _userId,
      receiptUrl: receiptUrl,
    );

    await docRef.set(newExpense.toMap());
    
    // Update budget spent amount
    final budgetRef = _firestore.collection('budgets').doc(expense.budgetId);
    await _firestore.runTransaction((transaction) async {
      final budgetDoc = await transaction.get(budgetRef);
      if (budgetDoc.exists) {
        final currentSpent = (budgetDoc.data()?['spent'] as num).toDouble();
        transaction.update(budgetRef, {'spent': currentSpent + expense.amount});
      }
    });

    return newExpense;
  }

  // Get all expenses for current user
  Stream<List<Expense>> getExpenses() {
    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    });
  }

  // Get expenses for a specific budget
  Stream<List<Expense>> getExpensesForBudget(String budgetId) {
    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .where('budgetId', isEqualTo: budgetId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    });
  }

  // Get expenses by category
  Stream<List<Expense>> getExpensesByCategory(String category) {
    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    });
  }

  // Get expenses by date range
  Stream<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    });
  }

  // Update an expense
  Future<void> updateExpense(Expense expense, {String? newImagePath}) async {
    String? receiptUrl = expense.receiptUrl;

    if (newImagePath != null) {
      // Delete old receipt if exists
      if (receiptUrl != null) {
        try {
          await _storage.refFromURL(receiptUrl).delete();
        } catch (_) {}
      }

      // Upload new receipt
      final storageRef = _storage
          .ref()
          .child('receipts')
          .child(_userId)
          .child('${expense.id}.jpg');
      await storageRef.putFile(File(newImagePath));
      receiptUrl = await storageRef.getDownloadURL();
    }

    final updatedExpense = expense.copyWith(receiptUrl: receiptUrl);
    await _expensesCollection.doc(expense.id).update(updatedExpense.toMap());
  }

  // Delete an expense
  Future<void> deleteExpense(Expense expense) async {
    // Delete receipt if exists
    if (expense.receiptUrl != null) {
      try {
        await _storage.refFromURL(expense.receiptUrl!).delete();
      } catch (_) {}
    }

    await _expensesCollection.doc(expense.id).delete();

    // Update budget spent amount
    final budgetRef = _firestore.collection('budgets').doc(expense.budgetId);
    await _firestore.runTransaction((transaction) async {
      final budgetDoc = await transaction.get(budgetRef);
      if (budgetDoc.exists) {
        final currentSpent = (budgetDoc.data()?['spent'] as num).toDouble();
        transaction.update(budgetRef, {'spent': currentSpent - expense.amount});
      }
    });
  }

  // Get total expenses for current month
  Stream<double> getCurrentMonthTotal() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<double>(
          0, (sum, doc) => sum + (doc.data()['amount'] as num).toDouble());
    });
  }

  // Get monthly totals for the last 6 months
  Stream<Map<DateTime, double>> getMonthlyTotals() {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    return _expensesCollection
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final monthlyTotals = <DateTime, double>{};
      
      for (var doc in snapshot.docs) {
        final expense = Expense.fromMap(doc.data());
        final monthStart = DateTime(expense.date.year, expense.date.month, 1);
        monthlyTotals[monthStart] =
            (monthlyTotals[monthStart] ?? 0) + expense.amount;
      }

      return monthlyTotals;
    });
  }
} 