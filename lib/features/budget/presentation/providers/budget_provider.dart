import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/budget.dart';
import '../../data/services/budget_service.dart';

part 'budget_provider.g.dart';

@riverpod
BudgetService budgetService(BudgetServiceRef ref) {
  return BudgetService();
}

@riverpod
Stream<List<Budget>> budgets(BudgetsRef ref) {
  return ref.watch(budgetServiceProvider).getBudgets();
}

@riverpod
Stream<List<Budget>> activeBudgets(ActiveBudgetsRef ref) {
  return ref.watch(budgetServiceProvider).getActiveBudgets();
}

@riverpod
Stream<Budget?> budget(BudgetRef ref, String budgetId) {
  return ref.watch(budgetServiceProvider).getBudget(budgetId);
}

@riverpod
class BudgetController extends _$BudgetController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createBudget({
    required String category,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final budget = Budget(
        id: '',
        userId: '',
        category: category,
        amount: amount,
        spent: 0,
        startDate: startDate,
        endDate: endDate,
        note: note,
      );
      return ref.read(budgetServiceProvider).createBudget(budget);
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetServiceProvider).updateBudget(budget);
    });
  }

  Future<void> deleteBudget(String budgetId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(budgetServiceProvider).deleteBudget(budgetId);
    });
  }

  Future<void> updateSpentAmount(String budgetId, double newSpentAmount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(budgetServiceProvider)
          .updateSpentAmount(budgetId, newSpentAmount);
    });
  }
} 