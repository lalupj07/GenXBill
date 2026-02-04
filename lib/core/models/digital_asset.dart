import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 32)
class DigitalAsset extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fileName;
  @HiveField(2)
  final String filePath; // Local path or Base64 (prefer local path for desktop)
  @HiveField(3)
  final String
      category; // 'Purchase Bill', 'Receipt', 'Warranty', 'Stamp', 'Signature'
  @HiveField(4)
  final String? linkedId; // ID of Invoice, Expense, Product, etc.
  @HiveField(5)
  final DateTime uploadedAt;

  DigitalAsset({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.category,
    this.linkedId,
    required this.uploadedAt,
  });

  factory DigitalAsset.create({
    required String fileName,
    required String filePath,
    required String category,
    String? linkedId,
  }) {
    return DigitalAsset(
      id: const Uuid().v4(),
      fileName: fileName,
      filePath: filePath,
      category: category,
      linkedId: linkedId,
      uploadedAt: DateTime.now(),
    );
  }
}

class DigitalAssetAdapter extends TypeAdapter<DigitalAsset> {
  @override
  final int typeId = 32;

  @override
  DigitalAsset read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return DigitalAsset(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      category: fields[3] as String,
      linkedId: fields[4] as String?,
      uploadedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DigitalAsset obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.linkedId)
      ..writeByte(5)
      ..write(obj.uploadedAt);
  }
}
