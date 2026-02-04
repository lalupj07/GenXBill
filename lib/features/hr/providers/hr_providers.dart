import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/employee_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/leave_repository.dart';
import '../data/repositories/hr_repositories.dart';
import '../data/models/employee_model.dart';

// Repository Providers
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

final overtimeRepositoryProvider = Provider<OvertimeRepository>((ref) {
  return OvertimeRepository();
});

final bonusRepositoryProvider = Provider<BonusRepository>((ref) {
  return BonusRepository();
});

final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  return HolidayRepository();
});

// State Providers for UI
final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Computed Providers
final activeEmployeesProvider = Provider<List<HREmployee>>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getActiveEmployees();
});

final allEmployeesProvider = Provider<List<HREmployee>>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getAllEmployees();
});

final pendingLeavesProvider = Provider((ref) {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getPendingLeaves();
});

final pendingOvertimeProvider = Provider((ref) {
  final repo = ref.watch(overtimeRepositoryProvider);
  return repo.getPendingOvertime();
});

final pendingBonusesProvider = Provider((ref) {
  final repo = ref.watch(bonusRepositoryProvider);
  return repo.getPendingBonuses();
});

final upcomingHolidaysProvider = Provider((ref) {
  final repo = ref.watch(holidayRepositoryProvider);
  return repo.getUpcomingHolidays();
});

// Dashboard Statistics Provider
final hrDashboardStatsProvider = Provider((ref) {
  final employeeRepo = ref.watch(employeeRepositoryProvider);
  final leaveRepo = ref.watch(leaveRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);

  return {
    'totalEmployees': employeeRepo.getTotalEmployees(),
    'activeEmployees': employeeRepo.getActiveEmployeesCount(),
    'pendingLeaves': leaveRepo.getPendingLeaves().length,
    'todayPresent': attendanceRepo.getTodayAttendance().length,
  };
});
