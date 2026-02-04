import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/reports/domain/models/report_data.dart';
import 'package:genx_bill/core/services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/services/csv_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:genx_bill/core/widgets/main_layout.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/l10n/app_localizations.dart';
import 'package:genx_bill/core/models/app_settings.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Month',
    'Last Month',
    'This Year',
    'Last Year',
    'All Time'
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    // We'll calculate report data on the fly for now based on selection
    final reportData = _calculateReportData(ref);

    return Scaffold(
      body: ThemeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 24),
                      _buildSummaryCards(reportData, settings),
                      const SizedBox(height: 24),
                      _buildProfitLossChart(reportData),
                      const SizedBox(height: 24),
                      _buildExpensePieChart(reportData),
                      const SizedBox(height: 24),
                      _buildTopInsights(reportData, settings),
                      const SizedBox(height: 24),
                      _buildDetailedTable(reportData, settings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportOptions(context, reportData),
        icon: const Icon(Icons.download),
        label: const Text('Export Report'),
        backgroundColor: AppTheme.primaryColor,
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              ref.read(navigationProvider.notifier).state = 0;
            },
            tooltip: 'Back to Home',
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 20,
            child: Icon(Icons.analytics, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Financial Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('${l10n.search}:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: const Color(0xFF1E1B4B),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white70),
                isExpanded: true,
                items: _periods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSummaryCards(ReportData data, AppSettings settings) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            'Total Revenue', data.revenue, Icons.attach_money, Colors.green,
            currency: settings.currency),
        _buildStatCard(
            'Total Expenses', data.expenses, Icons.money_off, Colors.redAccent,
            currency: settings.currency),
        _buildStatCard('Net Profit', data.netProfit, Icons.show_chart,
            data.netProfit >= 0 ? Colors.blue : Colors.orange,
            currency: settings.currency),
        _buildStatCard('Profit Margin', data.profitMargin * 100, Icons.percent,
            Colors.teal,
            isCurrency: false, suffix: '%'),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color,
      {bool isCurrency = true, String? suffix, String currency = 'INR'}) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCurrency
                    ? CurrencyUtils.formatAmount(value, currency)
                    : '${value.toStringAsFixed(isCurrency ? 2 : 0)}${suffix ?? ""}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTable(ReportData data, AppSettings settings) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRow('Invoiced Amount', data.revenue,
              isPositive: true, currency: settings.currency),
          const Divider(color: Colors.white10),
          _buildRow('Expense Amount', data.expenses,
              isPositive: false, currency: settings.currency),
          const Divider(color: Colors.white10, thickness: 2),
          _buildRow('Net Profit', data.netProfit,
              isBold: true,
              isPositive: data.netProfit >= 0,
              currency: settings.currency),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRow(String label, double amount,
      {bool isPositive = true, bool isBold = false, String currency = 'INR'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            CurrencyUtils.formatAmount(amount, currency),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isPositive ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  ReportData _calculateReportData(WidgetRef ref) {
    final invoiceBox = ref.watch(invoiceBoxProvider);
    final expenseBox = ref.watch(expenseBoxProvider);

    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (_selectedPeriod) {
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0); // Last day of prev month
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      case 'Last Year':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year - 1, 12, 31);
        break;
      case 'All Time':
        start = DateTime(2000); // Far past
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    final invoices = invoiceBox.values
        .where((inv) =>
            inv.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            inv.date.isBefore(end.add(const Duration(days: 1))))
        .toList();

    final expenses = expenseBox.values
        .where((exp) =>
            exp.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            exp.date.isBefore(end.add(const Duration(days: 1))))
        .toList();

    final revenue = invoices.fold<double>(0, (sum, inv) => sum + inv.total);
    final totalExpenses =
        expenses.fold<double>(0, (sum, exp) => sum + exp.amount);

    // Analytics calculation
    final Map<String, double> topProducts = {};
    final Map<String, double> topCustomers = {};
    final Map<DateTime, double> revenueMap = {};
    final Map<DateTime, double> expenseMap = {};

    for (var inv in invoices) {
      // Top Customers
      topCustomers[inv.clientName] =
          (topCustomers[inv.clientName] ?? 0) + inv.total;

      // Top Products
      for (var item in inv.items) {
        topProducts[item.description] =
            (topProducts[item.description] ?? 0) + item.quantity;
      }

      // Daily Revenue
      final date = DateTime(inv.date.year, inv.date.month, inv.date.day);
      revenueMap[date] = (revenueMap[date] ?? 0) + inv.total;
    }

    for (var exp in expenses) {
      final date = DateTime(exp.date.year, exp.date.month, exp.date.day);
      expenseMap[date] = (expenseMap[date] ?? 0) + exp.amount;
    }

    final dailyRevenueList = revenueMap.entries
        .map((e) => ChartPoint(e.key, e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final dailyExpensesList = expenseMap.entries
        .map((e) => ChartPoint(e.key, e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get top 5
    final sortedProducts = Map.fromEntries(topProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
    final sortedCustomers = Map.fromEntries(topCustomers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));

    // Expense Breakdown
    final Map<String, double> expensesByCategory = {};
    for (var exp in expenses) {
      expensesByCategory[exp.category.toString().split('.').last] =
          (expensesByCategory[exp.category.toString().split('.').last] ?? 0) +
              exp.amount;
    }

    // Advanced analytics
    final profitMargin =
        revenue > 0 ? (revenue - totalExpenses) / revenue : 0.0;
    final averageInvoiceValue =
        invoices.isNotEmpty ? revenue / invoices.length : 0.0;

    // New customers calculation (simplified: customers with only one invoice in this period)
    // Realistically we'd check if they had invoices before this period.
    final newCustomers = topCustomers.length;

    return ReportData(
      revenue: revenue,
      expenses: totalExpenses,
      netProfit: revenue - totalExpenses,
      transactionCount: invoices.length + expenses.length,
      periodName: _selectedPeriod,
      invoices: invoices,
      expenseList: expenses,
      topProducts: sortedProducts,
      topCustomers: sortedCustomers,
      expensesByCategory: expensesByCategory,
      dailyRevenue: dailyRevenueList,
      dailyExpenses: dailyExpensesList,
      profitMargin: profitMargin,
      averageInvoiceValue: averageInvoiceValue,
      newCustomers: newCustomers,
    );
  }

  Widget _buildProfitLossChart(ReportData data) {
    if (data.dailyRevenue.isEmpty && data.dailyExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue vs Expenses Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.dailyRevenue.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: data.dailyExpenses.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Revenue', Colors.green),
              const SizedBox(width: 24),
              _buildLegend('Expenses', Colors.redAccent),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildExpensePieChart(ReportData data) {
    if (data.expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Colors for pie chart
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    int colorIndex = 0;
    final sections = data.expensesByCategory.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title:
            '${e.key}\n${((e.value / data.expenses) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.expensesByCategory.entries.map((e) {
                      // Find color logic again or map it better.
                      // Simplified for now, just restart color loop logic visually
                      // Actually, let's keep it simple.
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            // Just a bullet point
                            Container(
                                width: 8, height: 8, color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(e.key,
                                    style: const TextStyle(fontSize: 12))),
                            Text('\$${e.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopInsights(ReportData data, AppSettings settings) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Products',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...data.topProducts.entries.take(5).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(e.key,
                                  style: const TextStyle(fontSize: 12))),
                          Text('${e.value.toInt()} qty',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Best Customers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...data.topCustomers.entries.take(5).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(e.key,
                                  style: const TextStyle(fontSize: 12))),
                          Text(
                              CurrencyUtils.formatAmount(
                                  e.value, settings.currency),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  void _showExportOptions(BuildContext context, ReportData data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B4B),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(context);
                final settings = ref.read(settingsProvider);
                final pdfBytes =
                    await PdfService().generateFinancialReport(data, settings);
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfBytes,
                  name: 'Financial_Report_${data.periodName}.pdf',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              onTap: () async {
                Navigator.pop(context);
                final settings = ref.read(settingsProvider);
                final csvData = CsvService().generateReportCsv(data, settings);

                final directory = await getApplicationDocumentsDirectory();
                final path = '${directory.path}/GenXBill/Reports';
                await Directory(path).create(recursive: true);
                final file = File(
                    '$path/Report_${data.periodName.replaceAll(' ', '_')}.csv');
                await file.writeAsString(csvData);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved to ${file.path}')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize, color: Colors.blue),
              title: const Text('HSN-wise Summary (CSV)'),
              onTap: () async {
                Navigator.pop(context);
                final settings = ref.read(settingsProvider);
                final csvData =
                    CsvService().generateHsnSummaryCsv(data.invoices, settings);

                final directory = await getApplicationDocumentsDirectory();
                final path = '${directory.path}/GenXBill/Reports';
                await Directory(path).create(recursive: true);
                final file = File(
                    '$path/HSN_Summary_${data.periodName.replaceAll(' ', '_')}.csv');
                await file.writeAsString(csvData);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('HSN Summary saved to ${file.path}')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.orange),
              title: const Text('Products Export (CSV)'),
              onTap: () async {
                Navigator.pop(context);
                final settings = ref.read(settingsProvider);
                final products =
                    ref.read(productRepositoryProvider).getAllProducts();
                final csvData =
                    CsvService().generateProductOnlyCsv(products, settings);

                final directory = await getApplicationDocumentsDirectory();
                final path = '${directory.path}/GenXBill/Reports';
                await Directory(path).create(recursive: true);
                final file = File('$path/Products_Export.csv');
                await file.writeAsString(csvData);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Products exported to ${file.path}')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
