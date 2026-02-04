import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:genx_bill/features/hr/data/models/payroll_settings.dart';
import 'package:genx_bill/features/hr/data/models/employee_document.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 40)
enum EmployeeStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
}

@HiveType(typeId: 41)
class HREmployee extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeCode;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String department;

  @HiveField(6)
  final String position;

  @HiveField(7)
  final DateTime joinDate;

  @HiveField(8)
  final double salary;

  @HiveField(9)
  final EmployeeStatus status;

  @HiveField(10)
  final Map<String, double> leaveBalances; // LeaveType -> Balance

  @HiveField(11)
  final String? address;

  @HiveField(12)
  final DateTime? dateOfBirth;

  @HiveField(13)
  final String? emergencyContactName;

  @HiveField(14)
  final String? emergencyContactPhone;

  // New Enhanced Fields
  @HiveField(16)
  final PayrollSettings? payrollSettings;

  @HiveField(17)
  final List<EmployeeDocument> documents;

  HREmployee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.joinDate,
    required this.salary,
    this.status = EmployeeStatus.active,
    Map<String, double>? leaveBalances,
    this.address,
    this.dateOfBirth,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.payrollSettings,
    this.documents = const [],
  }) : leaveBalances =
            leaveBalances ?? {'casual': 12.0, 'earned': 15.0, 'sick': 7.0};

  factory HREmployee.create({
    required String employeeCode,
    required String name,
    required String email,
    required String phone,
    required String department,
    required String position,
    required DateTime joinDate,
    required double salary,
    String? address,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return HREmployee(
      id: const Uuid().v4(),
      employeeCode: employeeCode,
      name: name,
      email: email,
      phone: phone,
      department: department,
      position: position,
      joinDate: joinDate,
      salary: salary,
      address: address,
      dateOfBirth: dateOfBirth,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      payrollSettings: PayrollSettings(),
    );
  }

  HREmployee copyWith({
    String? employeeCode,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? position,
    DateTime? joinDate,
    double? salary,
    EmployeeStatus? status,
    Map<String, double>? leaveBalances,
    String? address,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
    PayrollSettings? payrollSettings,
    List<EmployeeDocument>? documents,
  }) {
    return HREmployee(
      id: id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      leaveBalances: leaveBalances ?? this.leaveBalances,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      payrollSettings: payrollSettings ?? this.payrollSettings,
      documents: documents ?? this.documents,
    );
  }

  double getLeaveBalance(String leaveType) {
    return leaveBalances[leaveType] ?? 0.0;
  }

  HREmployee updateLeaveBalance(String leaveType, double balance) {
    final newBalances = Map<String, double>.from(leaveBalances);
    newBalances[leaveType] = balance;
    return copyWith(leaveBalances: newBalances);
  }
}
