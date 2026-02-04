// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OvertimeAdapter extends TypeAdapter<Overtime> {
  @override
  final int typeId = 51;

  @override
  Overtime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Overtime(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      date: fields[2] as DateTime,
      hours: fields[3] as double,
      rate: fields[4] as double,
      amount: fields[5] as double,
      reason: fields[6] as String,
      status: fields[7] as OvertimeStatus,
      appliedDate: fields[8] as DateTime,
      approvedBy: fields[9] as String?,
      approvalDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Overtime obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.hours)
      ..writeByte(4)
      ..write(obj.rate)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.appliedDate)
      ..writeByte(9)
      ..write(obj.approvedBy)
      ..writeByte(10)
      ..write(obj.approvalDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvertimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OvertimeStatusAdapter extends TypeAdapter<OvertimeStatus> {
  @override
  final int typeId = 50;

  @override
  OvertimeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OvertimeStatus.pending;
      case 1:
        return OvertimeStatus.approved;
      case 2:
        return OvertimeStatus.rejected;
      default:
        return OvertimeStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OvertimeStatus obj) {
    switch (obj) {
      case OvertimeStatus.pending:
        writer.writeByte(0);
        break;
      case OvertimeStatus.approved:
        writer.writeByte(1);
        break;
      case OvertimeStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvertimeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
