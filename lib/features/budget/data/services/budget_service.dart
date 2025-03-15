import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _budgetsCollection =>
      _firestore.collection('budgets');

  // Create a new budget
  Future<Budget> createBudget(Budget budget) async {
    final docRef = _budgetsCollection.doc();
    final newBudget = budget.copyWith(id: docRef.id, userId: _userId);
    await docRef.set(newBudget.toMap());
    return newBudget;
  }

  // Get all budgets for current user
  Stream<List<Budget>> getBudgets() {
    return _budgetsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList();
    });
  }

  // Get a specific budget
  Stream<Budget?> getBudget(String budgetId) {
    return _budgetsCollection.doc(budgetId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Budget.fromMap(doc.data()!);
    });
  }

  // Update a budget
  Future<void> updateBudget(Budget budget) async {
    await _budgetsCollection.doc(budget.id).update(budget.toMap());
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _budgetsCollection.doc(budgetId).delete();
  }

  // Update spent amount
  Future<void> updateSpentAmount(String budgetId, double newSpentAmount) async {
    await _budgetsCollection.doc(budgetId).update({'spent': newSpentAmount});
  }

  // Get budgets by category
  Stream<List<Budget>> getBudgetsByCategory(String category) {
    return _budgetsCollection
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList();
    });
  }

  // Get active budgets (current month)
  Stream<List<Budget>> getActiveBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _budgetsCollection
        .where('userId', isEqualTo: _userId)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Budget.fromMap(doc.data())).toList();
    });
  }
} 