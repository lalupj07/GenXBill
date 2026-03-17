// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_theme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceThemeAdapter extends TypeAdapter<InvoiceTheme> {
  @override
  final int typeId = 80;

  @override
  InvoiceTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceTheme(
      id: fields[0] as String,
      name: fields[1] as String,
      style: fields[2] as InvoiceTemplateStyle,
      primaryColor: fields[3] as String,
      secondaryColor: fields[4] as String,
      accentColor: fields[5] as String,
      fontFamily: fields[6] as String,
      headerFontSize: fields[7] as double,
      bodyFontSize: fields[8] as double,
      showLogo: fields[9] as bool,
      showSignature: fields[10] as bool,
      showStamp: fields[11] as bool,
      showBorder: fields[12] as bool,
      borderColor: fields[13] as String,
      borderWidth: fields[14] as double,
      showWatermark: fields[15] as bool,
      watermarkText: fields[16] as String?,
      createdAt: fields[17] as DateTime,
      isDefault: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceTheme obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.style)
      ..writeByte(3)
      ..write(obj.primaryColor)
      ..writeByte(4)
      ..write(obj.secondaryColor)
      ..writeByte(5)
      ..write(obj.accentColor)
      ..writeByte(6)
      ..write(obj.fontFamily)
      ..writeByte(7)
      ..write(obj.headerFontSize)
      ..writeByte(8)
      ..write(obj.bodyFontSize)
      ..writeByte(9)
      ..write(obj.showLogo)
      ..writeByte(10)
      ..write(obj.showSignature)
      ..writeByte(11)
      ..write(obj.showStamp)
      ..writeByte(12)
      ..write(obj.showBorder)
      ..writeByte(13)
      ..write(obj.borderColor)
      ..writeByte(14)
      ..write(obj.borderWidth)
      ..writeByte(15)
      ..write(obj.showWatermark)
      ..writeByte(16)
      ..write(obj.watermarkText)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceTemplateStyleAdapter extends TypeAdapter<InvoiceTemplateStyle> {
  @override
  final int typeId = 81;

  @override
  InvoiceTemplateStyle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceTemplateStyle.modern;
      case 1:
        return InvoiceTemplateStyle.classic;
      case 2:
        return InvoiceTemplateStyle.minimal;
      case 3:
        return InvoiceTemplateStyle.corporate;
      case 4:
        return InvoiceTemplateStyle.colorful;
      case 5:
        return InvoiceTemplateStyle.custom;
      default:
        return InvoiceTemplateStyle.modern;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceTemplateStyle obj) {
    switch (obj) {
      case InvoiceTemplateStyle.modern:
        writer.writeByte(0);
        break;
      case InvoiceTemplateStyle.classic:
        writer.writeByte(1);
        break;
      case InvoiceTemplateStyle.minimal:
        writer.writeByte(2);
        break;
      case InvoiceTemplateStyle.corporate:
        writer.writeByte(3);
        break;
      case InvoiceTemplateStyle.colorful:
        writer.writeByte(4);
        break;
      case InvoiceTemplateStyle.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceTemplateStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
