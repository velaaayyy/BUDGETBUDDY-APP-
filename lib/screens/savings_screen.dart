import 'package:material_ui/material_ui.dart';

import '../utils/formatters.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({
    super.key,
    required this.goal,
    required this.saved,
    required this.onSaveSavings,
  });

  final double goal;
  final double saved;
  final Future<void> Function(double goal, double amount) onSaveSavings;

  Future<void> _editSavings(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    var goalValue = '';
    var savedValue = '';
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update savings'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: goal > 0 ? goal.toStringAsFixed(2) : '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Savings goal (₱)',
                ),
                validator: validatePositiveAmount,
                onSaved: (value) => goalValue = value?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: saved > 0 ? saved.toStringAsFixed(2) : '0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount saved (₱)',
                ),
                validator: validateNonNegativeAmount,
                onSaved: (value) => savedValue = value?.trim() ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              try {
                await onSaveSavings(
                  double.parse(goalValue),
                  double.parse(savedValue),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Savings updated.')),
                );
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Could not update savings: $error')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (saved / goal).clamp(0.0, 1.0);
    final remaining = (goal - saved).clamp(0.0, double.infinity);
    final reached = goal > 0 && saved >= goal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Make room for your goals',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Small savings can make a big difference.'),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.savings_outlined,
                  size: 32,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),
                const Text('Saved so far'),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(saved),
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 10),
                Text(
                  goal > 0
                      ? '${(progress * 100).round()}% of ${formatCurrency(goal)}'
                      : 'Set a goal to track your progress.',
                ),
                if (goal > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    reached
                        ? 'Congratulations! You reached your goal.'
                        : '${formatCurrency(remaining)} left to reach your goal.',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _editSavings(context),
            icon: const Icon(Icons.edit_outlined),
            label: Text(goal > 0 ? 'Update savings' : 'Set a savings goal'),
          ),
        ),
      ],
    );
  }
}
