import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reports/domain/models/report_data.dart';
import '../models/app_settings.dart';
import 'package:intl/intl.dart';
import '../../features/invoices/data/models/invoice_model.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/hr/data/models/attendance_model.dart';
import '../../features/hr/data/models/leave_model.dart';

class CsvService {
  String generateReportCsv(ReportData data, AppSettings settings) {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([settings.companyName, 'Financial Report']);
    rows.add(['Period:', data.periodName]);
    rows.add(['Generated:', DateFormat.yMMMd().format(DateTime.now())]);
    rows.add([]); // Empty row

    // Summary
    rows.add(['SUMMARY']);
    rows.add(['Total Revenue', data.revenue.toStringAsFixed(2)]);
    rows.add(['Total Expenses', data.expenses.toStringAsFixed(2)]);
    rows.add(['Net Profit', data.netProfit.toStringAsFixed(2)]);
    rows.add([]);

    // Recent Invoices
    if (data.invoices.isNotEmpty) {
      rows.add(['INVOICES']);
      rows.add(['Date', 'Invoice #', 'Client', 'Amount', 'Status']);
      for (var inv in data.invoices) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(inv.date),
          inv.invoiceNumber,
          inv.clientName,
          inv.total.toStringAsFixed(2),
          inv.status.name,
        ]);
      }
      rows.add([]);
    }

    // Recent Expenses
    if (data.expenseList.isNotEmpty) {
      rows.add(['EXPENSES']);
      rows.add(['Date', 'Description', 'Category', 'Amount']);
      for (var exp in data.expenseList) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(exp.date),
          exp.description,
          exp.getCategoryName(),
          exp.amount.toStringAsFixed(2),
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateHsnSummaryCsv(List<Invoice> invoices, AppSettings settings) {
    List<List<dynamic>> rows = [];
    rows.add([settings.companyName, 'HSN-wise Summary']);
    rows.add(['Generated:', DateFormat.yMMMd().format(DateTime.now())]);
    rows.add([]);

    Map<String, Map<String, dynamic>> hsnSummary = {};

    for (var inv in invoices) {
      for (var item in inv.items) {
        final hsn = item.hsnCode.isEmpty ? 'N/A' : item.hsnCode;
        if (!hsnSummary.containsKey(hsn)) {
          hsnSummary[hsn] = {
            'qty': 0.0,
            'taxableValue': 0.0,
            'taxAmount': 0.0,
            'total': 0.0,
          };
        }

        final qty = item.quantity;
        final taxableValue = item.unitPrice * qty;
        // Assume 18% as per current invoice logic if not explicitly available per item
        final taxAmount = taxableValue * 0.18;

        hsnSummary[hsn]!['qty'] += qty;
        hsnSummary[hsn]!['taxableValue'] += taxableValue;
        hsnSummary[hsn]!['taxAmount'] += taxAmount;
        hsnSummary[hsn]!['total'] += (taxableValue + taxAmount);
      }
    }

    rows.add(
        ['HSN Code', 'Quantity', 'Taxable Value', 'Tax Amount', 'Total Value']);
    hsnSummary.forEach((hsn, data) {
      rows.add([
        hsn,
        data['qty'],
        data['taxableValue'].toStringAsFixed(2),
        data['taxAmount'].toStringAsFixed(2),
        data['total'].toStringAsFixed(2),
      ]);
    });

    return const ListToCsvConverter().convert(rows);
  }

  String generateProductOnlyCsv(List<Product> products, AppSettings settings) {
    List<List<dynamic>> rows = [];
    rows.add([settings.companyName, 'Product List']);
    rows.add(['Generated:', DateFormat.yMMMd().format(DateTime.now())]);
    rows.add([]);

    rows.add([
      'Name',
      'Description',
      'HSN/SKU',
      'Unit Price',
      'Stock Qty',
      'Min Stock'
    ]);
    for (var product in products) {
      rows.add([
        product.name,
        product.description,
        product.hsnCode.isNotEmpty ? product.hsnCode : product.sku,
        product.unitPrice.toStringAsFixed(2),
        product.stockQuantity,
        product.minStockLevel,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateAttendanceCsv(
      List<Attendance> attendanceList, AppSettings settings) {
    List<List<dynamic>> rows = [];
    rows.add([settings.companyName, 'Attendance Report']);
    rows.add(['Generated:', DateFormat.yMMMd().format(DateTime.now())]);
    rows.add([]);

    rows.add([
      'Date',
      'Employee ID',
      'Status',
      'Check In',
      'Check Out',
      'Work Hours',
      'Overtime',
      'Late?',
      'Early?',
      'Notes'
    ]);

    for (var att in attendanceList) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(att.date),
        att.employeeId,
        att.status.name,
        att.checkIn != null ? DateFormat('HH:mm').format(att.checkIn!) : '-',
        att.checkOut != null ? DateFormat('HH:mm').format(att.checkOut!) : '-',
        att.workHours.toStringAsFixed(2),
        att.overtimeHours.toStringAsFixed(2),
        att.isLateArrival ? 'Yes' : 'No',
        att.isEarlyDeparture ? 'Yes' : 'No',
        att.notes,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String generateLeaveReportCsv(List<Leave> leaveList, AppSettings settings) {
    List<List<dynamic>> rows = [];
    rows.add([settings.companyName, 'Leave Report']);
    rows.add(['Generated:', DateFormat.yMMMd().format(DateTime.now())]);
    rows.add([]);

    rows.add([
      'Employee ID',
      'Type',
      'Status',
      'Days',
      'Start Date',
      'End Date',
      'Reason',
      'Applied On',
      'Approved By'
    ]);

    for (var leave in leaveList) {
      rows.add([
        leave.employeeId,
        leave.leaveTypeName,
        leave.status.name,
        leave.numberOfDays.toString(),
        DateFormat('yyyy-MM-dd').format(leave.startDate),
        DateFormat('yyyy-MM-dd').format(leave.endDate),
        leave.reason,
        DateFormat('yyyy-MM-dd').format(leave.appliedDate),
        leave.approvedBy ?? '-',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}

final csvServiceProvider = Provider<CsvService>((ref) {
  return CsvService();
});
