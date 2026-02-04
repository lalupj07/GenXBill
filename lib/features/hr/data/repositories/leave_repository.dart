import 'package:hive_flutter/hive_flutter.dart';
import '../models/leave_model.dart';
import '../models/employee_model.dart';
import 'package:genx_bill/core/utils/app_logger.dart';

class LeaveRepository {
  static const String _boxName = 'leaves';

  Box<Leave> get box => Hive.box<Leave>(_boxName);

  // Create
  Future<void> addLeave(Leave leave) async {
    await box.put(leave.id, leave);
  }

  // Read
  Leave? getLeave(String id) {
    return box.get(id);
  }

  List<Leave> getAllLeaves() {
    return box.values.toList();
  }

  List<Leave> getLeavesByEmployee(String employeeId) {
    return box.values.where((leave) => leave.employeeId == employeeId).toList()
      ..sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
  }

  List<Leave> getPendingLeaves() {
    return box.values
        .where((leave) => leave.status == LeaveStatus.pending)
        .toList()
      ..sort((a, b) => a.appliedDate.compareTo(b.appliedDate));
  }

  List<Leave> getApprovedLeaves(String employeeId) {
    return box.values
        .where(
          (leave) =>
              leave.employeeId == employeeId &&
              leave.status == LeaveStatus.approved,
        )
        .toList();
  }

  List<Leave> getLeavesByDateRange(
    String employeeId,
    DateTime start,
    DateTime end,
  ) {
    return box.values.where((leave) {
      return leave.employeeId == employeeId &&
          leave.startDate.isBefore(end.add(const Duration(days: 1))) &&
          leave.endDate.isAfter(start.subtract(const Duration(days: 1)));
    }).toList();
  }

  List<Leave> getLeavesByType(String employeeId, LeaveType type) {
    return box.values
        .where(
          (leave) => leave.employeeId == employeeId && leave.leaveType == type,
        )
        .toList();
  }

  // Update
  Future<void> updateLeave(Leave leave) async {
    await box.put(leave.id, leave);
  }

  Future<void> approveLeave(String leaveId, String approvedBy) async {
    final leave = getLeave(leaveId);
    if (leave != null && leave.status == LeaveStatus.pending) {
      final updated = leave.approve(approvedBy);
      await updateLeave(updated);

      // Update Employee Balance
      // Note: We access the 'hr_employees' box directly here to avoid circular dependency
      // or complex dependency injection for this simple operation.
      try {
        final empBox = Hive.box<HREmployee>(
            'hr_employees'); // Ensure import alias matches if needed, but HREmployee is unique class name
        final employee =
            empBox.values.firstWhere((e) => e.id == leave.employeeId);

        final currentBalance = employee.getLeaveBalance(
            leave.leaveType.name); // Using name as key ('casual', 'earned')
        // Note: leave.leaveType is enum. leaveType.name returns 'casual', 'earned' which matches map keys

        final newBalance = currentBalance - leave.numberOfDays;
        final updatedEmp =
            employee.updateLeaveBalance(leave.leaveType.name, newBalance);

        await empBox.put(updatedEmp.id, updatedEmp);
      } catch (e) {
        // Handle case where employee not found or box not open.
        // Box should be open as per main.dart.
        AppLogger.error("Error updating leave balance", e);
      }
    }
  }

  Future<void> rejectLeave(
    String leaveId,
    String rejectedBy,
    String reason,
  ) async {
    final leave = getLeave(leaveId);
    if (leave != null) {
      final updated = leave.reject(rejectedBy, reason);
      await updateLeave(updated);
    }
  }

  Future<void> cancelLeave(String leaveId) async {
    final leave = getLeave(leaveId);
    if (leave != null) {
      final updated = leave.cancel();
      await updateLeave(updated);
    }
  }

  // Delete
  Future<void> deleteLeave(String id) async {
    await box.delete(id);
  }

  // Statistics
  double getTotalLeaveDays(String employeeId, int year) {
    return box.values
        .where(
          (leave) =>
              leave.employeeId == employeeId &&
              leave.status == LeaveStatus.approved &&
              leave.startDate.year == year,
        )
        .fold(0.0, (sum, leave) => sum + leave.numberOfDays);
  }

  double getLeaveDaysByType(String employeeId, LeaveType type, int year) {
    return box.values
        .where(
          (leave) =>
              leave.employeeId == employeeId &&
              leave.leaveType == type &&
              leave.status == LeaveStatus.approved &&
              leave.startDate.year == year,
        )
        .fold(0.0, (sum, leave) => sum + leave.numberOfDays);
  }

  int getPendingLeaveCount(String employeeId) {
    return box.values
        .where(
          (leave) =>
              leave.employeeId == employeeId &&
              leave.status == LeaveStatus.pending,
        )
        .length;
  }

  // Check for overlapping leaves
  bool hasOverlappingLeave(String employeeId, DateTime start, DateTime end) {
    return box.values.any((leave) {
      if (leave.employeeId != employeeId) {
        return false;
      }
      if (leave.status == LeaveStatus.rejected ||
          leave.status == LeaveStatus.cancelled) {
        return false;
      }

      return leave.startDate.isBefore(end.add(const Duration(days: 1))) &&
          leave.endDate.isAfter(start.subtract(const Duration(days: 1)));
    });
  }

  // Get leave balance for a specific type
  Map<LeaveType, double> getLeaveBalance(String employeeId, int year) {
    final balance = <LeaveType, double>{
      LeaveType.casual: 12.0,
      LeaveType.earned: 15.0,
      LeaveType.sick: 7.0,
    };

    for (var type in [LeaveType.casual, LeaveType.earned, LeaveType.sick]) {
      final used = getLeaveDaysByType(employeeId, type, year);
      balance[type] = (balance[type] ?? 0) - used;
    }

    return balance;
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await box.clear();
  }
}
