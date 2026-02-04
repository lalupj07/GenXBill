// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeDocumentAdapter extends TypeAdapter<EmployeeDocument> {
  @override
  final int typeId = 57;

  @override
  EmployeeDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmployeeDocument(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as DocumentType,
      filePath: fields[3] as String,
      uploadDate: fields[4] as DateTime,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmployeeDocument obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.uploadDate)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 56;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.idProof;
      case 1:
        return DocumentType.certificate;
      case 2:
        return DocumentType.contract;
      case 3:
        return DocumentType.other;
      default:
        return DocumentType.idProof;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.idProof:
        writer.writeByte(0);
        break;
      case DocumentType.certificate:
        writer.writeByte(1);
        break;
      case DocumentType.contract:
        writer.writeByte(2);
        break;
      case DocumentType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
