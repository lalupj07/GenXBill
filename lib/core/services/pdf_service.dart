import 'dart:typed_data';
import 'dart:io';

import '../models/app_settings.dart';
import '../../features/invoices/data/models/invoice_model.dart';
import '../../features/invoices/data/models/invoice_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../features/reports/domain/models/report_data.dart';

class PdfService {
  Future<Uint8List> generateInvoice({
    required Invoice invoice,
    required AppSettings settings,
    InvoiceTemplate? template,
  }) async {
    final pdf = pw.Document();
    final selectedTemplate = template ?? settings.defaultTemplate;
    final theme = _getThemeForTemplate(selectedTemplate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (pw.Context context) {
          switch (selectedTemplate) {
            case InvoiceTemplate.modern:
              return _buildModernTemplate(invoice, settings);
            case InvoiceTemplate.classic:
              return _buildClassicTemplate(invoice, settings);
            case InvoiceTemplate.minimal:
              return _buildMinimalTemplate(invoice, settings);
            case InvoiceTemplate.bold:
              return _buildBoldTemplate(invoice, settings);
            case InvoiceTemplate.gst:
              return _buildGstTemplate(invoice, settings);
            case InvoiceTemplate.creative:
              return _buildCreativeTemplate(invoice, settings);
          }
        },
      ),
    );

    return pdf.save();
  }

  pw.ThemeData _getThemeForTemplate(InvoiceTemplate template) {
    switch (template) {
      case InvoiceTemplate.modern:
        return pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        );
      case InvoiceTemplate.classic:
        return pw.ThemeData.withFont(
          base: pw.Font.times(),
          bold: pw.Font.timesBold(),
        );
      case InvoiceTemplate.minimal:
        return pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        );
      case InvoiceTemplate.bold:
        return pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        );
      case InvoiceTemplate.gst:
        return pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        );
      case InvoiceTemplate.creative:
        return pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        );
    }
  }

  // MODERN TEMPLATE
  pw.Widget _buildModernTemplate(Invoice invoice, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 20),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    settings.companyName,
                    style: pw.TextStyle(
                      color: PdfColors.blue800,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  if (settings.companyLogo != null &&
                      settings.companyLogo!.isNotEmpty)
                    pw.Text(
                      "Logo: ${settings.companyLogo}",
                    ), // Placeholder for actual image rendering
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
                    'INVOICE',
                    style: const pw.TextStyle(
                      fontSize: 30,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '#${invoice.invoiceNumber}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text('Date: ${DateFormat.yMMMd().format(invoice.date)}'),
                  pw.Text(
                    'Due Date: ${DateFormat.yMMMd().format(invoice.dueDate)}',
                  ),
                  if (invoice.poNumber.isNotEmpty)
                    pw.Text('PO No: ${invoice.poNumber}'),
                  if (invoice.transportMode.isNotEmpty)
                    pw.Text('Transport: ${invoice.transportMode}'),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),

        // Bill To
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    invoice.clientName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 30),

        // Items Table
        pw.TableHelper.fromTextArray(
          border: null,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          headerHeight: 30,
          cellHeight: 30,
          headerStyle: pw.TextStyle(
            color: PdfColors.blue800,
            fontWeight: pw.FontWeight.bold,
          ),
          headers: ['Description', 'HSN', 'Qty', 'Unit', 'Price', 'Total'],
          data: invoice.items.map((item) {
            return [
              item.description,
              item.hsnCode,
              item.quantity.toString(),
              item.unit,
              '${settings.currency} ${item.unitPrice.toStringAsFixed(2)}',
              '${settings.currency} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
            ];
          }).toList(),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
          },
        ),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 20),

        // Total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Subtotal:  ',
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                    pw.Text(
                      '${settings.currency} ${invoice.subtotal.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Tax (${(settings.taxRate * 100).toInt()}%):  ',
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                    pw.Text(
                      '${settings.currency} ${invoice.tax.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total:  ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      '${settings.currency} ${invoice.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Footer / Notes
        if (invoice.notes.isNotEmpty) ...[
          pw.SizedBox(height: 40),
          pw.Text(
            'Notes:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(invoice.notes),
        ],
        pw.Spacer(),
        pw.Divider(color: PdfColors.grey300),
        pw.Center(
          child: pw.Text(
            'Thank you for your business!',
            style: const pw.TextStyle(color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  // CLASSIC TEMPLATE
  pw.Widget _buildClassicTemplate(Invoice invoice, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'INVOICE',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  settings.companyName,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(settings.companyAddress),
                pw.Text(settings.companyEmail),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                pw.Text('Date: ${DateFormat.yMMMd().format(invoice.date)}'),
              ],
            ),
          ],
        ),
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Text(
          'Bill To:',
          style: const pw.TextStyle(decoration: pw.TextDecoration.underline),
        ),
        pw.Text(
          invoice.clientName,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 30),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headers: ['Description', 'Quantity', 'Price', 'Total'],
          data: invoice.items.map((item) {
            return [
              item.description,
              item.quantity.toString(),
              '${settings.currency} ${item.unitPrice.toStringAsFixed(2)}',
              '${settings.currency} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Subtotal: ${settings.currency} ${invoice.subtotal.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Tax: ${settings.currency} ${invoice.tax.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Total: ${settings.currency} ${invoice.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        if (invoice.notes.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Text('Notes: ${invoice.notes}'),
        ],
      ],
    );
  }

  // MINIMAL TEMPLATE
  pw.Widget _buildMinimalTemplate(Invoice invoice, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          settings.companyName,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('INVOICE #${invoice.invoiceNumber}'),
            pw.Text(DateFormat.yMMMd().format(invoice.date)),
          ],
        ),
        pw.SizedBox(height: 40),
        pw.Text(invoice.clientName, style: const pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 40),
        pw.Table(
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text('Item'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text('Cost', textAlign: pw.TextAlign.right),
                ),
              ],
            ),
            ...invoice.items.map((item) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Text('${item.description} x${item.quantity}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Text(
                      '${settings.currency} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Total: ${settings.currency} ${invoice.total.toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Text(
          settings.companyEmail,
          style: const pw.TextStyle(color: PdfColors.grey),
        ),
      ],
    );
  }

  // BOLD TEMPLATE
  pw.Widget _buildBoldTemplate(Invoice invoice, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.black,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                settings.companyName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'INVOICE',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 24),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO',
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        invoice.clientName,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE NO.',
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'DATE',
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        DateFormat.yMMMd().format(invoice.date),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.TableHelper.fromTextArray(
                border: null,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                headerHeight: 30,
                cellHeight: 30,
                headers: ['DESCRIPTION', 'QTY', 'PRICE', 'TOTAL'],
                data: invoice.items.map((item) {
                  return [
                    item.description,
                    item.quantity.toString(),
                    '${settings.currency} ${item.unitPrice.toStringAsFixed(2)}',
                    '${settings.currency} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  ];
                }).toList(),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  pw.Text(
                    '${settings.currency} ${invoice.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // FINANCIAL REPORT
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
            _buildReportHeader(data, settings),
            pw.SizedBox(height: 20),
            _buildReportSummary(data, settings),
            pw.SizedBox(height: 20),
            _buildDetailedBreakdown(data, settings),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildReportHeader(ReportData data, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              settings.companyName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20),
            ),
            pw.Text(
              'FINANCIAL REPORT',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 20),
            ),
          ],
        ),
        pw.Divider(),
        pw.Text(
          'Period: ${data.periodName}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.Text('Generated On: ${DateFormat.yMMMd().format(DateTime.now())}'),
      ],
    );
  }

  pw.Widget _buildReportSummary(ReportData data, AppSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Revenue',
            data.revenue,
            settings,
            PdfColors.green,
          ),
          _buildSummaryItem(
            'Total Expenses',
            data.expenses,
            settings,
            PdfColors.red,
          ),
          _buildSummaryItem(
            'Net Profit',
            data.netProfit,
            settings,
            data.netProfit >= 0 ? PdfColors.blue : PdfColors.orange,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(
    String label,
    double amount,
    AppSettings settings,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          '${settings.currency} ${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildDetailedBreakdown(ReportData data, AppSettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Income & Expenses Breakdown',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Type', 'Count', 'Amount'],
          data: [
            [
              'Invoices (Income)',
              data.invoices.length.toString(),
              '${settings.currency} ${data.revenue.toStringAsFixed(2)}',
            ],
            [
              'Expenses',
              data.expenseList.length.toString(),
              '${settings.currency} ${data.expenses.toStringAsFixed(2)}',
            ],
            [
              'Net Result',
              '-',
              '${settings.currency} ${data.netProfit.toStringAsFixed(2)}',
            ],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
          },
        ),
        if (data.invoices.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Text(
            'Recent Invoices (Top 10)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 10),
          _buildInvoiceTable(data.invoices.take(10).toList(), settings),
        ],
      ],
    );
  }

  pw.Widget _buildInvoiceTable(List<Invoice> invoices, AppSettings settings) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Client', 'Amount'],
      data: invoices
          .map(
            (i) => [
              DateFormat('MM/dd').format(i.date),
              i.clientName,
              '${settings.currency} ${i.total.toStringAsFixed(2)}',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  // GST TEMPLATE
  pw.Widget _buildGstTemplate(Invoice invoice, AppSettings settings) {
    // Styles
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    );
    const contentStyle = pw.TextStyle(fontSize: 9);
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.red,
    );
    const blueAddressStyle = pw.TextStyle(
      fontSize: 9,
      color: PdfColors.blue900,
    );

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        children: [
          // 1. Header (Logo, Name, Address)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              children: [
                // Logo Area (20%)
                if (settings.companyLogo != null &&
                    settings.companyLogo!.isNotEmpty)
                  if (File(settings.companyLogo!).existsSync())
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(
                        pw.MemoryImage(
                          File(settings.companyLogo!).readAsBytesSync(),
                        ),
                      ),
                    )
                  else
                    pw.Container(
                      width: 60,
                      height: 60,
                      decoration: const pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.grey200,
                      ),
                      child: pw.Center(child: pw.Text("Logo")),
                    ),
                pw.SizedBox(width: 10),

                // Company Details (Centered/Expanded)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "GSTIN : ${settings.taxId ?? ''}",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Tax Invoice / Bill of Supply",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        settings.companyName.toUpperCase(),
                        style: titleStyle,
                      ),
                      pw.Text(
                        settings.companyAddress,
                        style: blueAddressStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "Email: ${settings.companyEmail}  Ph: ${settings.companyPhone}",
                        style: blueAddressStyle,
                      ),
                    ],
                  ),
                ),

                // Top Right (Original for Recipient)
                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    "Original for Recipient",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          ),

          pw.Divider(height: 1, thickness: 1),

          // 2. Invoice Details Row
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide()),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text("INVOICE NO. : ", style: headerStyle),
                      pw.Text(invoice.invoiceNumber, style: contentStyle),
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Row(
                    children: [
                      pw.Text("DATE : ", style: headerStyle),
                      pw.Text(
                        DateFormat('dd-MMM-yy').format(invoice.date),
                        style: contentStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(height: 1, thickness: 1),

          // 3. Party Details (Two Cols)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Billed To
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide()),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Party Details:", style: headerStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Name : ${invoice.clientName}",
                        style: contentStyle,
                      ),
                      pw.Text(
                        "Address: ${invoice.shippingAddress}",
                        style: contentStyle,
                      ), // Using shipping as placeholder if Billed Address not separated in Invoice model strictly
                      pw.SizedBox(height: 5),
                      pw.Text("GSTIN : ${invoice.gstin}", style: headerStyle),
                    ],
                  ),
                ),
              ),
              // Shipped To (Same or Different)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Shipping : Detailed Address",
                        style: headerStyle,
                      ),
                      pw.Text(invoice.shippingAddress, style: contentStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Mode of Transport: ${invoice.transportMode}",
                        style: contentStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(height: 1, thickness: 1),

          // 4. Order Details
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    "Order No. : ${invoice.poNumber}",
                    style: contentStyle,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    "Order Dated : ${invoice.poDate != null ? DateFormat('dd-MMM-yy').format(invoice.poDate!) : ''}",
                    style: contentStyle,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(height: 1, thickness: 1),

          // 5. Item Table
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: const pw.BorderSide(width: 0.5),
              outside: const pw.BorderSide(width: 0),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(30), // S No
              1: const pw.FlexColumnWidth(4), // Item
              2: const pw.FixedColumnWidth(60), // HSN
              3: const pw.FixedColumnWidth(40), // Qty
              4: const pw.FixedColumnWidth(40), // Unit
              5: const pw.FixedColumnWidth(60), // Rate
              6: const pw.FixedColumnWidth(70), // Amount
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                children: [
                  'S. No.',
                  'Item Description',
                  'HSN/SAC',
                  'Qty',
                  'Unit',
                  'Rate',
                  'Amount',
                ]
                    .map(
                      (e) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          e,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              // Items
              ...invoice.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    (i + 1).toString(),
                    item.description,
                    item.hsnCode,
                    item.quantity.toString(),
                    item.unit,
                    item.unitPrice.toStringAsFixed(2),
                    (item.quantity * item.unitPrice).toStringAsFixed(2),
                  ]
                      .map(
                        (e) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(e, style: contentStyle),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),

          // Fill empty space if needed? No, just Divider.
          pw.Divider(height: 1, thickness: 1),

          // 6. Footer (Total, Words, Tax)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left Side (Words & Bank)
              pw.Expanded(
                flex: 6,
                child: pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(),
                          right: pw.BorderSide(),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Total Invoice Value (in words)",
                            style: headerStyle,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            "${invoice.total.toStringAsFixed(2)} Only",
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ), // Placeholder for NumberToWords
                        ],
                      ),
                    ),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(5),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide()),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Bank Details:", style: headerStyle),
                          pw.Text(
                            "Bank Name : ${settings.bankName ?? ''}",
                            style: contentStyle,
                          ),
                          pw.Text(
                            "A/C No. : ${settings.bankAccountNumber ?? ''}",
                            style: contentStyle,
                          ),
                          pw.Text(
                            "IFSC Code : ${settings.bankRoutingNumber ?? ''}",
                            style: contentStyle,
                          ), // Assuming Routing = IFSC for India
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Side (Totals)
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  children: [
                    _buildFooterRow(
                      "Total :",
                      invoice.subtotal.toStringAsFixed(2),
                    ),
                    _buildFooterRow(
                      "Packaging:",
                      invoice.courierCharges.toStringAsFixed(2),
                    ),
                    _buildFooterRow(
                      "Taxable Value:",
                      invoice.subtotal.toStringAsFixed(2),
                    ),
                    if (!invoice.isInterstate) ...[
                      _buildFooterRow(
                        "CGST (9%):",
                        (invoice.tax / 2).toStringAsFixed(2),
                      ),
                      _buildFooterRow(
                        "SGST (9%):",
                        (invoice.tax / 2).toStringAsFixed(2),
                      ),
                    ] else ...[
                      _buildFooterRow(
                        "IGST (18%):",
                        invoice.tax.toStringAsFixed(2),
                      ),
                    ],
                    pw.Divider(height: 1),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      color: PdfColors.grey200,
                      child: _buildFooterRow(
                        "GRAND TOTAL :",
                        invoice.total.toStringAsFixed(2),
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.Divider(height: 1, thickness: 1),

          // 7. Terms & Signatures
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Terms & Conditions:", style: headerStyle),
                    pw.Text(
                      "1. Goods once sold will not be taken back.",
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                    pw.Text(
                      "2. Interest @ 18% p.a. will be charged if payment is not made within due date.",
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                    pw.Text(
                      "3. Subject to jurisdiction.",
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      "For ${settings.companyName.toUpperCase()}",
                      style: headerStyle,
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text("Authorised Signatory", style: headerStyle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooterRow(String label, String value, {bool isBold = false}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  // CREATIVE TEMPLATE
  pw.Widget _buildCreativeTemplate(Invoice invoice, AppSettings settings) {
    const primaryColor = PdfColors.purple;
    const secondaryColor = PdfColors.purple100;

    return pw.Column(
      children: [
        // Fancy Header
        pw.Container(
          height: 100,
          decoration: const pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(30),
              bottomRight: pw.Radius.circular(30),
            ),
          ),
          padding: const pw.EdgeInsets.all(20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    settings.companyName,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    settings.companyAddress,
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10),
                  ),
                  pw.Text(
                    settings.companyEmail,
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.Text(
                    '#${invoice.invoiceNumber}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 30),

        // Info Row
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      color: PdfColors.grey500,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    invoice.clientName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  // Address could go here if available in Invoice model
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(children: [
                    pw.Text('Date: ',
                        style: const pw.TextStyle(color: PdfColors.grey500)),
                    pw.Text(DateFormat.yMMMd().format(invoice.date)),
                  ]),
                  pw.SizedBox(height: 5),
                  pw.Row(children: [
                    pw.Text('Due Date: ',
                        style: const pw.TextStyle(color: PdfColors.grey500)),
                    pw.Text(DateFormat.yMMMd().format(invoice.dueDate)),
                  ]),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 30),

        // Items Table with Custom Decoration
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.TableHelper.fromTextArray(
            headers: ['Description', 'Qty', 'Unit Price', 'Total'],
            data: invoice.items.map((item) {
              return [
                item.description,
                item.quantity.toString(),
                '${settings.currency} ${item.unitPrice.toStringAsFixed(2)}',
                '${settings.currency} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
              ];
            }).toList(),
            headerDecoration: const pw.BoxDecoration(
              color: secondaryColor,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            headerStyle: pw.TextStyle(
              color: primaryColor,
              fontWeight: pw.FontWeight.bold,
            ),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
            ),
            cellPadding: const pw.EdgeInsets.all(10),
          ),
        ),

        pw.SizedBox(height: 20),

        // Total
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 20),
          padding: const pw.EdgeInsets.all(15),
          decoration: const pw.BoxDecoration(
            color: secondaryColor,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(15)),
          ),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL AMOUNT',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${settings.currency} ${invoice.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ]),
        ),

        if (invoice.notes.isNotEmpty) ...[
          pw.SizedBox(height: 30),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Notes & Terms',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: primaryColor)),
                pw.SizedBox(height: 5),
                pw.Text(invoice.notes,
                    style: const pw.TextStyle(
                        color: PdfColors.grey600, fontSize: 10)),
              ],
            ),
          ),
        ],

        pw.Spacer(),
        pw.Container(
          width: double.infinity,
          height: 10,
          color: primaryColor,
        ),
      ],
    );
  }
}
