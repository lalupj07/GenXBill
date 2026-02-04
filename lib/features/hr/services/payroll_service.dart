import 'package:genx_bill/features/hr/data/models/payslip_model.dart';
import 'package:genx_bill/features/hr/data/models/attendance_model.dart';
import 'package:genx_bill/features/hr/data/models/leave_model.dart';
import 'package:genx_bill/features/hr/data/repositories/employee_repository.dart';
import 'package:genx_bill/features/hr/data/repositories/attendance_repository.dart';
import 'package:genx_bill/features/hr/data/repositories/leave_repository.dart';
import 'package:genx_bill/core/utils/app_logger.dart';

/// Service to calculate salary and generate payslips
class PayrollService {
  final EmployeeRepository employeeRepository;
  final AttendanceRepository attendanceRepository;
  final LeaveRepository leaveRepository;

  PayrollService({
    required this.employeeRepository,
    required this.attendanceRepository,
    required this.leaveRepository,
  });

  /// Calculate payslip for an employee for a given month/year
  Payslip calculatePayslip({
    required String employeeId,
    required int month,
    required int year,
  }) {
    final employee = employeeRepository.getEmployee(employeeId);
    if (employee == null) {
      throw Exception('Employee not found');
    }

    // Get total days in month
    final totalDaysInMonth = DateTime(year, month + 1, 0).day;

    // Get attendance data
    final attendanceRecords = attendanceRepository.getMonthlyAttendance(
      employeeId,
      year,
      month,
    );

    // Get leave data for the month
    final leaves =
        leaveRepository.getLeavesByEmployee(employeeId).where((leave) {
      return leave.startDate.year == year && leave.startDate.month == month;
    }).toList();

    // Calculate present days from attendance
    final presentDays = attendanceRecords
        .where((att) => att.status == AttendanceStatus.present)
        .length
        .toDouble();

    // Calculate approved leave days
    final approvedLeaveDays = leaves
        .where((leave) => leave.status == LeaveStatus.approved)
        .fold(0.0, (sum, leave) => sum + leave.numberOfDays);

    // Payable days = Present days + Approved leave days
    final payableDays = presentDays + approvedLeaveDays;

    // Calculate gross earnings (pro-rated based on payable days)
    final basicSalary = employee.salary;
    final grossEarnings = (basicSalary / totalDaysInMonth) * payableDays;

    // Get payroll settings
    final payrollSettings = employee.payrollSettings;

    // Calculate deductions
    double pfDeduction = 0.0;
    double esiDeduction = 0.0;
    double tdsDeduction = 0.0;
    double professionalTax = 0.0;

    if (payrollSettings != null) {
      if (payrollSettings.enablePF) {
        pfDeduction = grossEarnings * (payrollSettings.pfPercentage / 100);
      }
      if (payrollSettings.enableESI) {
        esiDeduction = grossEarnings * (payrollSettings.esiPercentage / 100);
      }
      tdsDeduction = grossEarnings * (payrollSettings.tdsPercentage / 100);
      professionalTax = payrollSettings.professionalTax;
    }

    final totalDeductions =
        pfDeduction + esiDeduction + tdsDeduction + professionalTax;
    final netSalary = grossEarnings - totalDeductions;

    return Payslip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      employeeName: employee.name,
      month: month,
      year: year,
      totalDaysInMonth: totalDaysInMonth,
      payableDays: payableDays,
      presentDays: presentDays,
      leaveDays: approvedLeaveDays,
      basicSalary: basicSalary,
      grossEarnings: grossEarnings,
      totalDeductions: totalDeductions,
      netSalary: netSalary,
      pfDeduction: pfDeduction,
      esiDeduction: esiDeduction,
      tdsDeduction: tdsDeduction,
      professionalTax: professionalTax,
      status: PayslipStatus.draft,
      generatedDate: DateTime.now(),
    );
  }

  /// Generate payslips for all active employees for a given month/year
  List<Payslip> generatePayslipsForAllEmployees({
    required int month,
    required int year,
  }) {
    final activeEmployees = employeeRepository.getActiveEmployees();
    final payslips = <Payslip>[];

    for (final employee in activeEmployees) {
      try {
        final payslip = calculatePayslip(
          employeeId: employee.id,
          month: month,
          year: year,
        );
        payslips.add(payslip);
      } catch (e) {
        AppLogger.error('Error generating payslip for ${employee.name}', e);
      }
    }

    return payslips;
  }
}
