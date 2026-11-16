import 'package:material_ui/material_ui.dart';

import 'screens/budget_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/savings_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const BudgetBuddyApp());
}

class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F5),
          foregroundColor: Color(0xFF263238),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
          ),
        ),
        useMaterial3: true,
      ),
      home: const BudgetBuddyShell(),
    );
  }
}

class BudgetBuddyShell extends StatefulWidget {
  const BudgetBuddyShell({super.key});

  @override
  State<BudgetBuddyShell> createState() => _BudgetBuddyShellState();
}

class _BudgetBuddyShellState extends State<BudgetBuddyShell> {
  AppData? _data;
  Object? _loadError;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loadError = null;
      _data = null;
    });
    try {
      final data = await StorageService.loadData();
      if (mounted) {
        setState(() => _data = data);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    }
  }

  Future<void> _saveData(AppData updatedData) async {
    await StorageService.saveData(updatedData);
    if (mounted) {
      setState(() => _data = updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                const SizedBox(height: 12),
                const Text('BudgetBuddy could not load your saved data.'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loadData,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      HomeScreen(
        data: data,
        onAddAllowance: (allowance) => _saveData(
          data.copyWith(allowances: [allowance, ...data.allowances]),
        ),
        onUpdateAllowance: (allowance) => _saveData(
          data.copyWith(
            allowances: data.allowances
                .map((item) => item.id == allowance.id ? allowance : item)
                .toList(),
          ),
        ),
      ),
      ExpenseScreen(
        expenses: data.expenses,
        onAddExpense: (expense) =>
            _saveData(data.copyWith(expenses: [expense, ...data.expenses])),
        onDeleteExpense: (expense) => _saveData(
          data.copyWith(
            expenses: data.expenses
                .where((item) => item.id != expense.id)
                .toList(),
          ),
        ),
      ),
      BudgetScreen(
        expenses: data.expenses,
        dailyLimit: data.dailyBudget,
        weeklyLimit: data.weeklyBudget,
        period: data.budgetPeriod,
        onSaveBudget: (period, amount) => _saveData(
          period == 'Daily'
              ? data.copyWith(dailyBudget: amount, budgetPeriod: period)
              : data.copyWith(weeklyBudget: amount, budgetPeriod: period),
        ),
      ),
      SavingsScreen(
        goal: data.savingsGoal,
        saved: data.savingsAmount,
        onSaveSavings: (goal, amount) =>
            _saveData(data.copyWith(savingsGoal: goal, savingsAmount: amount)),
      ),
      ProfileScreen(
        studentName: data.studentName,
        onSaveName: (name) => _saveData(data.copyWith(studentName: name)),
      ),
    ];
    const titles = ['BudgetBuddy', 'Expenses', 'Budget', 'Savings', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            label: 'Savings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
