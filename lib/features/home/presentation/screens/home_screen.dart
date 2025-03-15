import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_wing_academy/features/home/presentation/widgets/balance_card.dart';
import 'package:money_wing_academy/features/home/presentation/widgets/quick_action_card.dart';
import 'package:money_wing_academy/features/home/presentation/widgets/spending_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Wing Academy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to profile screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const BalanceCard(
              totalBalance: 5000.0,
              monthlyIncome: 3000.0,
              monthlyExpenses: 2000.0,
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  QuickActionCard(
                    icon: Icons.add,
                    label: 'Add Expense',
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  QuickActionCard(
                    icon: Icons.savings,
                    label: 'Set Budget',
                    color: Colors.green,
                  ),
                  SizedBox(width: 16),
                  QuickActionCard(
                    icon: Icons.flag,
                    label: 'New Goal',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Monthly Spending',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: SpendingChart(),
            ),
            const SizedBox(height: 24),
            Text(
              'Financial Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tip of the Day',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try the 50/30/20 rule: Spend 50% on needs, 30% on wants, and save 20% of your income.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 