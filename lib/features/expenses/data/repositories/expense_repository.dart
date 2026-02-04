import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';

final expenseBoxProvider = Provider<Box<Expense>>((ref) {
  return Hive.box<Expense>('expenses');
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(expenseBoxProvider));
});

class ExpenseRepository {
  final Box<Expense> _box;

  ExpenseRepository(this._box);

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Get all expenses
  List<Expense> getAllExpenses() {
    return _box.values.toList();
  }

  // Get expense by ID
  Expense? getExpenseById(String id) {
    return _box.get(id);
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _box.values.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _box.values
        .where((expense) => expense.category == category)
        .toList();
  }

  // Get total expenses
  double getTotalExpenses() {
    return _box.values.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses for a date range
  double getTotalExpensesForRange(DateTime start, DateTime end) {
    return getExpensesByDateRange(start, end)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses by category
  double getTotalExpensesByCategory(ExpenseCategory category) {
    return getExpensesByCategory(category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses for current month
  List<Expense> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return getExpensesByDateRange(start, end);
  }

  // Get total for current month
  double getCurrentMonthTotal() {
    return getCurrentMonthExpenses()
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
