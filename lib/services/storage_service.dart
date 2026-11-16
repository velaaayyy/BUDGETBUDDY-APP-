import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/allowance.dart';
import '../models/expense.dart';

class AppData {
  const AppData({
    required this.allowances,
    required this.expenses,
    required this.dailyBudget,
    required this.weeklyBudget,
    required this.budgetPeriod,
    required this.savingsGoal,
    required this.savingsAmount,
    required this.studentName,
  });

  final List<Allowance> allowances;
  final List<Expense> expenses;
  final double dailyBudget;
  final double weeklyBudget;
  final String budgetPeriod;
  final double savingsGoal;
  final double savingsAmount;
  final String studentName;

  double get totalAllowance =>
      allowances.fold(0, (total, allowance) => total + allowance.amount);

  double get totalExpenses =>
      expenses.fold(0, (total, expense) => total + expense.amount);

  double get remainingBalance => totalAllowance - totalExpenses;

  AppData copyWith({
    List<Allowance>? allowances,
    List<Expense>? expenses,
    double? dailyBudget,
    double? weeklyBudget,
    String? budgetPeriod,
    double? savingsGoal,
    double? savingsAmount,
    String? studentName,
  }) => AppData(
    allowances: allowances ?? this.allowances,
    expenses: expenses ?? this.expenses,
    dailyBudget: dailyBudget ?? this.dailyBudget,
    weeklyBudget: weeklyBudget ?? this.weeklyBudget,
    budgetPeriod: budgetPeriod ?? this.budgetPeriod,
    savingsGoal: savingsGoal ?? this.savingsGoal,
    savingsAmount: savingsAmount ?? this.savingsAmount,
    studentName: studentName ?? this.studentName,
  );

  factory AppData.empty({String studentName = 'Student'}) {
    return AppData(
      allowances: [],
      expenses: [],
      dailyBudget: 0,
      weeklyBudget: 0,
      budgetPeriod: 'Weekly',
      savingsGoal: 0,
      savingsAmount: 0,
      studentName: studentName,
    );
  }
}

class StorageService {
  static const _dataVersionKey = 'dataVersion';
  static const _currentDataVersion = 2;
  static const _allowancesKey = 'allowances';
  static const _expensesKey = 'expenses';
  static const _dailyBudgetKey = 'dailyBudget';
  static const _weeklyBudgetKey = 'weeklyBudget';
  static const _budgetPeriodKey = 'budgetPeriod';
  static const _savingsGoalKey = 'savingsGoal';
  static const _savingsAmountKey = 'savingsAmount';
  static const _studentNameKey = 'studentName';

  static Future<AppData> loadData() async {
    final preferences = await SharedPreferences.getInstance();
    final dataVersion = preferences.getInt(_dataVersionKey);
    if (dataVersion == null || dataVersion < _currentDataVersion) {
      final emptyData = AppData.empty(
        studentName: preferences.getString(_studentNameKey) ?? 'Student',
      );
      await saveData(emptyData);
      return emptyData;
    }

    final allowanceJson = preferences.getString(_allowancesKey);
    final expenseJson = preferences.getString(_expensesKey);
    if (allowanceJson == null || expenseJson == null) {
      final emptyData = AppData.empty(
        studentName: preferences.getString(_studentNameKey) ?? 'Student',
      );
      await saveData(emptyData);
      return emptyData;
    }

    return AppData(
      allowances: (jsonDecode(allowanceJson) as List<dynamic>)
          .map((item) => Allowance.fromJson(item as Map<String, dynamic>))
          .toList(),
      expenses: (jsonDecode(expenseJson) as List<dynamic>)
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList(),
      dailyBudget: preferences.getDouble(_dailyBudgetKey) ?? 0,
      weeklyBudget: preferences.getDouble(_weeklyBudgetKey) ?? 0,
      budgetPeriod: preferences.getString(_budgetPeriodKey) ?? 'Weekly',
      savingsGoal: preferences.getDouble(_savingsGoalKey) ?? 0,
      savingsAmount: preferences.getDouble(_savingsAmountKey) ?? 0,
      studentName: preferences.getString(_studentNameKey) ?? 'Student',
    );
  }

  static Future<void> saveData(AppData data) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await Future.wait([
      preferences.setString(
        _allowancesKey,
        jsonEncode(data.allowances.map((item) => item.toJson()).toList()),
      ),
      preferences.setString(
        _expensesKey,
        jsonEncode(data.expenses.map((item) => item.toJson()).toList()),
      ),
      preferences.setDouble(_dailyBudgetKey, data.dailyBudget),
      preferences.setDouble(_weeklyBudgetKey, data.weeklyBudget),
      preferences.setString(_budgetPeriodKey, data.budgetPeriod),
      preferences.setDouble(_savingsGoalKey, data.savingsGoal),
      preferences.setDouble(_savingsAmountKey, data.savingsAmount),
      preferences.setString(_studentNameKey, data.studentName),
      preferences.setInt(_dataVersionKey, _currentDataVersion),
    ]);
    if (saved.contains(false)) {
      throw StateError('BudgetBuddy could not save your changes.');
    }
  }
}
