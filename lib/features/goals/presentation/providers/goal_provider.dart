import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/goal.dart';
import '../../data/services/goal_service.dart';

part 'goal_provider.g.dart';

@riverpod
GoalService goalService(GoalServiceRef ref) {
  return GoalService();
}

@riverpod
Stream<List<Goal>> goals(GoalsRef ref) {
  return ref.watch(goalServiceProvider).getGoals();
}

@riverpod
Stream<List<Goal>> activeGoals(ActiveGoalsRef ref) {
  return ref.watch(goalServiceProvider).getActiveGoals();
}

@riverpod
Stream<List<Goal>> achievedGoals(AchievedGoalsRef ref) {
  return ref.watch(goalServiceProvider).getAchievedGoals();
}

@riverpod
Stream<double> totalSavedAmount(TotalSavedAmountRef ref) {
  return ref.watch(goalServiceProvider).getTotalSavedAmount();
}

@riverpod
Stream<double> achievementRate(AchievementRateRef ref) {
  return ref.watch(goalServiceProvider).getAchievementRate();
}

@riverpod
class GoalController extends _$GoalController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createGoal({
    required String title,
    required String category,
    required double targetAmount,
    required DateTime targetDate,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final goal = Goal(
        id: '',
        userId: '',
        title: title,
        category: category,
        targetAmount: targetAmount,
        savedAmount: 0,
        startDate: DateTime.now(),
        targetDate: targetDate,
        note: note,
      );
      return ref.read(goalServiceProvider).createGoal(goal);
    });
  }

  Future<void> updateGoal(Goal goal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalServiceProvider).updateGoal(goal);
    });
  }

  Future<void> deleteGoal(String goalId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalServiceProvider).deleteGoal(goalId);
    });
  }

  Future<void> updateSavedAmount(String goalId, double newAmount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalServiceProvider).updateSavedAmount(goalId, newAmount);
    });
  }

  Future<void> addToSavedAmount(String goalId, double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalServiceProvider).addToSavedAmount(goalId, amount);
    });
  }
} 