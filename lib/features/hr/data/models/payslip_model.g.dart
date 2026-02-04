// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayslipAdapter extends TypeAdapter<Payslip> {
  @override
  final int typeId = 59;

  @override
  Payslip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payslip(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      employeeName: fields[2] as String,
      month: fields[3] as int,
      year: fields[4] as int,
      totalDaysInMonth: fields[5] as int,
      payableDays: fields[6] as double,
      presentDays: fields[7] as double,
      leaveDays: fields[8] as double,
      basicSalary: fields[9] as double,
      grossEarnings: fields[10] as double,
      totalDeductions: fields[11] as double,
      netSalary: fields[12] as double,
      pfDeduction: fields[13] as double,
      esiDeduction: fields[14] as double,
      tdsDeduction: fields[15] as double,
      professionalTax: fields[16] as double,
      status: fields[17] as PayslipStatus,
      generatedDate: fields[18] as DateTime,
      paymentDate: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Payslip obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.employeeName)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.totalDaysInMonth)
      ..writeByte(6)
      ..write(obj.payableDays)
      ..writeByte(7)
      ..write(obj.presentDays)
      ..writeByte(8)
      ..write(obj.leaveDays)
      ..writeByte(9)
      ..write(obj.basicSalary)
      ..writeByte(10)
      ..write(obj.grossEarnings)
      ..writeByte(11)
      ..write(obj.totalDeductions)
      ..writeByte(12)
      ..write(obj.netSalary)
      ..writeByte(13)
      ..write(obj.pfDeduction)
      ..writeByte(14)
      ..write(obj.esiDeduction)
      ..writeByte(15)
      ..write(obj.tdsDeduction)
      ..writeByte(16)
      ..write(obj.professionalTax)
      ..writeByte(17)
      ..write(obj.status)
      ..writeByte(18)
      ..write(obj.generatedDate)
      ..writeByte(19)
      ..write(obj.paymentDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayslipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PayslipStatusAdapter extends TypeAdapter<PayslipStatus> {
  @override
  final int typeId = 58;

  @override
  PayslipStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PayslipStatus.draft;
      case 1:
        return PayslipStatus.generated;
      case 2:
        return PayslipStatus.paid;
      default:
        return PayslipStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, PayslipStatus obj) {
    switch (obj) {
      case PayslipStatus.draft:
        writer.writeByte(0);
        break;
      case PayslipStatus.generated:
        writer.writeByte(1);
        break;
      case PayslipStatus.paid:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayslipStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
