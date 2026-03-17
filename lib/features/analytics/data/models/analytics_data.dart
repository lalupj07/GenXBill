import 'package:flutter/material.dart';

/// Analytics data model for business insights
class AnalyticsData {
  final double totalRevenue;
  final double totalProfit;
  final double profitMargin;
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final int overdueInvoices;
  final double averageInvoiceValue;
  final List<RevenueDataPoint> revenueHistory;
  final List<ProductSalesData> topProducts;
  final List<CustomerPaymentBehavior> customerBehavior;
  final CashFlowForecast cashFlowForecast;

  AnalyticsData({
    required this.totalRevenue,
    required this.totalProfit,
    required this.profitMargin,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.averageInvoiceValue,
    required this.revenueHistory,
    required this.topProducts,
    required this.customerBehavior,
    required this.cashFlowForecast,
  });
}

/// Revenue data point for trend charts
class RevenueDataPoint {
  final DateTime date;
  final double revenue;
  final double profit;
  final int invoiceCount;

  RevenueDataPoint({
    required this.date,
    required this.revenue,
    required this.profit,
    required this.invoiceCount,
  });
}

/// Product sales analytics
class ProductSalesData {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;
  final double totalProfit;
  final double profitMargin;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.profitMargin,
  });
}

/// Customer payment behavior analysis
class CustomerPaymentBehavior {
  final String clientName;
  final int totalInvoices;
  final int paidOnTime;
  final int paidLate;
  final int pending;
  final double averagePaymentDelay; // in days
  final double creditScore; // 0-100
  final PaymentReliability reliability;

  CustomerPaymentBehavior({
    required this.clientName,
    required this.totalInvoices,
    required this.paidOnTime,
    required this.paidLate,
    required this.pending,
    required this.averagePaymentDelay,
    required this.creditScore,
    required this.reliability,
  });

  Color get reliabilityColor {
    switch (reliability) {
      case PaymentReliability.excellent:
        return Colors.green;
      case PaymentReliability.good:
        return Colors.lightGreen;
      case PaymentReliability.average:
        return Colors.orange;
      case PaymentReliability.poor:
        return Colors.red;
    }
  }
}

enum PaymentReliability { excellent, good, average, poor }

/// Cash flow forecast
class CashFlowForecast {
  final double expectedIncome30Days;
  final double expectedIncome60Days;
  final double expectedIncome90Days;
  final double overdueAmount;
  final List<ForecastDataPoint> forecastData;

  CashFlowForecast({
    required this.expectedIncome30Days,
    required this.expectedIncome60Days,
    required this.expectedIncome90Days,
    required this.overdueAmount,
    required this.forecastData,
  });
}

class ForecastDataPoint {
  final DateTime date;
  final double expectedAmount;
  final double confidence; // 0-1

  ForecastDataPoint({
    required this.date,
    required this.expectedAmount,
    required this.confidence,
  });
}
