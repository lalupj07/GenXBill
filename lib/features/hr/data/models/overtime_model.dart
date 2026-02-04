import 'package:hive/hive.dart';

part 'overtime_model.g.dart';

@HiveType(typeId: 50)
enum OvertimeStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}

@HiveType(typeId: 51)
class Overtime extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double hours;

  @HiveField(4)
  final double rate; // Multiplier (e.g., 1.5x, 2.0x)

  @HiveField(5)
  final double amount;

  @HiveField(6)
  final String reason;

  @HiveField(7)
  final OvertimeStatus status;

  @HiveField(8)
  final DateTime appliedDate;

  @HiveField(9)
  final String? approvedBy;

  @HiveField(10)
  final DateTime? approvalDate;

  Overtime({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.hours,
    required this.rate,
    required this.amount,
    required this.reason,
    this.status = OvertimeStatus.pending,
    required this.appliedDate,
    this.approvedBy,
    this.approvalDate,
  });

  factory Overtime.create({
    required String employeeId,
    required DateTime date,
    required double hours,
    required double hourlyRate,
    double multiplier = 1.5,
    required String reason,
  }) {
    final amount = hours * hourlyRate * multiplier;

    return Overtime(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      date: date,
      hours: hours,
      rate: multiplier,
      amount: amount,
      reason: reason,
      appliedDate: DateTime.now(),
    );
  }

  Overtime approve(String approvedBy) {
    return copyWith(
      status: OvertimeStatus.approved,
      approvedBy: approvedBy,
      approvalDate: DateTime.now(),
    );
  }

  Overtime reject(String rejectedBy) {
    return copyWith(
      status: OvertimeStatus.rejected,
      approvedBy: rejectedBy,
      approvalDate: DateTime.now(),
    );
  }

  Overtime copyWith({
    DateTime? date,
    double? hours,
    double? rate,
    double? amount,
    String? reason,
    OvertimeStatus? status,
    String? approvedBy,
    DateTime? approvalDate,
  }) {
    return Overtime(
      id: id,
      employeeId: employeeId,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }
}
