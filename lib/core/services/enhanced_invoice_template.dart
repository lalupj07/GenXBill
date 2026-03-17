import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/app_settings.dart';
import '../../features/invoices/data/models/invoice_model.dart';

// Add InvoiceStatus import if needed
// The InvoiceStatus enum is already in invoice_model.dart

/// Enhanced Professional Invoice Template with Comprehensive Details
/// Features: Modern design, complete tax breakdown, payment info, QR code support
class EnhancedInvoiceTemplate {
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
        margin: const pw.EdgeInsets.all(15),
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
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Top Bar: GSTIN and Document Type
          _buildTopBar(settings, invoice),

          // Header: Logo and Company Details
          _buildCompanyHeader(settings, logoImage),

          // Invoice Title
          _buildInvoiceTitle(invoice),

          // Invoice Details Row (Number, Date, Due Date)
          _buildInvoiceDetailsRow(invoice),

          // Billing and Shipping Details (Side by Side)
          _buildBillingShippingSection(invoice),

          // Order/Reference Details
          _buildOrderReferenceRow(invoice),

          // Items Table with Tax Details
          _buildItemsTable(invoice, settings),

          // Totals Section (Amount in Words + Tax Breakdown)
          _buildTotalsSection(invoice, settings),

          // Payment Information
          _buildPaymentInformation(invoice, settings),

          // Bank Details
          _buildBankDetails(settings),

          // Additional Notes
          if (invoice.notes.isNotEmpty) _buildNotes(invoice),

          // Terms & Conditions
          _buildTermsAndConditions(settings),

          // Footer: Signature and Declaration
          _buildFooterSection(settings, signatureImage, stampImage),
        ],
      ),
    );
  }

  static pw.Widget _buildTopBar(AppSettings settings, Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'GSTIN: ',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                settings.taxId ?? 'N/A',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.blue900),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: pw.BoxDecoration(
              color: PdfColors.red700,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              'ORIGINAL FOR RECIPIENT',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompanyHeader(
      AppSettings settings, pw.MemoryImage? logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo
          if (logoImage != null)
            pw.Container(
              width: 80,
              height: 80,
              margin: const pw.EdgeInsets.only(right: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 5,
                verticalRadius: 5,
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
            )
          else
            pw.Container(
              width: 80,
              height: 80,
              margin: const pw.EdgeInsets.only(right: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(5),
                color: PdfColors.grey100,
              ),
              child: pw.Center(
                child: pw.Text(
                  'LOGO',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Company Details
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  settings.companyName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (settings.companyAddress.isNotEmpty)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Address: ',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          settings.companyAddress,
                          style: const pw.TextStyle(fontSize: 8),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Text(
                      'Email: ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      settings.companyEmail,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Phone: ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      settings.companyPhone,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                if (settings.companyWebsite != null &&
                    settings.companyWebsite!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          'Website: ',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          settings.companyWebsite!,
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.blue700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceTitle(Invoice invoice) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue900,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          invoice.isInterstate
              ? 'TAX INVOICE (INTERSTATE)'
              : 'TAX INVOICE / BILL OF SUPPLY',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildInvoiceDetailsRow(Invoice invoice) {
    final dueDate = invoice.dueDate;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _infoBox('Invoice No.', invoice.invoiceNumber, PdfColors.blue900),
          _infoBox(
              'Invoice Date',
              DateFormat('dd-MMM-yyyy').format(invoice.date),
              PdfColors.blue900),
          _infoBox('Due Date', DateFormat('dd-MMM-yyyy').format(dueDate),
              PdfColors.red700),
          if (invoice.status == InvoiceStatus.paid)
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                'PAID',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _infoBox(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBillingShippingSection(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Billing Details
        pw.Expanded(
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
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoice.clientName,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                if (invoice.clientAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    invoice.clientAddress,
                    style: const pw.TextStyle(fontSize: 8),
                    maxLines: 3,
                  ),
                ],
                pw.SizedBox(height: 4),
                if (invoice.clientGstin.isNotEmpty)
                  _detailRow('GSTIN', invoice.clientGstin),
                if (invoice.clientStateCode.isNotEmpty)
                  _detailRow('State Code', invoice.clientStateCode),
                if (invoice.clientPhone.isNotEmpty)
                  _detailRow('Phone', invoice.clientPhone),
                if (invoice.clientEmail.isNotEmpty)
                  _detailRow('Email', invoice.clientEmail),
              ],
            ),
          ),
        ),

        // Shipping Details
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green700,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    'SHIP TO',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoice.shippingAddress.isNotEmpty
                      ? invoice.shippingAddress
                      : invoice.clientName,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                if (invoice.destination.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    invoice.destination,
                    style: const pw.TextStyle(fontSize: 8),
                    maxLines: 3,
                  ),
                ],
                pw.SizedBox(height: 4),
                if (invoice.transportMode.isNotEmpty)
                  _detailRow('Transport Mode', invoice.transportMode),
                if (invoice.dispatchedThrough.isNotEmpty)
                  _detailRow('Dispatched Through', invoice.dispatchedThrough),
                if (invoice.deliveryNote.isNotEmpty)
                  _detailRow('Delivery Note', invoice.deliveryNote),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.Container(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 7),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderReferenceRow(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (invoice.orderNumber.isNotEmpty)
            _smallInfoBox('Order No.', invoice.orderNumber),
          if (invoice.orderDate != null)
            _smallInfoBox('Order Date',
                DateFormat('dd-MMM-yy').format(invoice.orderDate!)),
          if (invoice.paymentTerms.isNotEmpty)
            _smallInfoBox('Payment Terms', invoice.paymentTerms),
          if (invoice.poNumber.isNotEmpty)
            _smallInfoBox('PO Number', invoice.poNumber),
        ],
      ),
    );
  }

  static pw.Widget _smallInfoBox(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 7),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice, AppSettings settings) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(25), // S.No
        1: const pw.FlexColumnWidth(4), // Description
        2: const pw.FixedColumnWidth(50), // HSN/SAC
        3: const pw.FixedColumnWidth(30), // Qty
        4: const pw.FixedColumnWidth(30), // Unit
        5: const pw.FixedColumnWidth(45), // Rate
        6: const pw.FixedColumnWidth(50), // Discount
        7: const pw.FixedColumnWidth(50), // Tax %
        8: const pw.FixedColumnWidth(60), // Amount
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue900,
          ),
          children: [
            _tableHeaderCell('S.No'),
            _tableHeaderCell('Item Description', align: pw.TextAlign.left),
            _tableHeaderCell('HSN/SAC'),
            _tableHeaderCell('Qty'),
            _tableHeaderCell('Unit'),
            _tableHeaderCell('Rate'),
            _tableHeaderCell('Disc.'),
            _tableHeaderCell('Tax %'),
            _tableHeaderCell('Amount'),
          ],
        ),

        // Item Rows
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          final itemTotal = item.quantity * item.unitPrice;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              _tableCell(index.toString()),
              _tableCell(item.description, align: pw.TextAlign.left),
              _tableCell(item.hsnCode.isNotEmpty ? item.hsnCode : '-'),
              _tableCell(item.quantity.toStringAsFixed(2)),
              _tableCell(item.unit),
              _tableCell(item.unitPrice.toStringAsFixed(2)),
              _tableCell('-'),
              _tableCell('18%'),
              _tableCell(itemTotal.toStringAsFixed(2)),
            ],
          );
        }),

        // Empty rows to fill page
        ...List.generate(
          (10 - invoice.items.length).clamp(0, 10),
          (index) => pw.TableRow(
            children: List.generate(9, (_) => _tableCell('')),
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text,
      {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: align,
        maxLines: 2,
      ),
    );
  }

  static pw.Widget _tableCell(String text,
      {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 6.5),
        textAlign: align,
        maxLines: 3,
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
        // Left: Amount in Words
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
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
                  'Total Invoice Amount (in words):',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _numberToWords(grandTotal),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    border: pw.Border.all(color: PdfColors.amber700),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tax Summary:',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Taxable Amount: ₹${taxableValue.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 6.5),
                      ),
                      if (invoice.isInterstate)
                        pw.Text(
                          'IGST @ 18%: ₹${igst.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 6.5),
                        )
                      else ...[
                        pw.Text(
                          'CGST @ 9%: ₹${cgst.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 6.5),
                        ),
                        pw.Text(
                          'SGST @ 9%: ₹${sgst.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 6.5),
                        ),
                      ],
                      pw.Text(
                        'Total Tax: ₹${(igst + cgst + sgst).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 6.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right: Amount Breakdown
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            children: [
              _amountRow('Subtotal', subtotal),
              if (packagingCharges > 0)
                _amountRow('Packaging/Courier', packagingCharges),
              _amountRow('Taxable Amount', taxableValue, isBold: true),
              pw.Container(height: 0.5, color: PdfColors.grey400),
              if (invoice.isInterstate)
                _amountRow('IGST @ 18%', igst)
              else ...[
                _amountRow('CGST @ 9%', cgst),
                _amountRow('SGST @ 9%', sgst),
              ],
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 1.5),
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'GRAND TOTAL',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '₹ ${grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
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

  static pw.Widget _amountRow(String label, double amount,
      {bool isBold = false, bool isNegative = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              maxLines: 2,
            ),
          ),
          pw.Text(
            '${isNegative ? '-' : ''}₹ ${amount.abs().toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentInformation(
      Invoice invoice, AppSettings settings) {
    final statusColor = invoice.status == InvoiceStatus.paid
        ? PdfColors.green700
        : invoice.status == InvoiceStatus.overdue
            ? PdfColors.red700
            : PdfColors.orange700;
    final bgColor = invoice.status == InvoiceStatus.paid
        ? PdfColors.green50
        : invoice.status == InvoiceStatus.overdue
            ? PdfColors.red50
            : PdfColors.orange50;

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: const pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Status:',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: statusColor,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  invoice.status.toString().split('.').last.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Total Amount:',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '₹ ${invoice.total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankDetails(AppSettings settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  'BANK DETAILS',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: _bankDetailItem('Bank Name', settings.bankName ?? 'N/A'),
              ),
              pw.Expanded(
                child: _bankDetailItem(
                    'Account Number', settings.bankAccountNumber ?? 'N/A'),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Row(
            children: [
              pw.Expanded(
                child: _bankDetailItem(
                    'IFSC Code', settings.bankIfscCode ?? 'N/A'),
              ),
              pw.Expanded(
                child: _bankDetailItem(
                    'Branch', settings.bankRoutingNumber ?? 'N/A'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _bankDetailItem(String label, String value) {
    return pw.Row(
      children: [
        pw.Container(
          width: 90,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 7),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildNotes(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Additional Notes:',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            invoice.notes,
            style: const pw.TextStyle(fontSize: 7),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsAndConditions(AppSettings settings) {
    final terms = settings.termsAndConditions ??
        '1. Goods once sold will not be taken back or exchanged.\n'
            '2. Interest @ 18% p.a. will be charged if payment is not made within the due date.\n'
            '3. All disputes are subject to [CITY] jurisdiction only.\n'
            '4. Please check goods before accepting delivery.';

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Terms & Conditions:',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            terms,
            style: const pw.TextStyle(fontSize: 6.5),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterSection(AppSettings settings,
      pw.MemoryImage? signatureImage, pw.MemoryImage? stampImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Left: Declaration
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Declaration:',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'We declare that this invoice shows the actual price\n'
                'of the goods described and that all particulars are\n'
                'true and correct.',
                style: const pw.TextStyle(fontSize: 6.5),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'E. & O.E.',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),

          // Center: Company Stamp
          if (stampImage != null)
            pw.Container(
              width: 70,
              height: 70,
              child: pw.Image(stampImage, fit: pw.BoxFit.contain),
            ),

          // Right: Signature
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'For ${settings.companyName.toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              if (signatureImage != null)
                pw.Container(
                  width: 100,
                  height: 50,
                  child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                )
              else
                pw.Container(
                  width: 100,
                  height: 50,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Authorised Signatory',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _numberToWords(double number) {
    final intPart = number.floor();
    if (intPart == 0) return 'Zero Rupees Only';

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
    var remaining = intPart;

    // Crores
    if (remaining >= 10000000) {
      final crores = remaining ~/ 10000000;
      result += '${_convertTwoDigits(crores, ones, tens, teens)} Crore ';
      remaining %= 10000000;
    }

    // Lakhs
    if (remaining >= 100000) {
      final lakhs = remaining ~/ 100000;
      result += '${_convertTwoDigits(lakhs, ones, tens, teens)} Lakh ';
      remaining %= 100000;
    }

    // Thousands
    if (remaining >= 1000) {
      final thousands = remaining ~/ 1000;
      result += '${_convertTwoDigits(thousands, ones, tens, teens)} Thousand ';
      remaining %= 1000;
    }

    // Hundreds
    if (remaining >= 100) {
      result += '${ones[remaining ~/ 100]} Hundred ';
      remaining %= 100;
    }

    // Tens and Ones
    if (remaining > 0) {
      result += _convertTwoDigits(remaining, ones, tens, teens);
    }

    return '${result.trim()} Rupees Only';
  }

  static String _convertTwoDigits(
      int num, List<String> ones, List<String> tens, List<String> teens) {
    if (num == 0) return '';
    if (num < 10) return ones[num];
    if (num < 20) return teens[num - 10];
    return '${tens[num ~/ 10]} ${ones[num % 10]}'.trim();
  }
}
