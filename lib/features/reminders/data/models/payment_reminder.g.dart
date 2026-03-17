// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentReminderAdapter extends TypeAdapter<PaymentReminder> {
  @override
  final int typeId = 82;

  @override
  PaymentReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentReminder(
      id: fields[0] as String,
      invoiceId: fields[1] as String,
      clientName: fields[2] as String,
      dueDate: fields[3] as DateTime,
      amount: fields[4] as double,
      schedules: (fields[5] as List).cast<ReminderSchedule>(),
      sendEmail: fields[6] as bool,
      sendWhatsApp: fields[7] as bool,
      customMessage: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      logs: (fields[10] as List).cast<ReminderLog>(),
      isActive: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentReminder obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceId)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.schedules)
      ..writeByte(6)
      ..write(obj.sendEmail)
      ..writeByte(7)
      ..write(obj.sendWhatsApp)
      ..writeByte(8)
      ..write(obj.customMessage)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.logs)
      ..writeByte(11)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderScheduleAdapter extends TypeAdapter<ReminderSchedule> {
  @override
  final int typeId = 83;

  @override
  ReminderSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderSchedule(
      daysBeforeDue: fields[0] as int,
      daysAfterDue: fields[1] as int,
      type: fields[2] as ReminderType,
      sent: fields[3] as bool,
      sentAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderSchedule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.daysBeforeDue)
      ..writeByte(1)
      ..write(obj.daysAfterDue)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.sent)
      ..writeByte(4)
      ..write(obj.sentAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderLogAdapter extends TypeAdapter<ReminderLog> {
  @override
  final int typeId = 85;

  @override
  ReminderLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderLog(
      sentAt: fields[0] as DateTime,
      type: fields[1] as ReminderType,
      channel: fields[2] as String,
      success: fields[3] as bool,
      errorMessage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sentAt)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.channel)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 84;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.friendly;
      case 1:
        return ReminderType.dueDate;
      case 2:
        return ReminderType.overdue;
      case 3:
        return ReminderType.finalReminder;
      default:
        return ReminderType.friendly;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.friendly:
        writer.writeByte(0);
        break;
      case ReminderType.dueDate:
        writer.writeByte(1);
        break;
      case ReminderType.overdue:
        writer.writeByte(2);
        break;
      case ReminderType.finalReminder:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
