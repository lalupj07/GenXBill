import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/features/analytics/data/models/analytics_data.dart';
import 'package:genx_bill/features/analytics/data/services/analytics_service.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceRepositoryProvider).getAllInvoices();
    final products = ref.watch(productRepositoryProvider).getActiveProducts();
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;

    final analytics = AnalyticsService.calculateAnalytics(invoices, products);

    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metrics Row
                    _buildKeyMetrics(analytics, currency),
                    const SizedBox(height: 16),

                    // Revenue Trend Chart
                    _buildRevenueChart(analytics, currency),
                    const SizedBox(height: 16),

                    // Two Column Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTopProducts(analytics, currency),
                              const SizedBox(height: 16),
                              _buildCashFlowForecast(analytics, currency),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCustomerBehavior(analytics),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom:
              BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: AppTheme.primaryColor, size: 32),
          const SizedBox(width: 12),
          const Text(
            'Smart Analytics Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(AnalyticsData analytics, String currency) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            CurrencyUtils.formatAmount(analytics.totalRevenue, currency),
            Icons.attach_money,
            Colors.green,
            subtitle: '${analytics.totalInvoices} invoices',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Profit',
            CurrencyUtils.formatAmount(analytics.totalProfit, currency),
            Icons.trending_up,
            Colors.blue,
            subtitle: '${analytics.profitMargin.toStringAsFixed(1)}% margin',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Avg Invoice',
            CurrencyUtils.formatAmount(analytics.averageInvoiceValue, currency),
            Icons.receipt,
            Colors.purple,
            subtitle: 'Per transaction',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Overdue',
            '${analytics.overdueInvoices}',
            Icons.warning,
            Colors.red,
            subtitle: 'Invoices pending',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRevenueChart(AnalyticsData analytics, String currency) {
    if (analytics.revenueHistory.isEmpty) {
      return const GlassContainer(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No revenue data available'),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Revenue Trend (Last 30 Days)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          CurrencyUtils.formatAmount(value, currency),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= analytics.revenueHistory.length) {
                          return const SizedBox();
                        }
                        final date =
                            analytics.revenueHistory[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Revenue line
                  LineChartBarData(
                    spots: analytics.revenueHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                        .toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                  // Profit line
                  LineChartBarData(
                    spots: analytics.revenueHistory
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
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
              _buildLegendItem('Revenue', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Profit', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopProducts(AnalyticsData analytics, String currency) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Top Selling Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (analytics.topProducts.isEmpty)
            const Center(child: Text('No product data available'))
          else
            ...analytics.topProducts.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.quantitySold} units sold',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.formatAmount(
                                product.totalRevenue, currency),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${product.profitMargin.toStringAsFixed(1)}% margin',
                            style: TextStyle(
                              fontSize: 11,
                              color: product.profitMargin > 20
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCustomerBehavior(AnalyticsData analytics) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Customer Payment Behavior',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (analytics.customerBehavior.isEmpty)
            const Center(child: Text('No customer data available'))
          else
            ...analytics.customerBehavior.take(8).map((customer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.clientName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: customer.reliabilityColor
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: customer.reliabilityColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            customer.reliability.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: customer.reliabilityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: customer.creditScore / 100,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              customer.reliabilityColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          customer.creditScore.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: customer.reliabilityColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${customer.paidOnTime} on-time, ${customer.paidLate} late, ${customer.pending} pending',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCashFlowForecast(AnalyticsData analytics, String currency) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Cash Flow Forecast',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildForecastItem(
            '30 Days',
            analytics.cashFlowForecast.expectedIncome30Days,
            currency,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildForecastItem(
            '60 Days',
            analytics.cashFlowForecast.expectedIncome60Days,
            currency,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildForecastItem(
            '90 Days',
            analytics.cashFlowForecast.expectedIncome90Days,
            currency,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildForecastItem(
            'Overdue Amount',
            analytics.cashFlowForecast.overdueAmount,
            currency,
            Colors.red,
            isOverdue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(
    String label,
    double amount,
    String currency,
    Color color, {
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          CurrencyUtils.formatAmount(amount, currency),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
