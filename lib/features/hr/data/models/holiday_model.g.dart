// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HolidayAdapter extends TypeAdapter<Holiday> {
  @override
  final int typeId = 53;

  @override
  Holiday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Holiday(
      id: fields[0] as String,
      name: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as HolidayType,
      isOptional: fields[4] as bool,
      description: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isOptional)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HolidayTypeAdapter extends TypeAdapter<HolidayType> {
  @override
  final int typeId = 52;

  @override
  HolidayType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HolidayType.public;
      case 1:
        return HolidayType.optional;
      case 2:
        return HolidayType.company;
      default:
        return HolidayType.public;
    }
  }

  @override
  void write(BinaryWriter writer, HolidayType obj) {
    switch (obj) {
      case HolidayType.public:
        writer.writeByte(0);
        break;
      case HolidayType.optional:
        writer.writeByte(1);
        break;
      case HolidayType.company:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
