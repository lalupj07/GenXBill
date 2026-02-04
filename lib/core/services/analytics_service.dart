import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';

class DashboardStats {
  final double totalRevenue;
  final double paidAmount;
  final double unpaidAmount;
  final double overdueAmount;
  final double totalExpenses;
  final double netProfit;
  final int totalInvoices;
  final int paidInvoices;
  final int unpaidInvoices;
  final int overdueInvoices;
  final double averageInvoiceValue;
  final List<MonthlyFinancials> monthlyFinancials;
  final List<ClientRevenue> topClients;
  final List<ExpenseCategoryStat> topExpenseCategories;

  DashboardStats({
    required this.totalRevenue,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.overdueAmount,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.unpaidInvoices,
    required this.overdueInvoices,
    required this.averageInvoiceValue,
    required this.monthlyFinancials,
    required this.topClients,
    required this.topExpenseCategories,
  });
}

class MonthlyFinancials {
  final String month;
  final double revenue;
  final double expenses;
  final int invoiceCount;
  final int expenseCount;

  MonthlyFinancials({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.invoiceCount,
    required this.expenseCount,
  });
}

class ClientRevenue {
  final String clientName;
  final double totalAmount;
  final int invoiceCount;

  ClientRevenue({
    required this.clientName,
    required this.totalAmount,
    required this.invoiceCount,
  });
}

class ExpenseCategoryStat {
  final String category;
  final double amount;
  final int count;

  ExpenseCategoryStat({
    required this.category,
    required this.amount,
    required this.count,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final invoiceBox = ref.watch(invoiceBoxProvider);
  final invoices = invoiceBox.values.toList();

  final expenseBox = ref.watch(expenseBoxProvider);
  final expenses = expenseBox.values.toList();

  if (invoices.isEmpty && expenses.isEmpty) {
    return DashboardStats(
      totalRevenue: 0,
      paidAmount: 0,
      unpaidAmount: 0,
      overdueAmount: 0,
      totalExpenses: 0,
      netProfit: 0,
      totalInvoices: 0,
      paidInvoices: 0,
      unpaidInvoices: 0,
      overdueInvoices: 0,
      averageInvoiceValue: 0,
      monthlyFinancials: [],
      topClients: [],
      topExpenseCategories: [],
    );
  }

  // Calculate basic invoice stats
  final totalRevenue = invoices.fold<double>(0, (sum, inv) => sum + inv.total);
  final paidInvoicesList =
      invoices.where((inv) => inv.status == InvoiceStatus.paid).toList();
  final unpaidInvoicesList = invoices
      .where((inv) =>
          inv.status == InvoiceStatus.draft || inv.status == InvoiceStatus.sent)
      .toList();
  final overdueInvoicesList =
      invoices.where((inv) => inv.status == InvoiceStatus.overdue).toList();

  final paidAmount =
      paidInvoicesList.fold<double>(0, (sum, inv) => sum + inv.total);
  final unpaidAmount =
      unpaidInvoicesList.fold<double>(0, (sum, inv) => sum + inv.total);
  final overdueAmount =
      overdueInvoicesList.fold<double>(0, (sum, inv) => sum + inv.total);

  // Calculate expense stats
  final totalExpenses =
      expenses.fold<double>(0, (sum, exp) => sum + exp.amount);
  final netProfit = totalRevenue - totalExpenses;

  // Calculate monthly stats (last 6 months)
  final now = DateTime.now();
  final monthlyStatsMap = <String, MonthlyFinancials>{};

  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthKey = '${_getMonthName(month.month)} ${month.year}';
    monthlyStatsMap[monthKey] = MonthlyFinancials(
      month: monthKey,
      revenue: 0,
      expenses: 0,
      invoiceCount: 0,
      expenseCount: 0,
    );
  }

  for (var invoice in invoices) {
    final monthKey =
        '${_getMonthName(invoice.date.month)} ${invoice.date.year}';
    if (monthlyStatsMap.containsKey(monthKey)) {
      final existing = monthlyStatsMap[monthKey]!;
      monthlyStatsMap[monthKey] = MonthlyFinancials(
        month: monthKey,
        revenue: existing.revenue + invoice.total,
        expenses: existing.expenses,
        invoiceCount: existing.invoiceCount + 1,
        expenseCount: existing.expenseCount,
      );
    }
  }

  for (var expense in expenses) {
    final monthKey =
        '${_getMonthName(expense.date.month)} ${expense.date.year}';
    if (monthlyStatsMap.containsKey(monthKey)) {
      final existing = monthlyStatsMap[monthKey]!;
      monthlyStatsMap[monthKey] = MonthlyFinancials(
        month: monthKey,
        revenue: existing.revenue,
        expenses: existing.expenses + expense.amount,
        invoiceCount: existing.invoiceCount,
        expenseCount: existing.expenseCount + 1,
      );
    }
  }

  // Calculate top clients by revenue
  final clientRevenueMap = <String, ClientRevenue>{};
  for (var invoice in invoices) {
    if (clientRevenueMap.containsKey(invoice.clientName)) {
      final existing = clientRevenueMap[invoice.clientName]!;
      clientRevenueMap[invoice.clientName] = ClientRevenue(
        clientName: invoice.clientName,
        totalAmount: existing.totalAmount + invoice.total,
        invoiceCount: existing.invoiceCount + 1,
      );
    } else {
      clientRevenueMap[invoice.clientName] = ClientRevenue(
        clientName: invoice.clientName,
        totalAmount: invoice.total,
        invoiceCount: 1,
      );
    }
  }

  final topClients = clientRevenueMap.values.toList()
    ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  // Calculate top expense categories
  final expenseCategoryMap = <String, ExpenseCategoryStat>{};
  for (var expense in expenses) {
    // Determine category display name (capitalize first letter)
    final catName = expense.category.name[0].toUpperCase() +
        expense.category.name.substring(1);

    if (expenseCategoryMap.containsKey(catName)) {
      final existing = expenseCategoryMap[catName]!;
      expenseCategoryMap[catName] = ExpenseCategoryStat(
        category: catName,
        amount: existing.amount + expense.amount,
        count: existing.count + 1,
      );
    } else {
      expenseCategoryMap[catName] = ExpenseCategoryStat(
        category: catName,
        amount: expense.amount,
        count: 1,
      );
    }
  }

  final topExpenseCategories = expenseCategoryMap.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return DashboardStats(
    totalRevenue: totalRevenue,
    paidAmount: paidAmount,
    unpaidAmount: unpaidAmount,
    overdueAmount: overdueAmount,
    totalExpenses: totalExpenses,
    netProfit: netProfit,
    totalInvoices: invoices.length,
    paidInvoices: paidInvoicesList.length,
    unpaidInvoices: unpaidInvoicesList.length,
    overdueInvoices: overdueInvoicesList.length,
    averageInvoiceValue: invoices.isEmpty ? 0 : totalRevenue / invoices.length,
    monthlyFinancials: monthlyStatsMap.values.toList(),
    topClients: topClients.take(5).toList(),
    topExpenseCategories: topExpenseCategories.take(5).toList(),
  );
});

String _getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}
