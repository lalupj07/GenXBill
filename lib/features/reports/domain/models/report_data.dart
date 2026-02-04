import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';

class ReportData {
  final double revenue;
  final double expenses;
  final double netProfit;
  final int transactionCount;
  final String periodName;
  final List<Invoice> invoices;
  final List<Expense> expenseList;

  // Analytics fields
  final Map<String, double> topProducts; // Name -> Quantity
  final Map<String, double> topCustomers; // Name -> Total Revenue
  final Map<String, double> expensesByCategory; // Category -> Amount
  final List<ChartPoint> dailyRevenue;
  final List<ChartPoint> dailyExpenses;

  // Advanced Analytics fields
  final double profitMargin;
  final double averageInvoiceValue;
  final int newCustomers;

  ReportData({
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.transactionCount,
    required this.periodName,
    required this.invoices,
    required this.expenseList,
    required this.topProducts,
    required this.topCustomers,
    required this.expensesByCategory,
    required this.dailyRevenue,
    required this.dailyExpenses,
    required this.profitMargin,
    required this.averageInvoiceValue,
    required this.newCustomers,
  });
}

class ChartPoint {
  final DateTime date;
  final double value;

  ChartPoint(this.date, this.value);
}
