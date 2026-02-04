import 'package:hive/hive.dart';

part 'bonus_model.g.dart';

@HiveType(typeId: 47)
enum BonusType {
  @HiveField(0)
  performance,
  @HiveField(1)
  festival,
  @HiveField(2)
  attendance,
  @HiveField(3)
  referral,
  @HiveField(4)
  projectCompletion,
  @HiveField(5)
  annual,
  @HiveField(6)
  custom,
}

@HiveType(typeId: 48)
enum BonusStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  paid,
  @HiveField(3)
  rejected,
}

@HiveType(typeId: 49)
class Bonus extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final BonusType bonusType;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime month;

  @HiveField(5)
  final String reason;

  @HiveField(6)
  final BonusStatus status;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  final String? approvedBy;

  @HiveField(9)
  final DateTime? approvalDate;

  @HiveField(10)
  final DateTime? paidDate;

  Bonus({
    required this.id,
    required this.employeeId,
    required this.bonusType,
    required this.amount,
    required this.month,
    required this.reason,
    this.status = BonusStatus.pending,
    required this.createdDate,
    this.approvedBy,
    this.approvalDate,
    this.paidDate,
  });

  factory Bonus.create({
    required String employeeId,
    required BonusType bonusType,
    required double amount,
    required DateTime month,
    required String reason,
  }) {
    return Bonus(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      bonusType: bonusType,
      amount: amount,
      month: month,
      reason: reason,
      createdDate: DateTime.now(),
    );
  }

  Bonus approve(String approvedBy) {
    return copyWith(
      status: BonusStatus.approved,
      approvedBy: approvedBy,
      approvalDate: DateTime.now(),
    );
  }

  Bonus markAsPaid() {
    return copyWith(
      status: BonusStatus.paid,
      paidDate: DateTime.now(),
    );
  }

  Bonus reject(String rejectedBy) {
    return copyWith(
      status: BonusStatus.rejected,
      approvedBy: rejectedBy,
      approvalDate: DateTime.now(),
    );
  }

  Bonus copyWith({
    BonusType? bonusType,
    double? amount,
    DateTime? month,
    String? reason,
    BonusStatus? status,
    String? approvedBy,
    DateTime? approvalDate,
    DateTime? paidDate,
  }) {
    return Bonus(
      id: id,
      employeeId: employeeId,
      bonusType: bonusType ?? this.bonusType,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdDate: createdDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  String get bonusTypeName {
    switch (bonusType) {
      case BonusType.performance:
        return 'Performance Bonus';
      case BonusType.festival:
        return 'Festival Bonus';
      case BonusType.attendance:
        return 'Attendance Bonus';
      case BonusType.referral:
        return 'Referral Bonus';
      case BonusType.projectCompletion:
        return 'Project Completion Bonus';
      case BonusType.annual:
        return 'Annual Bonus';
      case BonusType.custom:
        return 'Custom Bonus';
    }
  }
}
