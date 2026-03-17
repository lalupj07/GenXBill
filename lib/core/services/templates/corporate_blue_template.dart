import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/app_settings.dart';
import '../../../features/invoices/data/models/invoice_model.dart';

/// Corporate Blue Template - Professional blue headers with clean white body
class CorporateBlueTemplate {
  static Future<pw.Document> generatePDF(
      Invoice invoice, AppSettings settings) async {
    final pdf = pw.Document();

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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => _buildInvoice(
            invoice, settings, logoImage, signatureImage, stampImage),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildInvoice(
    Invoice invoice,
    AppSettings settings,
    pw.MemoryImage? logoImage,
    pw.MemoryImage? signatureImage,
    pw.MemoryImage? stampImage,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(invoice, settings, logoImage),
        pw.SizedBox(height: 20),
        _buildPartyDetails(invoice, settings),
        pw.SizedBox(height: 20),
        _buildItemsTable(invoice, settings),
        pw.SizedBox(height: 20),
        _buildTotalsSection(invoice, settings),
        pw.SizedBox(height: 20),
        _buildFooter(invoice, settings, signatureImage, stampImage),
      ],
    );
  }

  static pw.Widget _buildHeader(
    Invoice invoice,
    AppSettings settings,
    pw.MemoryImage? logoImage,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue700, width: 3),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.Container(
                    height: 50,
                    child: pw.Image(logoImage),
                  )
                else
                  pw.Text(
                    settings.companyName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                pw.SizedBox(height: 5),
                pw.Text(
                  settings.companyAddress,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700),
                ),
                if (settings.taxId != null && settings.taxId!.isNotEmpty)
                  pw.Text(
                    'GSTIN: ${settings.taxId}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    ),
                  ),
                pw.Text(
                  '${settings.companyEmail} | ${settings.companyPhone}',
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                invoice.invoiceNumber,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Date: ${DateFormat('dd-MMM-yy').format(invoice.date)}',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPartyDetails(Invoice invoice, AppSettings settings) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILLED TO',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoice.clientName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  invoice.clientAddress,
                  style: const pw.TextStyle(fontSize: 9),
                ),
                if (invoice.clientGstin.isNotEmpty)
                  pw.Text(
                    'GSTIN: ${invoice.clientGstin}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SHIPPED TO',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoice.clientName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  invoice.shippingAddress.isNotEmpty
                      ? invoice.shippingAddress
                      : invoice.clientAddress,
                  style: const pw.TextStyle(fontSize: 9),
                ),
                if (invoice.transportMode.isNotEmpty)
                  pw.Text(
                    'MODE: ${invoice.transportMode}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice, AppSettings settings) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.blue200, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(70),
        5: const pw.FixedColumnWidth(80),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: [
            _buildTableHeader('S.NO'),
            _buildTableHeader('ITEM DESCRIPTION'),
            _buildTableHeader('HSN'),
            _buildTableHeader('QTY'),
            _buildTableHeader('RATE'),
            _buildTableHeader('AMOUNT'),
          ],
        ),
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColors.white : PdfColors.blue50,
            ),
            children: [
              _buildTableCell('${index + 1}', align: pw.Alignment.center),
              _buildTableCell(item.description),
              _buildTableCell(item.hsnCode, align: pw.Alignment.center),
              _buildTableCell('${item.quantity.toInt()}',
                  align: pw.Alignment.center),
              _buildTableCell('₹${item.unitPrice.toStringAsFixed(2)}',
                  align: pw.Alignment.centerRight),
              _buildTableCell(
                  '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  align: pw.Alignment.centerRight),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: align,
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  static pw.Widget _buildTotalsSection(Invoice invoice, AppSettings settings) {
    final taxRate = invoice.isInterstate ? 0.0 : 9.0;
    final cgst = invoice.isInterstate ? 0.0 : invoice.tax / 2;
    final sgst = invoice.isInterstate ? 0.0 : invoice.tax / 2;
    final igst = invoice.isInterstate ? invoice.tax : 0.0;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColors.blue200),
          ),
          child: pw.Column(
            children: [
              _buildTotalRow('Subtotal', invoice.subtotal, settings),
              if (!invoice.isInterstate) ...[
                _buildTotalRow('CGST @ $taxRate%', cgst, settings),
                _buildTotalRow('SGST @ $taxRate%', sgst, settings),
              ] else
                _buildTotalRow('IGST @ 18%', igst, settings),
              pw.Divider(color: PdfColors.blue300),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8),
                      child: pw.Text(
                        'GRAND TOTAL',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 8),
                      child: pw.Text(
                        '₹${invoice.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
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

  static pw.Widget _buildTotalRow(
      String label, double amount, AppSettings settings) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(
    Invoice invoice,
    AppSettings settings,
    pw.MemoryImage? signatureImage,
    pw.MemoryImage? stampImage,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (settings.bankName != null && settings.bankName!.isNotEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bank Details',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Bank: ${settings.bankName ?? ''} | A/C: ${settings.bankAccountNumber ?? ''} | IFSC: ${settings.bankIfscCode ?? ''}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terms & Conditions',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Goods once sold will not be taken back.\nClaims within 7 days of receipt.',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'For ${settings.companyName}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                if (signatureImage != null)
                  pw.Container(
                    height: 40,
                    width: 80,
                    child: pw.Image(signatureImage),
                  )
                else
                  pw.SizedBox(height: 40),
                pw.Text(
                  'Authorised Signatory',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
