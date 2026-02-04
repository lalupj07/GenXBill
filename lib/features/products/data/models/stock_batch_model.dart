import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 12)
class StockBatch extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final String warehouseId;
  @HiveField(3)
  final String batchNumber;
  @HiveField(4)
  final String? serialNumber;
  @HiveField(5)
  final double quantity;
  @HiveField(6)
  final DateTime? expiryDate;
  @HiveField(7)
  final DateTime receivedDate;

  StockBatch({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.batchNumber,
    this.serialNumber,
    required this.quantity,
    this.expiryDate,
    required this.receivedDate,
  });

  factory StockBatch.create({
    required String productId,
    required String warehouseId,
    required String batchNumber,
    String? serialNumber,
    required double quantity,
    DateTime? expiryDate,
  }) {
    return StockBatch(
      id: const Uuid().v4(),
      productId: productId,
      warehouseId: warehouseId,
      batchNumber: batchNumber,
      serialNumber: serialNumber,
      quantity: quantity,
      expiryDate: expiryDate,
      receivedDate: DateTime.now(),
    );
  }
}

class StockBatchAdapter extends TypeAdapter<StockBatch> {
  @override
  final int typeId = 12;

  @override
  StockBatch read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return StockBatch(
      id: fields[0] as String,
      productId: fields[1] as String,
      warehouseId: fields[2] as String,
      batchNumber: fields[3] as String,
      serialNumber: fields[4] as String?,
      quantity: fields[5] as double,
      expiryDate: fields[6] as DateTime?,
      receivedDate: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StockBatch obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.warehouseId)
      ..writeByte(3)
      ..write(obj.batchNumber)
      ..writeByte(4)
      ..write(obj.serialNumber)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.expiryDate)
      ..writeByte(7)
      ..write(obj.receivedDate);
  }
}
