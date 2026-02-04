// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BonusAdapter extends TypeAdapter<Bonus> {
  @override
  final int typeId = 49;

  @override
  Bonus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bonus(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      bonusType: fields[2] as BonusType,
      amount: fields[3] as double,
      month: fields[4] as DateTime,
      reason: fields[5] as String,
      status: fields[6] as BonusStatus,
      createdDate: fields[7] as DateTime,
      approvedBy: fields[8] as String?,
      approvalDate: fields[9] as DateTime?,
      paidDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Bonus obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.bonusType)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.month)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdDate)
      ..writeByte(8)
      ..write(obj.approvedBy)
      ..writeByte(9)
      ..write(obj.approvalDate)
      ..writeByte(10)
      ..write(obj.paidDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BonusTypeAdapter extends TypeAdapter<BonusType> {
  @override
  final int typeId = 47;

  @override
  BonusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BonusType.performance;
      case 1:
        return BonusType.festival;
      case 2:
        return BonusType.attendance;
      case 3:
        return BonusType.referral;
      case 4:
        return BonusType.projectCompletion;
      case 5:
        return BonusType.annual;
      case 6:
        return BonusType.custom;
      default:
        return BonusType.performance;
    }
  }

  @override
  void write(BinaryWriter writer, BonusType obj) {
    switch (obj) {
      case BonusType.performance:
        writer.writeByte(0);
        break;
      case BonusType.festival:
        writer.writeByte(1);
        break;
      case BonusType.attendance:
        writer.writeByte(2);
        break;
      case BonusType.referral:
        writer.writeByte(3);
        break;
      case BonusType.projectCompletion:
        writer.writeByte(4);
        break;
      case BonusType.annual:
        writer.writeByte(5);
        break;
      case BonusType.custom:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BonusStatusAdapter extends TypeAdapter<BonusStatus> {
  @override
  final int typeId = 48;

  @override
  BonusStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BonusStatus.pending;
      case 1:
        return BonusStatus.approved;
      case 2:
        return BonusStatus.paid;
      case 3:
        return BonusStatus.rejected;
      default:
        return BonusStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BonusStatus obj) {
    switch (obj) {
      case BonusStatus.pending:
        writer.writeByte(0);
        break;
      case BonusStatus.approved:
        writer.writeByte(1);
        break;
      case BonusStatus.paid:
        writer.writeByte(2);
        break;
      case BonusStatus.rejected:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
