// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceAdapter extends TypeAdapter<Attendance> {
  @override
  final int typeId = 43;

  @override
  Attendance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attendance(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      date: fields[2] as DateTime,
      checkIn: fields[3] as DateTime?,
      checkOut: fields[4] as DateTime?,
      status: fields[5] as AttendanceStatus,
      workHours: fields[6] as double,
      overtimeHours: fields[7] as double,
      notes: fields[8] as String,
      isLateArrival: fields[9] as bool,
      isEarlyDeparture: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Attendance obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.checkIn)
      ..writeByte(4)
      ..write(obj.checkOut)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.workHours)
      ..writeByte(7)
      ..write(obj.overtimeHours)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isLateArrival)
      ..writeByte(10)
      ..write(obj.isEarlyDeparture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceStatusAdapter extends TypeAdapter<AttendanceStatus> {
  @override
  final int typeId = 42;

  @override
  AttendanceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceStatus.present;
      case 1:
        return AttendanceStatus.absent;
      case 2:
        return AttendanceStatus.halfDay;
      case 3:
        return AttendanceStatus.leave;
      case 4:
        return AttendanceStatus.holiday;
      case 5:
        return AttendanceStatus.weekOff;
      default:
        return AttendanceStatus.present;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceStatus obj) {
    switch (obj) {
      case AttendanceStatus.present:
        writer.writeByte(0);
        break;
      case AttendanceStatus.absent:
        writer.writeByte(1);
        break;
      case AttendanceStatus.halfDay:
        writer.writeByte(2);
        break;
      case AttendanceStatus.leave:
        writer.writeByte(3);
        break;
      case AttendanceStatus.holiday:
        writer.writeByte(4);
        break;
      case AttendanceStatus.weekOff:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
