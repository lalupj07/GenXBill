import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 54)
class SalaryRecord extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String employeeId;
  @HiveField(2)
  final DateTime payDate;
  @HiveField(3)
  final double basicSalary;
  @HiveField(4)
  final double bonuses;
  @HiveField(5)
  final double deductions;
  @HiveField(6)
  final String? notes;
  @HiveField(7)
  final String paymentMethod; // Cash, Bank Transfer, etc.

  SalaryRecord({
    required this.id,
    required this.employeeId,
    required this.payDate,
    required this.basicSalary,
    this.bonuses = 0.0,
    this.deductions = 0.0,
    this.notes,
    this.paymentMethod = 'Bank Transfer',
  });

  double get netSalary => basicSalary + bonuses - deductions;

  factory SalaryRecord.create({
    required String employeeId,
    required double basicSalary,
    double bonuses = 0.0,
    double deductions = 0.0,
    String? notes,
    required String paymentMethod,
  }) {
    return SalaryRecord(
      id: const Uuid().v4(),
      employeeId: employeeId,
      payDate: DateTime.now(),
      basicSalary: basicSalary,
      bonuses: bonuses,
      deductions: deductions,
      notes: notes,
      paymentMethod: paymentMethod,
    );
  }
}

class SalaryRecordAdapter extends TypeAdapter<SalaryRecord> {
  @override
  final int typeId = 54;

  @override
  SalaryRecord read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return SalaryRecord(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      payDate: fields[2] as DateTime,
      basicSalary: fields[3] as double,
      bonuses: fields[4] as double? ?? 0.0,
      deductions: fields[5] as double? ?? 0.0,
      notes: fields[6] as String?,
      paymentMethod: fields[7] as String? ?? 'Bank Transfer',
    );
  }

  @override
  void write(BinaryWriter writer, SalaryRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.payDate)
      ..writeByte(3)
      ..write(obj.basicSalary)
      ..writeByte(4)
      ..write(obj.bonuses)
      ..writeByte(5)
      ..write(obj.deductions)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.paymentMethod);
  }
}
