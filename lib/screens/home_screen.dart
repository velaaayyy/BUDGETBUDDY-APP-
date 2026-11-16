import 'package:material_ui/material_ui.dart';

import '../models/allowance.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.data,
    required this.onAddAllowance,
    required this.onUpdateAllowance,
  });

  final AppData data;
  final Future<void> Function(Allowance allowance) onAddAllowance;
  final Future<void> Function(Allowance allowance) onUpdateAllowance;

  Future<void> _showAllowanceForm(
    BuildContext context, {
    Allowance? allowance,
  }) async {
    final formKey = GlobalKey<FormState>();
    var amount = '';
    var frequency = allowance?.frequency ?? 'Weekly';
    var date = allowance?.date ?? DateTime.now();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(allowance == null ? 'Add allowance' : 'Edit allowance'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: allowance?.amount.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Amount (₱)'),
                    validator: validatePositiveAmount,
                    onSaved: (value) => amount = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: const [
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => frequency = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _DatePickerButton(
                    date: date,
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
                  final updatedAllowance = Allowance(
                    id:
                        allowance?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    amount: double.parse(amount),
                    frequency: frequency,
                    date: date,
                  );
                  if (allowance == null) {
                    await onAddAllowance(updatedAllowance);
                  } else {
                    await onUpdateAllowance(updatedAllowance);
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        allowance == null
                            ? 'Allowance added.'
                            : 'Allowance updated.',
                      ),
                    ),
                  );
                } catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Could not save allowance: $error')),
                  );
                }
              },
              child: Text(allowance == null ? 'Add allowance' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllowanceHistory(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allowance history'),
        content: SizedBox(
          width: 360,
          child: data.allowances.isEmpty
              ? const Text('No allowance entries yet.')
              : ListView(
                  shrinkWrap: true,
                  children: data.allowances
                      .map(
                        (allowance) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(formatCurrency(allowance.amount)),
                          subtitle: Text(
                            '${allowance.frequency} · ${formatDate(allowance.date)}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Edit allowance',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showAllowanceForm(
                              context,
                              allowance: allowance,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = [...data.expenses]..sort((a, b) => b.date.compareTo(a.date));
    final allowances = [...data.allowances]
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          'Welcome, ${data.studentName}!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Here is your money snapshot.'),
        const SizedBox(height: 14),
        SizedBox(
          height: 46,
          child: FilledButton.icon(
            onPressed: () => _showAllowanceForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add allowance'),
          ),
        ),
        const SizedBox(height: 14),
        BalanceCard(
          balance: data.remainingBalance,
          allowance: data.totalAllowance,
          expenses: data.totalExpenses,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Allowance',
                amount: data.totalAllowance,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SummaryCard(
                title: 'Total Expenses',
                amount: data.totalExpenses,
                icon: Icons.shopping_bag_outlined,
                isExpense: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Remaining Balance',
                amount: data.remainingBalance,
                icon: Icons.savings_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SummaryCard(
                title: 'Total Savings',
                amount: data.savingsAmount,
                icon: Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Allowance',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAllowanceHistory(context),
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showAllowanceForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (allowances.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Add an allowance to get started.'),
                  )
                else
                  ...allowances
                      .take(2)
                      .map(
                        (allowance) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_downward,
                                size: 18,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${allowance.frequency} allowance · '
                                  '${formatDate(allowance.date)}',
                                ),
                              ),
                              Text(
                                '+${formatCurrency(allowance.amount)}',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Your expenses will appear here.'),
            ),
          )
        else
          ...recent.take(3).map((expense) => TransactionItem(expense: expense)),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.date, required this.onPressed});

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text('Date: ${formatDate(date)}'),
  );
}
