import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  static const String _boxName = 'attendance';

  Box<Attendance> get box => Hive.box<Attendance>(_boxName);

  // Create
  Future<void> addAttendance(Attendance attendance) async {
    await box.put(attendance.id, attendance);
  }

  // Read
  Attendance? getAttendance(String id) {
    return box.get(id);
  }

  List<Attendance> getAllAttendance() {
    return box.values.toList();
  }

  List<Attendance> getAttendanceByEmployee(String employeeId) {
    return box.values.where((att) => att.employeeId == employeeId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Attendance? getAttendanceByEmployeeAndDate(String employeeId, DateTime date) {
    return box.values.firstWhere(
      (att) =>
          att.employeeId == employeeId &&
          att.date.year == date.year &&
          att.date.month == date.month &&
          att.date.day == date.day,
      orElse: () => throw Exception('Attendance not found'),
    );
  }

  List<Attendance> getAttendanceByDateRange(
    String employeeId,
    DateTime start,
    DateTime end,
  ) {
    return box.values.where((att) {
      return att.employeeId == employeeId &&
          att.date.isAfter(start.subtract(const Duration(days: 1))) &&
          att.date.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Attendance> getMonthlyAttendance(
    String employeeId,
    int year,
    int month,
  ) {
    return box.values.where((att) {
      return att.employeeId == employeeId &&
          att.date.year == year &&
          att.date.month == month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Update
  Future<void> updateAttendance(Attendance attendance) async {
    await box.put(attendance.id, attendance);
  }

  Future<void> checkIn(String employeeId, DateTime date) async {
    try {
      final existing = getAttendanceByEmployeeAndDate(employeeId, date);
      if (existing != null) {
        final updated = existing.checkInNow();
        await updateAttendance(updated);
      }
    } catch (e) {
      // Create new attendance record
      final attendance = Attendance.create(
        employeeId: employeeId,
        date: date,
        checkIn: DateTime.now(),
      );
      await addAttendance(attendance);
    }
  }

  Future<void> checkOut(String employeeId, DateTime date) async {
    try {
      final attendance = getAttendanceByEmployeeAndDate(employeeId, date);
      if (attendance != null) {
        final updated = attendance.checkOutNow();
        await updateAttendance(updated);
      }
    } catch (e) {
      // Attendance not found
      throw Exception('No check-in record found for today');
    }
  }

  // Delete
  Future<void> deleteAttendance(String id) async {
    await box.delete(id);
  }

  // Statistics
  int getPresentDays(String employeeId, int year, int month) {
    return getMonthlyAttendance(
      employeeId,
      year,
      month,
    ).where((att) => att.status == AttendanceStatus.present).length;
  }

  int getAbsentDays(String employeeId, int year, int month) {
    return getMonthlyAttendance(
      employeeId,
      year,
      month,
    ).where((att) => att.status == AttendanceStatus.absent).length;
  }

  int getLateDays(String employeeId, int year, int month) {
    return getMonthlyAttendance(
      employeeId,
      year,
      month,
    ).where((att) => att.isLateArrival).length;
  }

  double getTotalWorkHours(String employeeId, int year, int month) {
    return getMonthlyAttendance(
      employeeId,
      year,
      month,
    ).fold(0.0, (sum, att) => sum + att.workHours);
  }

  double getTotalOvertimeHours(String employeeId, int year, int month) {
    return getMonthlyAttendance(
      employeeId,
      year,
      month,
    ).fold(0.0, (sum, att) => sum + att.overtimeHours);
  }

  double getAttendancePercentage(String employeeId, int year, int month) {
    final attendance = getMonthlyAttendance(employeeId, year, month);
    if (attendance.isEmpty) return 0.0;

    final presentDays = attendance
        .where((att) => att.status == AttendanceStatus.present)
        .length;
    final totalDays = attendance.length;

    return (presentDays / totalDays) * 100;
  }

  // Get today's attendance for all employees
  List<Attendance> getTodayAttendance() {
    final today = DateTime.now();
    return box.values.where((att) {
      return att.date.year == today.year &&
          att.date.month == today.month &&
          att.date.day == today.day;
    }).toList();
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await box.clear();
  }
}
