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
      case 6:
        return InvoiceTemplate.professional;
      case 7:
        return InvoiceTemplate.executive;
      case 8:
        return InvoiceTemplate.corporate;
      case 9:
        return InvoiceTemplate.elegant;
      case 10:
        return InvoiceTemplate.standard;
      case 11:
        return InvoiceTemplate.enterprise;
      case 12:
        return InvoiceTemplate.compact;
      case 13:
        return InvoiceTemplate.detailed;
      case 14:
        return InvoiceTemplate.retail;
      case 15:
        return InvoiceTemplate.service;
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
      case InvoiceTemplate.professional:
        writer.writeByte(6);
        break;
      case InvoiceTemplate.executive:
        writer.writeByte(7);
        break;
      case InvoiceTemplate.corporate:
        writer.writeByte(8);
        break;
      case InvoiceTemplate.elegant:
        writer.writeByte(9);
        break;
      case InvoiceTemplate.standard:
        writer.writeByte(10);
        break;
      case InvoiceTemplate.enterprise:
        writer.writeByte(11);
        break;
      case InvoiceTemplate.compact:
        writer.writeByte(12);
        break;
      case InvoiceTemplate.detailed:
        writer.writeByte(13);
        break;
      case InvoiceTemplate.retail:
        writer.writeByte(14);
        break;
      case InvoiceTemplate.service:
        writer.writeByte(15);
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
