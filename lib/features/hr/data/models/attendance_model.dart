import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 42)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  halfDay,
  @HiveField(3)
  leave,
  @HiveField(4)
  holiday,
  @HiveField(5)
  weekOff,
}

@HiveType(typeId: 43)
class Attendance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final DateTime? checkIn;

  @HiveField(4)
  final DateTime? checkOut;

  @HiveField(5)
  final AttendanceStatus status;

  @HiveField(6)
  final double workHours;

  @HiveField(7)
  final double overtimeHours;

  @HiveField(8)
  final String notes;

  @HiveField(9)
  final bool isLateArrival;

  @HiveField(10)
  final bool isEarlyDeparture;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workHours = 0.0,
    this.overtimeHours = 0.0,
    this.notes = '',
    this.isLateArrival = false,
    this.isEarlyDeparture = false,
  });

  factory Attendance.create({
    required String employeeId,
    required DateTime date,
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    String notes = '',
  }) {
    final workHours = _calculateWorkHours(checkIn, checkOut);
    final overtimeHours = _calculateOvertimeHours(workHours);
    final isLate = _isLateArrival(checkIn);
    final isEarly = _isEarlyDeparture(checkOut);

    return Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      status: status ??
          (checkIn != null
              ? AttendanceStatus.present
              : AttendanceStatus.absent),
      workHours: workHours,
      overtimeHours: overtimeHours,
      notes: notes,
      isLateArrival: isLate,
      isEarlyDeparture: isEarly,
    );
  }

  static double _calculateWorkHours(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) return 0.0;
    final duration = checkOut.difference(checkIn);
    return duration.inMinutes / 60.0;
  }

  static double _calculateOvertimeHours(double workHours) {
    const standardHours = 8.0;
    return workHours > standardHours ? workHours - standardHours : 0.0;
  }

  static bool _isLateArrival(DateTime? checkIn) {
    if (checkIn == null) return false;
    // Consider late if check-in is after 9:30 AM
    final lateTime = DateTime(checkIn.year, checkIn.month, checkIn.day, 9, 30);
    return checkIn.isAfter(lateTime);
  }

  static bool _isEarlyDeparture(DateTime? checkOut) {
    if (checkOut == null) return false;
    // Consider early if check-out is before 5:30 PM
    final earlyTime =
        DateTime(checkOut.year, checkOut.month, checkOut.day, 17, 30);
    return checkOut.isBefore(earlyTime);
  }

  Attendance copyWith({
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    double? workHours,
    double? overtimeHours,
    String? notes,
    bool? isLateArrival,
    bool? isEarlyDeparture,
  }) {
    return Attendance(
      id: id,
      employeeId: employeeId,
      date: date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      workHours: workHours ?? this.workHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      notes: notes ?? this.notes,
      isLateArrival: isLateArrival ?? this.isLateArrival,
      isEarlyDeparture: isEarlyDeparture ?? this.isEarlyDeparture,
    );
  }

  Attendance checkInNow() {
    final now = DateTime.now();
    final workHours = _calculateWorkHours(now, checkOut);
    final overtimeHours = _calculateOvertimeHours(workHours);

    return copyWith(
      checkIn: now,
      status: AttendanceStatus.present,
      workHours: workHours,
      overtimeHours: overtimeHours,
      isLateArrival: _isLateArrival(now),
    );
  }

  Attendance checkOutNow() {
    final now = DateTime.now();
    final workHours = _calculateWorkHours(checkIn, now);
    final overtimeHours = _calculateOvertimeHours(workHours);

    return copyWith(
      checkOut: now,
      workHours: workHours,
      overtimeHours: overtimeHours,
      isEarlyDeparture: _isEarlyDeparture(now),
    );
  }
}
