import 'package:hive_flutter/hive_flutter.dart';

part 'payslip_model.g.dart';

@HiveType(typeId: 58)
enum PayslipStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  generated, // Finalized but not paid
  @HiveField(2)
  paid,
}

@HiveType(typeId: 59)
class Payslip extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final String employeeName; // Snapshot in case name changes

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  // Days Calculation
  @HiveField(5)
  final int totalDaysInMonth;

  @HiveField(6)
  final double payableDays;

  @HiveField(7)
  final double presentDays;

  @HiveField(8)
  final double leaveDays;

  // Financials
  @HiveField(9)
  final double basicSalary; // The fixed monthly salary

  @HiveField(10)
  final double grossEarnings; // Calculated based on payable days

  @HiveField(11)
  final double totalDeductions;

  @HiveField(12)
  final double netSalary;

  // Deductions Breakdown
  @HiveField(13)
  final double pfDeduction;

  @HiveField(14)
  final double esiDeduction;

  @HiveField(15)
  final double tdsDeduction;

  @HiveField(16)
  final double professionalTax;

  @HiveField(17)
  final PayslipStatus status;

  @HiveField(18)
  final DateTime generatedDate;

  @HiveField(19)
  final DateTime? paymentDate;

  Payslip({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.totalDaysInMonth,
    required this.payableDays,
    required this.presentDays,
    required this.leaveDays,
    required this.basicSalary,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.pfDeduction,
    required this.esiDeduction,
    required this.tdsDeduction,
    required this.professionalTax,
    this.status = PayslipStatus.draft,
    required this.generatedDate,
    this.paymentDate,
  });
}
