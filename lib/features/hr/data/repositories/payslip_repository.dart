import 'package:hive_flutter/hive_flutter.dart';
import '../models/payslip_model.dart';

class PayslipRepository {
  static const String _boxName = 'payslips';

  Box<Payslip> get box => Hive.box<Payslip>(_boxName);

  // Create
  Future<void> addPayslip(Payslip payslip) async {
    await box.put(payslip.id, payslip);
  }

  // Read
  Payslip? getPayslip(String id) {
    return box.get(id);
  }

  List<Payslip> getAllPayslips() {
    return box.values.toList()
      ..sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.month.compareTo(a.month);
      });
  }

  List<Payslip> getPayslipsByEmployee(String employeeId) {
    return box.values
        .where((payslip) => payslip.employeeId == employeeId)
        .toList()
      ..sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.month.compareTo(a.month);
      });
  }

  Payslip? getPayslipByEmployeeAndMonth({
    required String employeeId,
    required int month,
    required int year,
  }) {
    try {
      return box.values.firstWhere(
        (payslip) =>
            payslip.employeeId == employeeId &&
            payslip.month == month &&
            payslip.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  List<Payslip> getPayslipsByMonth({
    required int month,
    required int year,
  }) {
    return box.values
        .where((payslip) => payslip.month == month && payslip.year == year)
        .toList();
  }

  List<Payslip> getPayslipsByStatus(PayslipStatus status) {
    return box.values.where((payslip) => payslip.status == status).toList();
  }

  // Update
  Future<void> updatePayslip(Payslip payslip) async {
    await box.put(payslip.id, payslip);
  }

  Future<void> markAsPaid(String payslipId) async {
    final payslip = getPayslip(payslipId);
    if (payslip != null) {
      final updated = Payslip(
        id: payslip.id,
        employeeId: payslip.employeeId,
        employeeName: payslip.employeeName,
        month: payslip.month,
        year: payslip.year,
        totalDaysInMonth: payslip.totalDaysInMonth,
        payableDays: payslip.payableDays,
        presentDays: payslip.presentDays,
        leaveDays: payslip.leaveDays,
        basicSalary: payslip.basicSalary,
        grossEarnings: payslip.grossEarnings,
        totalDeductions: payslip.totalDeductions,
        netSalary: payslip.netSalary,
        pfDeduction: payslip.pfDeduction,
        esiDeduction: payslip.esiDeduction,
        tdsDeduction: payslip.tdsDeduction,
        professionalTax: payslip.professionalTax,
        status: PayslipStatus.paid,
        generatedDate: payslip.generatedDate,
        paymentDate: DateTime.now(),
      );
      await updatePayslip(updated);
    }
  }

  // Delete
  Future<void> deletePayslip(String id) async {
    await box.delete(id);
  }

  // Statistics
  double getTotalPayrollForMonth({
    required int month,
    required int year,
  }) {
    return getPayslipsByMonth(month: month, year: year)
        .fold(0.0, (sum, payslip) => sum + payslip.netSalary);
  }

  int getPendingPayslipsCount() {
    return box.values
        .where((payslip) => payslip.status != PayslipStatus.paid)
        .length;
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await box.clear();
  }
}
