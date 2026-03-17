import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/employee_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/leave_repository.dart';
import '../data/repositories/hr_repositories.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart';
import 'package:genx_bill/features/hr/data/models/attendance_model.dart';

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

// --- Reactive Stream Providers ---

final employeesStreamProvider = StreamProvider<List<HREmployee>>((ref) {
  final box = ref.watch(employeeRepositoryProvider).box;
  return box.watch().map((_) => box.values.toList());
});

final attendanceStreamProvider = StreamProvider<List<Attendance>>((ref) {
  final box = ref.watch(attendanceRepositoryProvider).box;
  return box.watch().map((_) => box.values.toList());
});

// --- Computed Providers (Synchronous for easier UI usage) ---

final attendanceProvider = Provider<List<Attendance>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  // Watch the stream to trigger rebuilds, but return current values immediately
  ref.watch(attendanceStreamProvider);
  return repo.box.values.toList();
});

final allEmployeesProvider = Provider<List<HREmployee>>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  // Watch the stream to trigger rebuilds
  ref.watch(employeesStreamProvider);
  return repo.box.values.toList();
});

final activeEmployeesProvider = Provider<List<HREmployee>>((ref) {
  final employees = ref.watch(allEmployeesProvider);
  return employees.where((emp) => emp.status == EmployeeStatus.active).toList();
});

final pendingLeavesProvider = Provider((ref) {
  final repo = ref.watch(leaveRepositoryProvider);
  // We should ideally have a stream for leaves too, but let's start with these.
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
  final employees = ref.watch(allEmployeesProvider);
  final attendance = ref.watch(attendanceProvider);
  final leaveRepo = ref.watch(leaveRepositoryProvider);

  final today = DateTime.now();
  final todayPresent = attendance
      .where((att) =>
          att.date.year == today.year &&
          att.date.month == today.month &&
          att.date.day == today.day)
      .length;

  return {
    'totalEmployees': employees.length,
    'activeEmployees':
        employees.where((e) => e.status == EmployeeStatus.active).length,
    'pendingLeaves':
        leaveRepo.getPendingLeaves().length, // Not yet reactive to box changes
    'todayPresent': todayPresent,
  };
});
