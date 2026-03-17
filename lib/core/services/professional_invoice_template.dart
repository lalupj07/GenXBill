import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../../features/invoices/data/models/invoice_model.dart';

/// Professional GST Invoice Template - Exact match to reference format
/// Complete A4 format with all details: Logo, GSTIN, Party/Shipping Details,
/// HSN/SAC Codes, Tax Breakdown, Bank Details, Terms & Conditions, Signature
class ProfessionalInvoiceTemplate {
  static Future<pw.Widget> buildInvoice(
      Invoice invoice, AppSettings settings) async {
    // Load images if available
    pw.MemoryImage? logoImage;
    pw.MemoryImage? signatureImage;
    pw.MemoryImage? stampImage;

    try {
      if (settings.companyLogo != null && settings.companyLogo!.isNotEmpty) {
        final logoFile = File(settings.companyLogo!);
        if (await logoFile.exists()) {
          logoImage = pw.MemoryImage(await logoFile.readAsBytes());
        }
      }

      if (settings.companySignature != null &&
          settings.companySignature!.isNotEmpty) {
        final signatureFile = File(settings.companySignature!);
        if (await signatureFile.exists()) {
          signatureImage = pw.MemoryImage(await signatureFile.readAsBytes());
        }
      }

      if (settings.companyStamp != null && settings.companyStamp!.isNotEmpty) {
        final stampFile = File(settings.companyStamp!);
        if (await stampFile.exists()) {
          stampImage = pw.MemoryImage(await stampFile.readAsBytes());
        }
      }
    } catch (e) {
      // Ignore image loading errors
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Top: GSTIN and Original Label
          _buildTopBar(settings, invoice),

          // Header with Logo and Company Details
          _buildCompanyHeader(settings, logoImage),

          // Invoice Title
          _buildInvoiceTitle(),

          // Invoice Number and Date Row
          _buildInvoiceNumberRow(invoice),

          // Party Details and Shipping (Side by Side)
          _buildPartyAndShipping(invoice),

          // Order Details Row
          _buildOrderDetailsRow(invoice),

          // Items Table
          _buildItemsTable(invoice, settings),

          // Total in Words and Tax Summary
          _buildTotalsSection(invoice, settings),

          // Bank Details Section
          _buildBankDetails(settings),

          // Customer Notes
          _buildCustomerNotes(invoice),

          // Terms & Conditions
          _buildTermsAndConditions(settings),

          // Signature Section
          _buildSignatureSection(settings, signatureImage, stampImage),
        ],
      ),
    );
  }

  static pw.Widget _buildTopBar(AppSettings settings, Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GSTIN : ${settings.taxId ?? 'N/A'}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Original for Recipient',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompanyHeader(
      AppSettings settings, pw.MemoryImage? logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo
          if (logoImage != null)
            pw.Container(
              width: 70,
              height: 70,
              margin: const pw.EdgeInsets.only(right: 12),
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 70,
              height: 70,
              margin: const pw.EdgeInsets.only(right: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Center(
                child: pw.Text(
                  'LOGO',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Company Details
          pw.Expanded(
            child: pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    settings.companyName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900,
                      letterSpacing: 1,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 3),
                  if (settings.companyAddress.isNotEmpty)
                    pw.Container(
                      width: double.infinity,
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'ADDRESS : ${settings.companyAddress}',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                  pw.SizedBox(height: 2),
                  pw.Container(
                    width: double.infinity,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'E-Mail : ${settings.companyEmail}   M: ${settings.companyPhone}',
                      style: const pw.TextStyle(fontSize: 7),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceTitle() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Center(
        child: pw.Text(
          'Tax Invoice / Bill of Supply',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildInvoiceNumberRow(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'INVOICE NO. : ${invoice.invoiceNumber}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'DATE : ${DateFormat('dd-MMM-yy').format(invoice.date)}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartyAndShipping(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Party Details
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 1),
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Party Details:',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Name : ${invoice.clientName}',
                  style: const pw.TextStyle(fontSize: 7),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
                if (invoice.clientAddress.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 1),
                    child: pw.Text(
                      'Address: ${invoice.clientAddress}',
                      style: const pw.TextStyle(fontSize: 6),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                pw.SizedBox(height: 2),
                if (invoice.clientGstin.isNotEmpty ||
                    invoice.clientStateCode.isNotEmpty)
                  pw.Text(
                    '${invoice.clientGstin.isNotEmpty ? 'GSTIN: ${invoice.clientGstin}' : ''}${invoice.clientStateCode.isNotEmpty ? '  State Code: ${invoice.clientStateCode}' : ''}',
                    style: const pw.TextStyle(fontSize: 6),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ),

        // Shipping Details
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Shipping : ${invoice.shippingAddress.isNotEmpty ? invoice.shippingAddress : invoice.clientName}',
                  style:
                      pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
                pw.SizedBox(height: 2),
                if (invoice.destination.isNotEmpty)
                  pw.Text(
                    invoice.destination,
                    style: const pw.TextStyle(fontSize: 6),
                    maxLines: 2,
                    overflow: pw.TextOverflow.clip,
                  ),
                if (invoice.transportMode.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 1),
                    child: pw.Text(
                      'Mode of Transport : ${invoice.transportMode}',
                      style: const pw.TextStyle(fontSize: 6),
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildOrderDetailsRow(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (invoice.orderNumber.isNotEmpty)
            pw.Text(
              'Order No. : ${invoice.orderNumber}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          if (invoice.orderDate != null)
            pw.Text(
              'Order Dated : ${DateFormat('dd-MMM-yy').format(invoice.orderDate!)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          if (invoice.paymentTerms.isNotEmpty)
            pw.Text(
              'Payment Terms : ${invoice.paymentTerms}',
              style: const pw.TextStyle(fontSize: 8),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice, AppSettings settings) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // S.No
        1: const pw.FlexColumnWidth(5), // Item Description
        2: const pw.FixedColumnWidth(60), // HSN/SAC Code
        3: const pw.FixedColumnWidth(35), // Qty
        4: const pw.FixedColumnWidth(35), // Unit
        5: const pw.FixedColumnWidth(55), // Rate
        6: const pw.FixedColumnWidth(65), // Amount
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _tableCell('S. No.', isHeader: true),
            _tableCell('Item Description',
                isHeader: true, align: pw.TextAlign.left),
            _tableCell('HSN/SAC Code', isHeader: true),
            _tableCell('Qty', isHeader: true),
            _tableCell('Unit', isHeader: true),
            _tableCell('Rate', isHeader: true),
            _tableCell('Amount', isHeader: true),
          ],
        ),

        // Item Rows
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _tableCell(index.toString()),
              _tableCell(item.description, align: pw.TextAlign.left),
              _tableCell(item.hsnCode.isNotEmpty ? item.hsnCode : '-'),
              _tableCell(item.quantity.toStringAsFixed(0)),
              _tableCell(item.unit),
              _tableCell(item.unitPrice.toStringAsFixed(2)),
              _tableCell((item.quantity * item.unitPrice).toStringAsFixed(2)),
            ],
          );
        }),

        // Empty rows for spacing (minimum 8 rows total to fill page)
        ...List.generate(
          (8 - invoice.items.length).clamp(0, 8),
          (index) => pw.TableRow(
            children: [
              _tableCell(''),
              _tableCell(''),
              _tableCell(''),
              _tableCell(''),
              _tableCell(''),
              _tableCell(''),
              _tableCell(''),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(String text,
      {bool isHeader = false, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 7 : 6.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
        maxLines: isHeader ? 2 : 3,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static pw.Widget _buildTotalsSection(Invoice invoice, AppSettings settings) {
    final subtotal = invoice.subtotal;
    final packagingCharges = invoice.courierCharges;
    final taxableValue = subtotal + packagingCharges;
    final igst = invoice.isInterstate ? taxableValue * 0.18 : 0.0;
    final cgst = !invoice.isInterstate ? taxableValue * 0.09 : 0.0;
    final sgst = !invoice.isInterstate ? taxableValue * 0.09 : 0.0;
    final grandTotal = taxableValue + igst + cgst + sgst;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Total in Words
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.black, width: 1),
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total Invoice Value (in words)',
                  style:
                      pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  _numberToWords(grandTotal),
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // Right: Tax Breakdown
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            children: [
              _totalRow('Total :', subtotal, settings),
              _totalRow('Packaging &\nForwarding Charges :', packagingCharges,
                  settings),
              _totalRow('Taxable Value :', taxableValue, settings),
              if (invoice.isInterstate)
                _totalRow('IGST', igst, settings, rate: '18%')
              else ...[
                _totalRow('CGST', cgst, settings, rate: '9%'),
                _totalRow('SGST', sgst, settings, rate: '9%'),
              ],
              _totalRow('Round Off :', 0.0, settings),

              // Grand Total
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 1),
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'GRAND TOTAL :',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      grandTotal.toStringAsFixed(2),
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, double amount, AppSettings settings,
      {String? rate}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 6.5),
              maxLines: 2,
              overflow: pw.TextOverflow.clip,
            ),
          ),
          if (rate != null)
            pw.Container(
              width: 30,
              child: pw.Text(
                rate,
                style: const pw.TextStyle(fontSize: 6.5),
                textAlign: pw.TextAlign.center,
              ),
            ),
          pw.Container(
            width: 50,
            child: pw.Text(
              amount.toStringAsFixed(2),
              style: const pw.TextStyle(fontSize: 6.5),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankDetails(AppSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Bank Details : ',
                style:
                    pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                settings.bankName ?? 'PUNJAB NATIONAL BANK',
                style: const pw.TextStyle(fontSize: 7),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              if (settings.bankAccountNumber != null &&
                  settings.bankAccountNumber!.isNotEmpty) ...[
                pw.Text(
                  'A/c No. : ',
                  style: pw.TextStyle(
                      fontSize: 6.5, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  settings.bankAccountNumber!,
                  style: const pw.TextStyle(fontSize: 6.5),
                ),
                pw.SizedBox(width: 20),
              ],
              if (settings.bankIfscCode != null &&
                  settings.bankIfscCode!.isNotEmpty) ...[
                pw.Text(
                  'IFSC Code No. : ',
                  style: pw.TextStyle(
                      fontSize: 6.5, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  settings.bankIfscCode!,
                  style: const pw.TextStyle(fontSize: 6.5),
                ),
              ],
            ],
          ),
          if (settings.bankRoutingNumber != null &&
              settings.bankRoutingNumber!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Row(
                children: [
                  pw.Text(
                    'Branch : ',
                    style: pw.TextStyle(
                        fontSize: 6.5, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    settings.bankRoutingNumber!,
                    style: const pw.TextStyle(fontSize: 6.5),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerNotes(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Text(
        'Customer Notes:',
        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildTermsAndConditions(AppSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Terms & Conditions:',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            settings.termsAndConditions ??
                '1. Goods once sold will not be taken back.\n'
                    '2. Interest @ 18% p.a will be charged if bill is not paid within 7 days thereafter it will not be entertained.\n'
                    '3. The seller is not responsible for any damage during transit.\n'
                    '4. All disputes subject to delhi jurisdiction only.',
            style: const pw.TextStyle(fontSize: 6),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureSection(AppSettings settings,
      pw.MemoryImage? signatureImage, pw.MemoryImage? stampImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // E. & O.E.
          pw.Text(
            'E. & O.E.',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),

          // Stamp (if available)
          if (stampImage != null)
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(stampImage, fit: pw.BoxFit.contain),
            ),

          // Signature Section
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (signatureImage != null)
                pw.Container(
                  width: 90,
                  height: 45,
                  child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                )
              else
                pw.SizedBox(height: 45),
              pw.SizedBox(height: 3),
              pw.Text(
                'Authorised Signatory',
                style:
                    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                'For ${settings.companyName.toUpperCase()}',
                style:
                    pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _numberToWords(double number) {
    var intPart = number.floor();
    if (intPart == 0) return 'Zero Only';

    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    String result = '';

    // Lakhs
    if (intPart >= 100000) {
      final lakhs = intPart ~/ 100000;
      if (lakhs >= 10) {
        result += '${tens[lakhs ~/ 10]} ';
        if (lakhs % 10 > 0) result += '${ones[lakhs % 10]} ';
      } else {
        result += '${ones[lakhs]} ';
      }
      result += 'Lakh ';
      intPart %= 100000;
    }

    // Thousands
    if (intPart >= 1000) {
      final thousands = intPart ~/ 1000;
      if (thousands >= 20) {
        result += '${tens[thousands ~/ 10]} ';
        if (thousands % 10 > 0) result += '${ones[thousands % 10]} ';
      } else if (thousands >= 10) {
        result += '${teens[thousands - 10]} ';
      } else {
        result += '${ones[thousands]} ';
      }
      result += 'Thousand ';
      intPart %= 1000;
    }

    // Hundreds
    if (intPart >= 100) {
      result += '${ones[intPart ~/ 100]} Hundred ';
      intPart %= 100;
    }

    // Tens and Ones
    if (intPart >= 20) {
      result += '${tens[intPart ~/ 10]} ';
      intPart %= 10;
    } else if (intPart >= 10) {
      result += '${teens[intPart - 10]} ';
      intPart = 0;
    }

    if (intPart > 0) {
      result += '${ones[intPart]} ';
    }

    return '${result.trim()} Only';
  }
}
