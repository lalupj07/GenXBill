import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:genx_bill/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:genx_bill/core/widgets/main_layout.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  ExpenseCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final expenseRepo = ref.watch(expenseRepositoryProvider);
    final expenses = expenseRepo.getAllExpenses();

    // Filter expenses
    final filteredExpenses = expenses.where((expense) {
      final matchesCategory =
          _selectedCategory == null || expense.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          expense.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (expense.vendor?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesCategory && matchesSearch;
    }).toList();

    // Sort by date (newest first)
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    final totalExpenses = expenseRepo.getTotalExpenses();
    final monthlyExpenses = expenseRepo.getCurrentMonthTotal();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppTheme.primaryColor,
      ).animate().scale(delay: 300.ms),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            ref.read(navigationProvider.notifier).state = 0;
                          },
                          tooltip: 'Back to Home',
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Expenses',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Text(
                      'Track your business expenses',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Expenses',
                    '\$${totalExpenses.toStringAsFixed(2)}',
                    Icons.receipt_long,
                    Colors.red,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '\$${monthlyExpenses.toStringAsFixed(2)}',
                    Icons.calendar_month,
                    Colors.orange,
                  ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Count',
                    '${expenses.length}',
                    Icons.numbers,
                    Colors.blue,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<ExpenseCategory?>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ExpenseCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Expenses List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: Colors.grey.shade700),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedCategory == null
                                ? 'No expenses yet'
                                : 'No expenses found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first expense to get started',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return _buildExpenseCard(expense, index)
                            .animate()
                            .fadeIn(delay: (50 * index).ms)
                            .slideX(begin: -0.1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_getCategoryName(expense.category)),
            if (expense.vendor != null) ...[
              const SizedBox(height: 2),
              Text('Vendor: ${expense.vendor}',
                  style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().format(expense.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deleteExpense(expense.id),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ExpenseCategory category) {
    return Expense(
      id: '',
      description: '',
      amount: 0,
      date: DateTime.now(),
      category: category,
    ).getCategoryName();
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.office:
        return Icons.business;
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.supplies:
        return Icons.inventory;
      case ExpenseCategory.utilities:
        return Icons.bolt;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.salary:
        return Icons.payments;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.equipment:
        return Icons.hardware;
      case ExpenseCategory.software:
        return Icons.computer;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.office:
        return Colors.blue;
      case ExpenseCategory.travel:
        return Colors.purple;
      case ExpenseCategory.supplies:
        return Colors.green;
      case ExpenseCategory.utilities:
        return Colors.orange;
      case ExpenseCategory.marketing:
        return Colors.pink;
      case ExpenseCategory.salary:
        return Colors.teal;
      case ExpenseCategory.rent:
        return Colors.brown;
      case ExpenseCategory.equipment:
        return Colors.indigo;
      case ExpenseCategory.software:
        return Colors.cyan;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result == true && mounted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteExpense(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(expenseRepositoryProvider).deleteExpense(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted!')),
        );
      }
    }
  }
}
