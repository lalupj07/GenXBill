import 'package:hive/hive.dart';

part 'leave_model.g.dart';

@HiveType(typeId: 44)
enum LeaveType {
  @HiveField(0)
  casual,
  @HiveField(1)
  earned,
  @HiveField(2)
  sick,
  @HiveField(3)
  compOff,
  @HiveField(4)
  lossOfPay,
  @HiveField(5)
  maternity,
  @HiveField(6)
  paternity,
  @HiveField(7)
  optional,
}

@HiveType(typeId: 45)
enum LeaveStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 46)
class Leave extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final LeaveType leaveType;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final double numberOfDays;

  @HiveField(6)
  final String reason;

  @HiveField(7)
  final LeaveStatus status;

  @HiveField(8)
  final DateTime appliedDate;

  @HiveField(9)
  final String? approvedBy;

  @HiveField(10)
  final DateTime? approvalDate;

  @HiveField(11)
  final String? rejectionReason;

  @HiveField(12)
  final bool isHalfDay;

  Leave({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    required this.appliedDate,
    this.approvedBy,
    this.approvalDate,
    this.rejectionReason,
    this.isHalfDay = false,
  });

  factory Leave.create({
    required String employeeId,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
  }) {
    final numberOfDays = _calculateLeaveDays(startDate, endDate, isHalfDay);

    return Leave(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      numberOfDays: numberOfDays,
      reason: reason,
      appliedDate: DateTime.now(),
      isHalfDay: isHalfDay,
    );
  }

  static double _calculateLeaveDays(
      DateTime start, DateTime end, bool isHalfDay) {
    if (isHalfDay) return 0.5;

    int days = 0;
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        days++;
      }
      current = current.add(const Duration(days: 1));
    }

    return days.toDouble();
  }

  Leave approve(String approvedBy) {
    return copyWith(
      status: LeaveStatus.approved,
      approvedBy: approvedBy,
      approvalDate: DateTime.now(),
    );
  }

  Leave reject(String rejectedBy, String reason) {
    return copyWith(
      status: LeaveStatus.rejected,
      approvedBy: rejectedBy,
      approvalDate: DateTime.now(),
      rejectionReason: reason,
    );
  }

  Leave cancel() {
    return copyWith(status: LeaveStatus.cancelled);
  }

  Leave copyWith({
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    double? numberOfDays,
    String? reason,
    LeaveStatus? status,
    String? approvedBy,
    DateTime? approvalDate,
    String? rejectionReason,
    bool? isHalfDay,
  }) {
    return Leave(
      id: id,
      employeeId: employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isHalfDay: isHalfDay ?? this.isHalfDay,
    );
  }

  String get leaveTypeName {
    switch (leaveType) {
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.earned:
        return 'Earned Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.compOff:
        return 'Compensatory Off';
      case LeaveType.lossOfPay:
        return 'Loss of Pay';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.optional:
        return 'Optional Holiday';
    }
  }
}
