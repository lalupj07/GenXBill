// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HREmployeeAdapter extends TypeAdapter<HREmployee> {
  @override
  final int typeId = 41;

  @override
  HREmployee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HREmployee(
      id: fields[0] as String,
      employeeCode: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String,
      department: fields[5] as String,
      position: fields[6] as String,
      joinDate: fields[7] as DateTime,
      salary: fields[8] as double,
      status: fields[9] as EmployeeStatus,
      leaveBalances: (fields[10] as Map?)?.cast<String, double>(),
      address: fields[11] as String?,
      dateOfBirth: fields[12] as DateTime?,
      emergencyContactName: fields[13] as String?,
      emergencyContactPhone: fields[14] as String?,
      payrollSettings: fields[16] as PayrollSettings?,
      documents: (fields[17] as List).cast<EmployeeDocument>(),
    );
  }

  @override
  void write(BinaryWriter writer, HREmployee obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeCode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.department)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.joinDate)
      ..writeByte(8)
      ..write(obj.salary)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.leaveBalances)
      ..writeByte(11)
      ..write(obj.address)
      ..writeByte(12)
      ..write(obj.dateOfBirth)
      ..writeByte(13)
      ..write(obj.emergencyContactName)
      ..writeByte(14)
      ..write(obj.emergencyContactPhone)
      ..writeByte(16)
      ..write(obj.payrollSettings)
      ..writeByte(17)
      ..write(obj.documents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HREmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeStatusAdapter extends TypeAdapter<EmployeeStatus> {
  @override
  final int typeId = 40;

  @override
  EmployeeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmployeeStatus.active;
      case 1:
        return EmployeeStatus.inactive;
      default:
        return EmployeeStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, EmployeeStatus obj) {
    switch (obj) {
      case EmployeeStatus.active:
        writer.writeByte(0);
        break;
      case EmployeeStatus.inactive:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
