import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _showGoalForm(BuildContext context, WidgetRef ref, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                goal == null ? 'Create New Goal' : 'Edit Goal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GoalForm(
                initialGoal: goal,
                onSubmit: (title, category, targetAmount, targetDate, note) async {
                  final controller = ref.read(goalControllerProvider.notifier);
                  if (goal == null) {
                    await controller.createGoal(
                      title: title,
                      category: category,
                      targetAmount: targetAmount,
                      targetDate: targetDate,
                      note: note,
                    );
                  } else {
                    await controller.updateGoal(
                      goal.copyWith(
                        title: title,
                        category: category,
                        targetAmount: targetAmount,
                        targetDate: targetDate,
                        note: note,
                      ),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(goalControllerProvider.notifier)
                  .deleteGoal(goal.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(goalsProvider);
    final achievementRate = ref.watch(achievementRateProvider);
    final totalSaved = ref.watch(totalSavedAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGoalForm(context, ref),
            tooltip: 'Add Goal',
          ),
        ],
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (goals) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Saved',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            totalSaved.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (error, _) => Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                              data: (amount) => Text(
                                '\$${amount.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Achievement Rate',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            achievementRate.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (error, _) => Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                              data: (rate) => Text(
                                '${(rate * 100).toStringAsFixed(1)}%',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No goals yet',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first goal',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(goalsProvider);
                        ref.invalidate(totalSavedAmountProvider);
                        ref.invalidate(achievementRateProvider);
                      },
                      child: ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return GoalCard(
                            goal: goal,
                            onTap: () => _showGoalForm(
                              context,
                              ref,
                              goal: goal,
                            ),
                            onEdit: () => _showGoalForm(
                              context,
                              ref,
                              goal: goal,
                            ),
                            onDelete: () => _confirmDelete(context, ref, goal),
                            onAddAmount: (amount) {
                              ref
                                  .read(goalControllerProvider.notifier)
                                  .addToSavedAmount(goal.id, amount);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 