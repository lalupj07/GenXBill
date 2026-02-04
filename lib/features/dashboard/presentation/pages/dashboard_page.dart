import 'package:flutter/material.dart';
import 'package:genx_bill/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/core/services/analytics_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/l10n/app_localizations.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/models/app_settings.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceBox = ref.watch(invoiceBoxProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                top: true,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcomeBack,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ).animate().fadeIn().slideX(begin: -0.2),
                            const SizedBox(height: 4),
                            Text(
                              l10n.businessOverview,
                              style: const TextStyle(color: Colors.grey),
                            )
                                .animate()
                                .fadeIn()
                                .slideX(begin: -0.2, delay: 100.ms),
                            const SizedBox(height: 24),

                            // Stats Grid with REAL DATA
                            LayoutBuilder(builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 900;
                              final isTablet = constraints.maxWidth > 600;
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: isWide ? 4 : (isTablet ? 3 : 2),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildStatCard(
                                    l10n.totalRevenue,
                                    CurrencyUtils.formatAmount(
                                        stats.totalRevenue, settings.currency),
                                    Icons.attach_money,
                                    Colors.green,
                                    '${stats.totalInvoices} ${l10n.invoices}',
                                  ),
                                  _buildStatCard(
                                    l10n.totalExpenses,
                                    CurrencyUtils.formatAmount(
                                        stats.totalExpenses, settings.currency),
                                    Icons.money_off,
                                    Colors.redAccent,
                                    '${stats.monthlyFinancials.fold(0, (sum, m) => sum + m.expenseCount)} ${l10n.expenses}',
                                  ),
                                  _buildStatCard(
                                    l10n.netProfit,
                                    CurrencyUtils.formatAmount(
                                        stats.netProfit, settings.currency),
                                    Icons.show_chart,
                                    stats.netProfit >= 0
                                        ? Colors.blue
                                        : Colors.orange,
                                    '${stats.totalRevenue > 0 ? ((stats.netProfit / stats.totalRevenue) * 100).toStringAsFixed(1) : "0.0"}% margin',
                                  ),
                                  _buildStatCard(
                                    l10n.paidAmount,
                                    CurrencyUtils.formatAmount(
                                        stats.paidAmount, settings.currency),
                                    Icons.check_circle,
                                    Colors.teal,
                                    '${stats.paidInvoices} paid',
                                  ),
                                  _buildStatCard(
                                    l10n.unpaidAmount,
                                    CurrencyUtils.formatAmount(
                                        stats.unpaidAmount, settings.currency),
                                    Icons.pending_actions,
                                    Colors.orangeAccent,
                                    '${stats.unpaidInvoices} pending',
                                  ),
                                  _buildStatCard(
                                    l10n.overdueAmount,
                                    CurrencyUtils.formatAmount(
                                        stats.overdueAmount, settings.currency),
                                    Icons.warning,
                                    Colors.red,
                                    '${stats.overdueInvoices} overdue',
                                  ),
                                ],
                              );
                            }),

                            const SizedBox(height: 24),

                            // Financial Trend Chart
                            if (stats.monthlyFinancials.isNotEmpty)
                              GlassContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.financialTrend,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.circle,
                                                color: AppTheme.primaryColor,
                                                size: 10),
                                            const SizedBox(width: 4),
                                            Text(l10n.revenue,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.circle,
                                                color: Colors.redAccent,
                                                size: 10),
                                            const SizedBox(width: 4),
                                            Text(l10n.totalExpenses,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 250,
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: stats
                                                    .monthlyFinancials
                                                    .map((e) =>
                                                        (e.revenue > e.expenses
                                                            ? e.revenue
                                                            : e.expenses) +
                                                        1) // avoid div by 0
                                                    .reduce((a, b) =>
                                                        a > b ? a : b) /
                                                5,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.white
                                                    .withValues(alpha: 0.1),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 30,
                                                interval: 1,
                                                getTitlesWidget: (double value,
                                                    TitleMeta meta) {
                                                  final index = value.toInt();
                                                  if (index >= 0 &&
                                                      index <
                                                          stats
                                                              .monthlyFinancials
                                                              .length) {
                                                    final month = stats
                                                        .monthlyFinancials[
                                                            index]
                                                        .month
                                                        .split(' ')[0];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        month,
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: stats
                                                        .monthlyFinancials
                                                        .map((e) =>
                                                            (e.revenue >
                                                                    e.expenses
                                                                ? e.revenue
                                                                : e.expenses) +
                                                            1)
                                                        .reduce((a, b) =>
                                                            a > b ? a : b) /
                                                    3,
                                                reservedSize: 50,
                                                getTitlesWidget: (double value,
                                                    TitleMeta meta) {
                                                  return Text(
                                                    '${(value / 1000).toStringAsFixed(0)}k',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          minX: 0,
                                          maxX:
                                              (stats.monthlyFinancials.length -
                                                      1)
                                                  .toDouble(),
                                          minY: 0,
                                          maxY: stats.monthlyFinancials
                                                  .map((e) =>
                                                      e.revenue > e.expenses
                                                          ? e.revenue
                                                          : e.expenses)
                                                  .fold<double>(
                                                      0,
                                                      (max, val) => val > max
                                                          ? val
                                                          : max) *
                                              1.2,
                                          lineBarsData: [
                                            // Revenue
                                            LineChartBarData(
                                              spots: stats.monthlyFinancials
                                                  .asMap()
                                                  .entries
                                                  .map((e) => FlSpot(
                                                      e.key.toDouble(),
                                                      e.value.revenue))
                                                  .toList(),
                                              isCurved: true,
                                              color: AppTheme.primaryColor,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData:
                                                  const FlDotData(show: true),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                            // Expenses
                                            LineChartBarData(
                                              spots: stats.monthlyFinancials
                                                  .asMap()
                                                  .entries
                                                  .map((e) => FlSpot(
                                                      e.key.toDouble(),
                                                      e.value.expenses))
                                                  .toList(),
                                              isCurved: true,
                                              color: Colors.redAccent,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData:
                                                  const FlDotData(show: true),
                                              belowBarData:
                                                  BarAreaData(show: false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 200.ms)
                                  .slideY(begin: 0.1),

                            const SizedBox(height: 24),

                            // Top Clients
                            if (stats.topClients.isNotEmpty)
                              GlassContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.topClients,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    ...stats.topClients.take(5).map((client) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppTheme
                                                  .primaryColor
                                                  .withValues(alpha: 0.2),
                                              child: Text(
                                                client.clientName.isNotEmpty
                                                    ? client.clientName[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    client.clientName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${client.invoiceCount} invoice${client.invoiceCount > 1 ? 's' : ''}',
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              CurrencyUtils.formatAmount(
                                                  client.totalAmount,
                                                  settings.currency),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .slideY(begin: 0.1),

                            const SizedBox(height: 24),

                            // Top Expenses
                            if (stats.topExpenseCategories.isNotEmpty) ...[
                              GlassContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.topExpenses,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    ...stats.topExpenseCategories.map((stat) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.redAccent
                                                  .withValues(alpha: 0.2),
                                              child: const Icon(Icons.category,
                                                  color: Colors.redAccent,
                                                  size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stat.category,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${stat.count} transaction${stat.count > 1 ? 's' : ''}',
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              CurrencyUtils.formatAmount(
                                                  stat.amount,
                                                  settings.currency),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 350.ms)
                                  .slideY(begin: 0.1),
                              const SizedBox(height: 24),
                            ],

                            // Recent Invoices
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.recentInvoices,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  ValueListenableBuilder(
                                    valueListenable: invoiceBox.listenable(),
                                    builder: (context, Box<Invoice> box, _) {
                                      final invoices =
                                          box.values.toList().cast<Invoice>();
                                      final recentInvoices =
                                          invoices.reversed.take(5).toList();

                                      if (recentInvoices.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Text(
                                              l10n.noInvoicesYet,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        children: recentInvoices.map((invoice) {
                                          return _buildInvoiceItem(
                                              invoice, settings);
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoicePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newInvoice),
        backgroundColor: AppTheme.primaryColor,
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 20,
            child: Icon(Icons.flash_on, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'GenXBill',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                subtitle,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale();
  }

  Widget _buildInvoiceItem(Invoice invoice, AppSettings settings) {
    Color statusColor;
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = Colors.green;
        break;
      case InvoiceStatus.sent:
        statusColor = Colors.orange;
        break;
      case InvoiceStatus.overdue:
        statusColor = Colors.red;
        break;
      case InvoiceStatus.draft:
        statusColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  invoice.clientName,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatAmount(invoice.total, settings.currency),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invoice.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
