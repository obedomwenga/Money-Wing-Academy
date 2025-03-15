import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/expense.dart';
import '../../data/services/expense_service.dart';

part 'expense_provider.g.dart';

@riverpod
ExpenseService expenseService(ExpenseServiceRef ref) {
  return ExpenseService();
}

@riverpod
Stream<List<Expense>> expenses(ExpensesRef ref) {
  return ref.watch(expenseServiceProvider).getExpenses();
}

@riverpod
Stream<List<Expense>> expensesForBudget(
  ExpensesForBudgetRef ref,
  String budgetId,
) {
  return ref.watch(expenseServiceProvider).getExpensesForBudget(budgetId);
}

@riverpod
Stream<double> currentMonthTotal(CurrentMonthTotalRef ref) {
  return ref.watch(expenseServiceProvider).getCurrentMonthTotal();
}

@riverpod
Stream<Map<DateTime, double>> monthlyTotals(MonthlyTotalsRef ref) {
  return ref.watch(expenseServiceProvider).getMonthlyTotals();
}

@riverpod
class ExpenseController extends _$ExpenseController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createExpense({
    required String budgetId,
    required String category,
    required double amount,
    required DateTime date,
    String? note,
    String? imagePath,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expense = Expense(
        id: '',
        userId: '',
        budgetId: budgetId,
        category: category,
        amount: amount,
        date: date,
        note: note,
      );
      return ref.read(expenseServiceProvider).createExpense(expense, imagePath: imagePath);
    });
  }

  Future<void> updateExpense(Expense expense, {String? newImagePath}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseServiceProvider).updateExpense(expense, newImagePath: newImagePath);
    });
  }

  Future<void> deleteExpense(Expense expense) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseServiceProvider).deleteExpense(expense);
    });
  }
} 