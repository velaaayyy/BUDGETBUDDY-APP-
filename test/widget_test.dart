import 'package:budgetbuddy/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetbuddy/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('starts with zero balances and an empty expense history', (
    tester,
  ) async {
    await tester.pumpWidget(const BudgetBuddyApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Student!'), findsOneWidget);
    expect(find.text('₱0.00'), findsWidgets);

    await tester.tap(find.text('Expenses').last);
    await tester.pumpAndSettle();

    expect(find.text('Expense history (0)'), findsOneWidget);
    expect(
      find.text('No expenses yet. Add your first expense above.'),
      findsOneWidget,
    );
  });

  test(
    'clears saved money data once when upgrading to the zero-balance version',
    () async {
      SharedPreferences.setMockInitialValues({
        'allowances': '[{"id":"old","amount":1000,"frequency":"Weekly","date":"2026-11-16T00:00:00.000"}]',
        'expenses': '[{"id":"old-expense","name":"Food","category":"Food","amount":100,"date":"2026-11-16T00:00:00.000"}]',
        'dailyBudget': 100.0,
        'weeklyBudget': 500.0,
        'budgetPeriod': 'Weekly',
        'savingsGoal': 300.0,
        'savingsAmount': 50.0,
        'studentName': 'Alex',
      });

      final resetData = await StorageService.loadData();
      expect(resetData.allowances, isEmpty);
      expect(resetData.expenses, isEmpty);
      expect(resetData.totalAllowance, 0);
      expect(resetData.totalExpenses, 0);
      expect(resetData.remainingBalance, 0);
      expect(resetData.dailyBudget, 0);
      expect(resetData.weeklyBudget, 0);
      expect(resetData.savingsGoal, 0);
      expect(resetData.savingsAmount, 0);
      expect(resetData.studentName, 'Alex');

      final loadedAgain = await StorageService.loadData();
      expect(loadedAgain.totalAllowance, 0);
      expect(loadedAgain.totalExpenses, 0);
    },
  );

  testWidgets('adds and edits an allowance entry', (tester) async {
    await tester.pumpWidget(const BudgetBuddyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add allowance').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '500');
    final addDialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(
        of: addDialog,
        matching: find.widgetWithText(FilledButton, 'Add allowance'),
      ),
    );
    await tester.pumpAndSettle();
    var savedData = await StorageService.loadData();
    expect(savedData.totalAllowance, 500);

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit allowance'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '750');
    final editDialog = find.byType(AlertDialog).last;
    await tester.tap(
      find.descendant(
        of: editDialog,
        matching: find.widgetWithText(FilledButton, 'Save changes'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    savedData = await StorageService.loadData();
    expect(savedData.totalAllowance, 750);
    await tester.ensureVisible(find.text('+₱750.00'));
    expect(find.text('+₱750.00'), findsOneWidget);
  });

  testWidgets('adding and deleting an expense updates saved totals', (
    tester,
  ) async {
    await tester.pumpWidget(const BudgetBuddyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expenses').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Campus coffee');
    await tester.enterText(find.byType(TextFormField).at(1), '25');
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Campus coffee'), findsOneWidget);
    expect(find.text('Expense history (1)'), findsOneWidget);

    final expenseCard = find.ancestor(
      of: find.text('Campus coffee'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(
        of: expenseCard,
        matching: find.byTooltip('Delete expense'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Expense history (0)'), findsOneWidget);
    final savedData = await StorageService.loadData();
    expect(savedData.totalExpenses, 0);
    expect(savedData.remainingBalance, 0);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('₱0.00'), findsWidgets);
  });
}
