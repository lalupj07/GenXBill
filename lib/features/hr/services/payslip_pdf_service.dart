import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:genx_bill/features/hr/data/models/payslip_model.dart';
import 'package:genx_bill/core/models/app_settings.dart';

class PayslipPdfService {
  /// Generate a professional payslip PDF
  Future<Uint8List> generatePayslipPdf({
    required Payslip payslip,
    required AppSettings settings,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return _buildPayslipContent(payslip, settings);
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPayslipContent(Payslip payslip, AppSettings settings) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final monthYear =
        DateFormat('MMMM yyyy').format(DateTime(payslip.year, payslip.month));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(settings, monthYear),
        pw.SizedBox(height: 30),

        // Employee Info
        _buildEmployeeInfo(payslip),
        pw.SizedBox(height: 20),

        // Attendance Summary
        _buildAttendanceSummary(payslip),
        pw.SizedBox(height: 20),

        // Earnings and Deductions Table
        _buildEarningsDeductionsTable(payslip, currencyFormat),
        pw.SizedBox(height: 30),

        // Net Salary
        _buildNetSalary(payslip, currencyFormat),
        pw.SizedBox(height: 30),

        // Footer
        _buildFooter(payslip),
      ],
    );
  }

  pw.Widget _buildHeader(AppSettings settings, String monthYear) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            settings.companyName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'PAYSLIP FOR $monthYear',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          if (settings.companyAddress.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              settings.companyAddress,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildEmployeeInfo(Payslip payslip) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Employee Name:', payslip.employeeName),
              pw.SizedBox(height: 8),
              _buildInfoRow('Employee ID:', payslip.employeeId),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Month/Year:', '${payslip.month}/${payslip.year}'),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  'Payment Date:',
                  payslip.paymentDate != null
                      ? DateFormat('dd MMM yyyy').format(payslip.paymentDate!)
                      : 'Pending'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 8),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildAttendanceSummary(Payslip payslip) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Days', payslip.totalDaysInMonth.toString()),
          _buildSummaryItem(
              'Present Days', payslip.presentDays.toStringAsFixed(1)),
          _buildSummaryItem('Leave Days', payslip.leaveDays.toStringAsFixed(1)),
          _buildSummaryItem(
              'Payable Days', payslip.payableDays.toStringAsFixed(1)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildEarningsDeductionsTable(
      Payslip payslip, NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          children: [
            _buildTableHeader('EARNINGS'),
            _buildTableHeader('AMOUNT'),
            _buildTableHeader('DEDUCTIONS'),
            _buildTableHeader('AMOUNT'),
          ],
        ),
        // Basic Salary Row
        pw.TableRow(
          children: [
            _buildTableCell('Basic Salary'),
            _buildTableCell(currencyFormat.format(payslip.basicSalary),
                align: pw.TextAlign.right),
            _buildTableCell('PF Deduction'),
            _buildTableCell(currencyFormat.format(payslip.pfDeduction),
                align: pw.TextAlign.right),
          ],
        ),
        // Gross Earnings Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Gross Earnings (Pro-rated)'),
            _buildTableCell(currencyFormat.format(payslip.grossEarnings),
                align: pw.TextAlign.right),
            _buildTableCell('ESI Deduction'),
            _buildTableCell(currencyFormat.format(payslip.esiDeduction),
                align: pw.TextAlign.right),
          ],
        ),
        // Empty row for alignment
        pw.TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell('TDS Deduction'),
            _buildTableCell(currencyFormat.format(payslip.tdsDeduction),
                align: pw.TextAlign.right),
          ],
        ),
        // Professional Tax Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell('Professional Tax'),
            _buildTableCell(currencyFormat.format(payslip.professionalTax),
                align: pw.TextAlign.right),
          ],
        ),
        // Total Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: [
            _buildTableCell('TOTAL EARNINGS', bold: true),
            _buildTableCell(currencyFormat.format(payslip.grossEarnings),
                bold: true, align: pw.TextAlign.right),
            _buildTableCell('TOTAL DEDUCTIONS', bold: true),
            _buildTableCell(currencyFormat.format(payslip.totalDeductions),
                bold: true, align: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildNetSalary(Payslip payslip, NumberFormat currencyFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green700, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'NET SALARY PAYABLE',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.Text(
            currencyFormat.format(payslip.netSalary),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(Payslip payslip) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Text(
          'This is a computer-generated payslip and does not require a signature.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(payslip.generatedDate)}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        if (payslip.status == PayslipStatus.paid) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            'Status: PAID',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
        ],
      ],
    );
  }
}
