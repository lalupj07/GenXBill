import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/features/invoices/presentation/pages/invoices_page.dart';
import 'package:genx_bill/features/products/presentation/pages/products_page.dart';

class SmartInsightsWidget extends ConsumerWidget {
  const SmartInsightsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceBox = ref.watch(invoiceBoxProvider);
    final expenseBox = ref.watch(expenseBoxProvider);
    final productBox = ref.watch(productBoxProvider);
    final settings = ref.watch(settingsProvider);

    // --- Calculations ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Day Book
    final todaysInvoices = invoiceBox.values.where((i) {
      final iDate = i.date;
      return iDate.year == today.year &&
          iDate.month == today.month &&
          iDate.day == today.day;
    }).toList();

    final todaysExpenses = expenseBox.values.where((e) {
      final eDate = e.date;
      return eDate.year == today.year &&
          eDate.month == today.month &&
          eDate.day == today.day;
    }).toList();

    final todaysSalesAmount =
        todaysInvoices.fold(0.0, (sum, i) => sum + i.total);
    final todaysExpenseAmount =
        todaysExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final netToday = todaysSalesAmount - todaysExpenseAmount;

    // 2. Alerts
    final overdueInvoices = invoiceBox.values
        .where((i) => i.status == InvoiceStatus.overdue)
        .toList();
    final lowStockProducts = productBox.values
        .where((p) => p.isActive && p.stockQuantity <= p.minStockLevel)
        .toList();

    // 3. Greeting
    String greeting = 'Hello!';
    if (now.hour < 12) {
      greeting = 'Good Morning!';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    String insightMessage =
        "You're off to a great start. Keep pushing forward!";
    if (netToday > 0) {
      insightMessage =
          "Positive cash flow today! You're up by ${CurrencyUtils.formatAmount(netToday, settings.currency)}.";
    } else if (todaysExpenses.isNotEmpty && todaysInvoices.isEmpty) {
      insightMessage = "Recorded expenses today. Time to make some sales!";
    } else if (overdueInvoices.isNotEmpty) {
      insightMessage =
          "You have ${overdueInvoices.length} overdue invoices. Consider sending reminders.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Greeting Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.secondaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insightMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Day Book Grid
        LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: _buildDayBookCard(
                  'Sales Today',
                  CurrencyUtils.formatAmount(
                      todaysSalesAmount, settings.currency),
                  '${todaysInvoices.length} Invoices',
                  Icons.show_chart,
                  Colors.green,
                  context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDayBookCard(
                  'Expenses Today',
                  CurrencyUtils.formatAmount(
                      todaysExpenseAmount, settings.currency),
                  '${todaysExpenses.length} Transactions',
                  Icons.money_off,
                  Colors.redAccent,
                  context,
                ),
              ),
            ],
          );
        }),

        if (overdueInvoices.isNotEmpty || lowStockProducts.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Action Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Action Cards (Horizontal Scroll if needed, or Column)
          if (overdueInvoices.isNotEmpty)
            _buildActionItem(
              icon: Icons.access_time_filled,
              color: Colors.orange,
              title: '${overdueInvoices.length} Overdue Invoices',
              subtitle:
                  'Total Amount: ${CurrencyUtils.formatAmount(overdueInvoices.fold(0.0, (s, i) => s + i.total), settings.currency)}',
              actionLabel: 'View All',
              context: context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoicesPage(
                        initialStatus: InvoiceStatus.overdue),
                  ),
                );
              },
            ),
          if (lowStockProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildActionItem(
                icon: Icons.inventory_2,
                color: Colors.red,
                title: '${lowStockProducts.length} Items Low on Stock',
                subtitle: 'Restock recommended',
                actionLabel: 'Check Stock',
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(),
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildDayBookCard(String title, String value, String subtitle,
      IconData icon, Color color, BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
