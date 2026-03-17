import 'dart:typed_data';
import 'package:flutter/material.dart' show DateTimeRange;

import '../models/app_settings.dart';
import '../../features/invoices/data/models/invoice_model.dart';
import '../../features/invoices/data/models/invoice_template.dart';
import '../../features/clients/data/models/client_model.dart';
import '../../features/reports/domain/models/report_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'templates/template_manager.dart';

class PdfService {
  Future<Uint8List> generateClientLedger({
    required Client client,
    required List<Invoice> invoices,
    required AppSettings settings,
    DateTimeRange? dateRange,
  }) async {
    final pdf = pw.Document();

    // Calculate Totals
    double totalBilled = 0;
    double totalPaid = 0;
    double balanceDue = 0;

    for (var invoice in invoices) {
      if (invoice.status == InvoiceStatus.draft) continue;
      totalBilled += invoice.total;
      if (invoice.status == InvoiceStatus.paid) {
        totalPaid += invoice.total;
      } else {
        balanceDue += invoice.total;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      settings.companyName,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18),
                    ),
                    pw.Text(settings.companyAddress),
                    pw.Text(settings.companyEmail),
                    if (settings.companyPhone.isNotEmpty)
                      pw.Text(settings.companyPhone),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'CLIENT LEDGER',
                      style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}'),
                    if (dateRange != null)
                      pw.Text(
                          'Period: ${DateFormat('dd/MM/yy').format(dateRange.start)} - ${DateFormat('dd/MM/yy').format(dateRange.end)}'),
                  ],
                ),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Client Info & Summary
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client Details',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700)),
                      pw.SizedBox(height: 5),
                      pw.Text(client.name,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text(client.address),
                      pw.Text(client.email),
                      pw.Text(client.phone),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Billed:'),
                            pw.Text(
                                '${settings.currency} ${totalBilled.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Paid:'),
                            pw.Text(
                                '${settings.currency} ${totalPaid.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green)),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Balance Due:'),
                            pw.Text(
                                '${settings.currency} ${balanceDue.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.red)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Transactions Table
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Invoice #', 'Status', 'Amount'],
              data: invoices.map((inv) {
                return [
                  DateFormat('dd MMM yyyy').format(inv.date),
                  inv.invoiceNumber,
                  inv.status.name.toUpperCase(),
                  '${settings.currency} ${inv.total.toStringAsFixed(2)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey),
              rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300))),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Center(
                child: pw.Text('Report Generated by GenXBill',
                    style: const pw.TextStyle(
                        color: PdfColors.grey, fontSize: 10))),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateInvoice({
    required Invoice invoice,
    required AppSettings settings,
    InvoiceTemplate? template,
  }) async {
    // Use template manager to route to the appropriate template design
    return await TemplateManager.generateInvoicePDF(
      invoice: invoice,
      settings: settings,
      templateType: template,
    );
  }

  Future<Uint8List> generateFinancialReport(
    ReportData data,
    AppSettings settings,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Financial Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    data.periodName,
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Summary Cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildSummaryCard(
                    'Revenue',
                    '${settings.currency} ${data.revenue.toStringAsFixed(2)}',
                    PdfColors.green,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildSummaryCard(
                    'Expenses',
                    '${settings.currency} ${data.expenses.toStringAsFixed(2)}',
                    PdfColors.red,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildSummaryCard(
                    'Net Profit',
                    '${settings.currency} ${data.netProfit.toStringAsFixed(2)}',
                    data.netProfit >= 0 ? PdfColors.blue : PdfColors.red,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Key Metrics
            pw.Text(
              'Key Metrics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [
                  _buildMetricRow('Profit Margin',
                      '${data.profitMargin.toStringAsFixed(1)}%'),
                  pw.SizedBox(height: 8),
                  _buildMetricRow('Average Invoice Value',
                      '${settings.currency} ${data.averageInvoiceValue.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 8),
                  _buildMetricRow(
                      'Total Transactions', '${data.transactionCount}'),
                  pw.SizedBox(height: 8),
                  _buildMetricRow('New Customers', '${data.newCustomers}'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Top Products
            if (data.topProducts.isNotEmpty) ...[
              pw.Text(
                'Top Products',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Product', 'Quantity Sold'],
                data: data.topProducts.entries
                    .take(5)
                    .map((e) => [e.key, e.value.toStringAsFixed(0)])
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blue700),
              ),
              pw.SizedBox(height: 20),
            ],

            // Top Customers
            if (data.topCustomers.isNotEmpty) ...[
              pw.Text(
                'Top Customers',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Customer', 'Revenue'],
                data: data.topCustomers.entries
                    .take(5)
                    .map((e) => [
                          e.key,
                          '${settings.currency} ${e.value.toStringAsFixed(2)}'
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blue700),
              ),
              pw.SizedBox(height: 20),
            ],

            // Expenses by Category
            if (data.expensesByCategory.isNotEmpty) ...[
              pw.Text(
                'Expenses by Category',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Category', 'Amount'],
                data: data.expensesByCategory.entries
                    .map((e) => [
                          e.key,
                          '${settings.currency} ${e.value.toStringAsFixed(2)}'
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blue700),
              ),
            ],

            // Footer
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                'Report Generated by ${settings.companyName}',
                style: const pw.TextStyle(
                  color: PdfColors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryCard(
      String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetricRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
