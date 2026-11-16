import 'package:material_ui/material_ui.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({
    super.key,
    required this.expenses,
    required this.dailyLimit,
    required this.weeklyLimit,
    required this.period,
    required this.onSaveBudget,
  });

  final List<Expense> expenses;
  final double dailyLimit;
  final double weeklyLimit;
  final String period;
  final Future<void> Function(String period, double amount) onSaveBudget;

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _weekStart(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  double _spendingForPeriod(DateTime now) {
    if (period == 'Daily') {
      final today = _dateOnly(now);
      return expenses
          .where((expense) => _dateOnly(expense.date) == today)
          .fold(0, (total, expense) => total + expense.amount);
    }
    final start = _weekStart(now);
    final end = start.add(const Duration(days: 7));
    return expenses
        .where((expense) {
          final day = _dateOnly(expense.date);
          return !day.isBefore(start) && day.isBefore(end);
        })
        .fold(0, (total, expense) => total + expense.amount);
  }

  Future<void> _editBudget(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentLimit = period == 'Daily' ? dailyLimit : weeklyLimit;
    var amount = '';
    var selectedPeriod = period;
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set spending limit'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedPeriod,
                  decoration: const InputDecoration(labelText: 'Budget period'),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPeriod = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: currentLimit > 0
                      ? currentLimit.toStringAsFixed(2)
                      : '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Limit (₱)'),
                  validator: validatePositiveAmount,
                  onSaved: (value) => amount = value?.trim() ?? '',
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
                  await onSaveBudget(selectedPeriod, double.parse(amount));
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Budget saved.')),
                  );
                } catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Could not save budget: $error')),
                  );
                }
              },
              child: const Text('Save budget'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spending = _spendingForPeriod(DateTime.now());
    final limit = period == 'Daily' ? dailyLimit : weeklyLimit;
    final usage = limit <= 0 ? 0.0 : (spending / limit).clamp(0.0, 1.0);
    final overBudget = limit > 0 && spending >= limit;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Stay within your plan',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Choose a daily or weekly spending limit.'),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Spending budget',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit budget',
                      onPressed: () => _editBudget(context),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                Text('$period budget'),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        formatCurrency(spending),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      limit > 0
                          ? 'of ${formatCurrency(limit)}'
                          : 'No limit set',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: usage,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: overBudget
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 12),
                Text(
                  limit <= 0
                      ? 'Set a limit to start monitoring your spending.'
                      : overBudget
                      ? 'Budget reached. Try to avoid extra spending.'
                      : '${(usage * 100).round()}% of your budget used.',
                  style: TextStyle(
                    color: overBudget
                        ? const Color(0xFFE53935)
                        : const Color(0xFF546E7A),
                    fontWeight: overBudget
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _editBudget(context),
            icon: const Icon(Icons.tune),
            label: Text(limit > 0 ? 'Update budget' : 'Set a budget'),
          ),
        ),
      ],
    );
  }
}
