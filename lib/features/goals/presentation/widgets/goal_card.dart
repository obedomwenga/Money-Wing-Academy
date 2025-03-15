import 'package:flutter/material.dart';
import '../../data/models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(double amount)? onAddAmount;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.category,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    Row(
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: onEdit,
                            tooltip: 'Edit Goal',
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete,
                            tooltip: 'Delete Goal',
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: goal.progressPercentage,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isAchieved ? Colors.green : colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${goal.savedAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${goal.targetAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due ${goal.targetDate.month}/${goal.targetDate.day}/${goal.targetDate.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: goal.isOverdue ? Colors.red : null,
                    ),
                  ),
                  if (onAddAmount != null && !goal.isAchieved)
                    TextButton.icon(
                      onPressed: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add Amount'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixText: '\$',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );

                        if (result == true) {
                          final amount = double.tryParse(controller.text);
                          if (amount != null && amount > 0) {
                            onAddAmount!(amount);
                          }
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Amount'),
                    ),
                ],
              ),
              if (goal.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  goal.note!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 