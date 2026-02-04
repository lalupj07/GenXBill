// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayrollSettingsAdapter extends TypeAdapter<PayrollSettings> {
  @override
  final int typeId = 55;

  @override
  PayrollSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PayrollSettings(
      pfPercentage: fields[0] as double,
      esiPercentage: fields[1] as double,
      tdsPercentage: fields[2] as double,
      professionalTax: fields[3] as double,
      enablePF: fields[4] as bool,
      enableESI: fields[5] as bool,
      bankName: fields[6] as String?,
      accountNumber: fields[7] as String?,
      ifscCode: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PayrollSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.pfPercentage)
      ..writeByte(1)
      ..write(obj.esiPercentage)
      ..writeByte(2)
      ..write(obj.tdsPercentage)
      ..writeByte(3)
      ..write(obj.professionalTax)
      ..writeByte(4)
      ..write(obj.enablePF)
      ..writeByte(5)
      ..write(obj.enableESI)
      ..writeByte(6)
      ..write(obj.bankName)
      ..writeByte(7)
      ..write(obj.accountNumber)
      ..writeByte(8)
      ..write(obj.ifscCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayrollSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
