import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _goalsCollection =>
      _firestore.collection('goals');

  // Create a new goal
  Future<Goal> createGoal(Goal goal) async {
    final docRef = _goalsCollection.doc();
    final newGoal = goal.copyWith(
      id: docRef.id,
      userId: _userId,
    );
    await docRef.set(newGoal.toMap());
    return newGoal;
  }

  // Get all goals for current user
  Stream<List<Goal>> getGoals() {
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList();
    });
  }

  // Get active goals (not achieved and not overdue)
  Stream<List<Goal>> getActiveGoals() {
    final now = DateTime.now();
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .where('targetDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data()))
          .where((goal) => !goal.isAchieved)
          .toList();
    });
  }

  // Get achieved goals
  Stream<List<Goal>> getAchievedGoals() {
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Goal.fromMap(doc.data()))
          .where((goal) => goal.isAchieved)
          .toList();
    });
  }

  // Get goals by category
  Stream<List<Goal>> getGoalsByCategory(String category) {
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList();
    });
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) async {
    await _goalsCollection.doc(goal.id).update(goal.toMap());
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  // Update saved amount
  Future<void> updateSavedAmount(String goalId, double newAmount) async {
    await _goalsCollection.doc(goalId).update({'savedAmount': newAmount});
  }

  // Add to saved amount
  Future<void> addToSavedAmount(String goalId, double amount) async {
    final goalRef = _goalsCollection.doc(goalId);
    await _firestore.runTransaction((transaction) async {
      final goalDoc = await transaction.get(goalRef);
      if (goalDoc.exists) {
        final currentAmount = (goalDoc.data()?['savedAmount'] as num).toDouble();
        transaction.update(goalRef, {'savedAmount': currentAmount + amount});
      }
    });
  }

  // Get total saved amount across all goals
  Stream<double> getTotalSavedAmount() {
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<double>(
          0, (sum, doc) => sum + (doc.data()['savedAmount'] as num).toDouble());
    });
  }

  // Get achievement rate (percentage of achieved goals)
  Stream<double> getAchievementRate() {
    return _goalsCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0;
      final goals = snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList();
      final achievedGoals = goals.where((goal) => goal.isAchieved).length;
      return (achievedGoals / goals.length * 100);
    });
  }
} 