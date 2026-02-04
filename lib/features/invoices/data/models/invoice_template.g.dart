// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceTemplateAdapter extends TypeAdapter<InvoiceTemplate> {
  @override
  final int typeId = 9;

  @override
  InvoiceTemplate read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceTemplate.modern;
      case 1:
        return InvoiceTemplate.classic;
      case 2:
        return InvoiceTemplate.minimal;
      case 3:
        return InvoiceTemplate.bold;
      case 4:
        return InvoiceTemplate.gst;
      case 5:
        return InvoiceTemplate.creative;
      default:
        return InvoiceTemplate.modern;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceTemplate obj) {
    switch (obj) {
      case InvoiceTemplate.modern:
        writer.writeByte(0);
        break;
      case InvoiceTemplate.classic:
        writer.writeByte(1);
        break;
      case InvoiceTemplate.minimal:
        writer.writeByte(2);
        break;
      case InvoiceTemplate.bold:
        writer.writeByte(3);
        break;
      case InvoiceTemplate.gst:
        writer.writeByte(4);
        break;
      case InvoiceTemplate.creative:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
