import 'package:material_ui/material_ui.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_item.dart';

const _expenseCategories = [
  'Food',
  'Transportation',
  'School Supplies',
  'Personal Needs',
  'Entertainment',
  'Others',
];

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({
    super.key,
    required this.expenses,
    required this.onAddExpense,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final Future<void> Function(Expense expense) onAddExpense;
  final Future<void> Function(Expense expense) onDeleteExpense;

  Future<void> _showExpenseForm(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    var name = '';
    var amount = '';
    var category = _expenseCategories.first;
    var date = DateTime.now();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add expense'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Expense name',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter an expense name.'
                        : null,
                    onSaved: (value) => name = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Amount (₱)'),
                    validator: validatePositiveAmount,
                    onSaved: (value) => amount = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _expenseCategories
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => category = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => date = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Date: ${formatDate(date)}'),
                  ),
                ],
              ),
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
                  await onAddExpense(
                    Expense(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name,
                      category: category,
                      amount: double.parse(amount),
                      date: date,
                    ),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Expense saved.')),
                  );
                } catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Could not save expense: $error')),
                  );
                }
              },
              child: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${expense.name}" from your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      await onDeleteExpense(expense);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Expense deleted.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete expense: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Track your spending',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Every small purchase adds up.'),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _showExpenseForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add expense'),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Expense history (${sorted.length})',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (sorted.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('No expenses yet. Add your first expense above.'),
            ),
          )
        else
          ...sorted.map(
            (expense) => TransactionItem(
              expense: expense,
              onDelete: () => _confirmDelete(context, expense),
            ),
          ),
      ],
    );
  }
}
