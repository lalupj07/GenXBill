// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveAdapter extends TypeAdapter<Leave> {
  @override
  final int typeId = 46;

  @override
  Leave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leave(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      leaveType: fields[2] as LeaveType,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      numberOfDays: fields[5] as double,
      reason: fields[6] as String,
      status: fields[7] as LeaveStatus,
      appliedDate: fields[8] as DateTime,
      approvedBy: fields[9] as String?,
      approvalDate: fields[10] as DateTime?,
      rejectionReason: fields[11] as String?,
      isHalfDay: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Leave obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.leaveType)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.numberOfDays)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.appliedDate)
      ..writeByte(9)
      ..write(obj.approvedBy)
      ..writeByte(10)
      ..write(obj.approvalDate)
      ..writeByte(11)
      ..write(obj.rejectionReason)
      ..writeByte(12)
      ..write(obj.isHalfDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LeaveTypeAdapter extends TypeAdapter<LeaveType> {
  @override
  final int typeId = 44;

  @override
  LeaveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveType.casual;
      case 1:
        return LeaveType.earned;
      case 2:
        return LeaveType.sick;
      case 3:
        return LeaveType.compOff;
      case 4:
        return LeaveType.lossOfPay;
      case 5:
        return LeaveType.maternity;
      case 6:
        return LeaveType.paternity;
      case 7:
        return LeaveType.optional;
      default:
        return LeaveType.casual;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveType obj) {
    switch (obj) {
      case LeaveType.casual:
        writer.writeByte(0);
        break;
      case LeaveType.earned:
        writer.writeByte(1);
        break;
      case LeaveType.sick:
        writer.writeByte(2);
        break;
      case LeaveType.compOff:
        writer.writeByte(3);
        break;
      case LeaveType.lossOfPay:
        writer.writeByte(4);
        break;
      case LeaveType.maternity:
        writer.writeByte(5);
        break;
      case LeaveType.paternity:
        writer.writeByte(6);
        break;
      case LeaveType.optional:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LeaveStatusAdapter extends TypeAdapter<LeaveStatus> {
  @override
  final int typeId = 45;

  @override
  LeaveStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveStatus.pending;
      case 1:
        return LeaveStatus.approved;
      case 2:
        return LeaveStatus.rejected;
      case 3:
        return LeaveStatus.cancelled;
      default:
        return LeaveStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveStatus obj) {
    switch (obj) {
      case LeaveStatus.pending:
        writer.writeByte(0);
        break;
      case LeaveStatus.approved:
        writer.writeByte(1);
        break;
      case LeaveStatus.rejected:
        writer.writeByte(2);
        break;
      case LeaveStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
