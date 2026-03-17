import 'package:genx_bill/features/analytics/data/models/analytics_data.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';

/// Service for calculating business analytics and insights
class AnalyticsService {
  /// Calculate comprehensive analytics from invoice data
  static AnalyticsData calculateAnalytics(
    List<Invoice> invoices,
    List<Product> products,
  ) {
    if (invoices.isEmpty) {
      return _emptyAnalytics();
    }

    // Calculate basic metrics
    final totalRevenue = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );

    final totalProfit = _calculateTotalProfit(invoices, products);
    final profitMargin =
        totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;

    final paidInvoices =
        invoices.where((i) => i.status == InvoiceStatus.paid).length;
    final pendingInvoices = invoices
        .where((i) =>
            i.status == InvoiceStatus.sent || i.status == InvoiceStatus.draft)
        .length;
    final overdueInvoices = _countOverdueInvoices(invoices);

    final averageInvoiceValue = totalRevenue / invoices.length.toDouble();

    // Generate revenue history (last 30 days)
    final revenueHistory = _generateRevenueHistory(invoices, products);

    // Calculate top products
    final topProducts = _calculateTopProducts(invoices, products);

    // Analyze customer payment behavior
    final customerBehavior = _analyzeCustomerBehavior(invoices);

    // Generate cash flow forecast
    final cashFlowForecast = _generateCashFlowForecast(invoices);

    return AnalyticsData(
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      profitMargin: profitMargin,
      totalInvoices: invoices.length,
      paidInvoices: paidInvoices,
      pendingInvoices: pendingInvoices,
      overdueInvoices: overdueInvoices,
      averageInvoiceValue: averageInvoiceValue,
      revenueHistory: revenueHistory,
      topProducts: topProducts,
      customerBehavior: customerBehavior,
      cashFlowForecast: cashFlowForecast,
    );
  }

  static AnalyticsData _emptyAnalytics() {
    return AnalyticsData(
      totalRevenue: 0,
      totalProfit: 0,
      profitMargin: 0,
      totalInvoices: 0,
      paidInvoices: 0,
      pendingInvoices: 0,
      overdueInvoices: 0,
      averageInvoiceValue: 0,
      revenueHistory: [],
      topProducts: [],
      customerBehavior: [],
      cashFlowForecast: CashFlowForecast(
        expectedIncome30Days: 0,
        expectedIncome60Days: 0,
        expectedIncome90Days: 0,
        overdueAmount: 0,
        forecastData: [],
      ),
    );
  }

  static double _calculateTotalProfit(
      List<Invoice> invoices, List<Product> products) {
    // Since Product model doesn't have costPrice, we'll estimate profit as 30% of revenue
    // This can be enhanced later by adding costPrice to Product model
    double totalRevenue =
        invoices.fold<double>(0, (sum, invoice) => sum + invoice.total);
    return totalRevenue * 0.30; // Assume 30% profit margin
  }

  static int _countOverdueInvoices(List<Invoice> invoices) {
    final now = DateTime.now();
    return invoices.where((invoice) {
      return invoice.status != InvoiceStatus.paid &&
          invoice.dueDate.isBefore(now);
    }).length;
  }

  static List<RevenueDataPoint> _generateRevenueHistory(
    List<Invoice> invoices,
    List<Product> products,
  ) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Group invoices by date
    final Map<DateTime, List<Invoice>> invoicesByDate = {};

    for (var invoice in invoices) {
      if (invoice.date.isAfter(thirtyDaysAgo)) {
        final dateKey =
            DateTime(invoice.date.year, invoice.date.month, invoice.date.day);
        invoicesByDate.putIfAbsent(dateKey, () => []).add(invoice);
      }
    }

    // Create data points
    final dataPoints = <RevenueDataPoint>[];
    for (var i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final dateKey = DateTime(date.year, date.month, date.day);
      final dayInvoices = invoicesByDate[dateKey] ?? [];

      final revenue =
          dayInvoices.fold<double>(0, (sum, inv) => sum + inv.total);
      final profit = _calculateDayProfit(dayInvoices, products);

      dataPoints.add(RevenueDataPoint(
        date: dateKey,
        revenue: revenue,
        profit: profit,
        invoiceCount: dayInvoices.length,
      ));
    }

    return dataPoints;
  }

  static double _calculateDayProfit(
      List<Invoice> invoices, List<Product> products) {
    // Estimate profit as 30% of revenue
    double revenue = invoices.fold<double>(0, (sum, inv) => sum + inv.total);
    return revenue * 0.30;
  }

  static List<ProductSalesData> _calculateTopProducts(
    List<Invoice> invoices,
    List<Product> products,
  ) {
    final Map<String, ProductSalesData> productSales = {};

    for (var invoice in invoices) {
      for (var item in invoice.items) {
        final product = products.firstWhere(
          (p) => p.name == item.description,
          orElse: () => Product(
            id: item.description,
            name: item.description,
            description: '',
            sku: '',
            unitPrice: item.unitPrice,
            stockQuantity: 0,
            hsnCode: '',
          ),
        );

        final itemRevenue = item.unitPrice * item.quantity;
        final itemProfit = itemRevenue * 0.30; // Estimate 30% profit margin

        if (productSales.containsKey(product.id)) {
          final existing = productSales[product.id]!;
          productSales[product.id] = ProductSalesData(
            productId: product.id,
            productName: product.name,
            quantitySold: existing.quantitySold + item.quantity.toInt(),
            totalRevenue: existing.totalRevenue + itemRevenue,
            totalProfit: existing.totalProfit + itemProfit,
            profitMargin: 0, // Will calculate after
          );
        } else {
          productSales[product.id] = ProductSalesData(
            productId: product.id,
            productName: product.name,
            quantitySold: item.quantity.toInt(),
            totalRevenue: itemRevenue,
            totalProfit: itemProfit,
            profitMargin: 0,
          );
        }
      }
    }

    // Calculate profit margins and sort by revenue
    final salesList = productSales.values.map((data) {
      final margin = data.totalRevenue > 0
          ? (data.totalProfit / data.totalRevenue) * 100
          : 0.0;
      return ProductSalesData(
        productId: data.productId,
        productName: data.productName,
        quantitySold: data.quantitySold,
        totalRevenue: data.totalRevenue,
        totalProfit: data.totalProfit,
        profitMargin: margin,
      );
    }).toList();

    salesList.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return salesList.take(10).toList();
  }

  static List<CustomerPaymentBehavior> _analyzeCustomerBehavior(
      List<Invoice> invoices) {
    final Map<String, List<Invoice>> invoicesByClient = {};

    for (var invoice in invoices) {
      invoicesByClient.putIfAbsent(invoice.clientName, () => []).add(invoice);
    }

    final behaviors = <CustomerPaymentBehavior>[];

    for (var entry in invoicesByClient.entries) {
      final clientInvoices = entry.value;
      final totalInvoices = clientInvoices.length;

      int paidOnTime = 0;
      int paidLate = 0;
      int pending = 0;
      double totalDelay = 0;
      int delayCount = 0;

      for (var invoice in clientInvoices) {
        if (invoice.status == InvoiceStatus.paid) {
          // Assume paid on time if before due date (simplified)
          paidOnTime++;
        } else if (invoice.status == InvoiceStatus.sent) {
          if (invoice.dueDate.isBefore(DateTime.now())) {
            final delay = DateTime.now().difference(invoice.dueDate).inDays;
            totalDelay += delay;
            delayCount++;
            paidLate++;
          } else {
            pending++;
          }
        } else {
          pending++;
        }
      }

      final averageDelay =
          delayCount > 0 ? totalDelay / delayCount.toDouble() : 0.0;

      // Calculate credit score (0-100)
      double creditScore = 100;
      creditScore -=
          (paidLate / totalInvoices.toDouble()) * 30; // -30 for late payments
      creditScore -=
          (pending / totalInvoices.toDouble()) * 20; // -20 for pending
      creditScore -= (averageDelay * 2); // -2 per day of average delay
      creditScore = creditScore.clamp(0, 100);

      PaymentReliability reliability;
      if (creditScore >= 80) {
        reliability = PaymentReliability.excellent;
      } else if (creditScore >= 60) {
        reliability = PaymentReliability.good;
      } else if (creditScore >= 40) {
        reliability = PaymentReliability.average;
      } else {
        reliability = PaymentReliability.poor;
      }

      behaviors.add(CustomerPaymentBehavior(
        clientName: entry.key,
        totalInvoices: totalInvoices,
        paidOnTime: paidOnTime,
        paidLate: paidLate,
        pending: pending,
        averagePaymentDelay: averageDelay,
        creditScore: creditScore,
        reliability: reliability,
      ));
    }

    behaviors.sort((a, b) => b.creditScore.compareTo(a.creditScore));
    return behaviors;
  }

  static CashFlowForecast _generateCashFlowForecast(List<Invoice> invoices) {
    final now = DateTime.now();
    final thirtyDays = now.add(const Duration(days: 30));
    final sixtyDays = now.add(const Duration(days: 60));
    final ninetyDays = now.add(const Duration(days: 90));

    double expected30 = 0;
    double expected60 = 0;
    double expected90 = 0;
    double overdue = 0;

    for (var invoice in invoices) {
      if (invoice.status != InvoiceStatus.paid) {
        if (invoice.dueDate.isBefore(now)) {
          overdue += invoice.total;
        } else if (invoice.dueDate.isBefore(thirtyDays)) {
          expected30 += invoice.total;
        } else if (invoice.dueDate.isBefore(sixtyDays)) {
          expected60 += invoice.total;
        } else if (invoice.dueDate.isBefore(ninetyDays)) {
          expected90 += invoice.total;
        }
      }
    }

    // Generate forecast data points (simplified AI prediction)
    final forecastData = <ForecastDataPoint>[];
    for (var i = 0; i < 90; i += 7) {
      final date = now.add(Duration(days: i));
      final expectedAmount = _predictExpectedAmount(invoices, date);
      final confidence = 1.0 - (i / 90) * 0.3; // Confidence decreases over time

      forecastData.add(ForecastDataPoint(
        date: date,
        expectedAmount: expectedAmount,
        confidence: confidence,
      ));
    }

    return CashFlowForecast(
      expectedIncome30Days: expected30,
      expectedIncome60Days: expected60,
      expectedIncome90Days: expected90,
      overdueAmount: overdue,
      forecastData: forecastData,
    );
  }

  static double _predictExpectedAmount(List<Invoice> invoices, DateTime date) {
    // Simple prediction based on historical average
    final historicalInvoices = invoices.where((inv) => inv.date.isBefore(date));
    if (historicalInvoices.isEmpty) return 0;

    final avgDaily =
        historicalInvoices.fold<double>(0, (sum, inv) => sum + inv.total) /
            historicalInvoices.length;

    return avgDaily * 7; // Weekly prediction
  }
}
