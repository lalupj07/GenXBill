import 'dart:io';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CsvExportService {
  /// Export invoices to CSV file
  Future<String> exportInvoicesToCsv(List<Invoice> invoices) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'Invoice Number,Client Name,Date,Due Date,Status,Subtotal,Tax,Total,Items Count');

    // CSV Data
    for (var invoice in invoices) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      buffer.writeln([
        _escapeCsv(invoice.invoiceNumber),
        _escapeCsv(invoice.clientName),
        dateFormat.format(invoice.date),
        dateFormat.format(invoice.dueDate),
        _getStatusText(invoice.status),
        invoice.subtotal.toStringAsFixed(2),
        invoice.tax.toStringAsFixed(2),
        invoice.total.toStringAsFixed(2),
        invoice.items.length.toString(),
      ].join(','));
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/invoices_export_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }

  /// Export invoice items to CSV file
  Future<String> exportInvoiceItemsToCsv(List<Invoice> invoices) async {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'Invoice Number,Client Name,Item Description,Quantity,Unit Price,Total');

    // CSV Data
    for (var invoice in invoices) {
      for (var item in invoice.items) {
        buffer.writeln([
          _escapeCsv(invoice.invoiceNumber),
          _escapeCsv(invoice.clientName),
          _escapeCsv(item.description),
          item.quantity.toString(),
          item.unitPrice.toStringAsFixed(2),
          item.total.toStringAsFixed(2),
        ].join(','));
      }
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/invoice_items_export_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }

  /// Escape CSV special characters
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get status text
  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }
}
