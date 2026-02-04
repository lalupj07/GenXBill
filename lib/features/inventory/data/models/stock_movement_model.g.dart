// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockMovementAdapter extends TypeAdapter<StockMovement> {
  @override
  final int typeId = 22;

  @override
  StockMovement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockMovement(
      id: fields[0] as String,
      inventoryItemId: fields[1] as String,
      productId: fields[2] as String,
      productName: fields[3] as String,
      type: fields[4] as MovementType,
      quantity: fields[5] as double,
      previousStock: fields[6] as double,
      newStock: fields[7] as double,
      fromLocation: fields[8] as String?,
      toLocation: fields[9] as String?,
      referenceId: fields[10] as String?,
      referenceType: fields[11] as String?,
      reason: fields[12] as String,
      timestamp: fields[13] as DateTime,
      performedBy: fields[14] as String,
      notes: fields[15] as String?,
      costPrice: fields[16] as double?,
      sellingPrice: fields[17] as double?,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, StockMovement obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inventoryItemId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.previousStock)
      ..writeByte(7)
      ..write(obj.newStock)
      ..writeByte(8)
      ..write(obj.fromLocation)
      ..writeByte(9)
      ..write(obj.toLocation)
      ..writeByte(10)
      ..write(obj.referenceId)
      ..writeByte(11)
      ..write(obj.referenceType)
      ..writeByte(12)
      ..write(obj.reason)
      ..writeByte(13)
      ..write(obj.timestamp)
      ..writeByte(14)
      ..write(obj.performedBy)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.costPrice)
      ..writeByte(17)
      ..write(obj.sellingPrice)
      ..writeByte(18)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovementTypeAdapter extends TypeAdapter<MovementType> {
  @override
  final int typeId = 23;

  @override
  MovementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MovementType.purchase;
      case 1:
        return MovementType.sale;
      case 2:
        return MovementType.transfer;
      case 3:
        return MovementType.adjustment;
      case 4:
        return MovementType.customerReturn;
      case 5:
        return MovementType.damage;
      case 6:
        return MovementType.production;
      case 7:
        return MovementType.assembly;
      case 8:
        return MovementType.reorder;
      default:
        return MovementType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, MovementType obj) {
    switch (obj) {
      case MovementType.purchase:
        writer.writeByte(0);
        break;
      case MovementType.sale:
        writer.writeByte(1);
        break;
      case MovementType.transfer:
        writer.writeByte(2);
        break;
      case MovementType.adjustment:
        writer.writeByte(3);
        break;
      case MovementType.customerReturn:
        writer.writeByte(4);
        break;
      case MovementType.damage:
        writer.writeByte(5);
        break;
      case MovementType.production:
        writer.writeByte(6);
        break;
      case MovementType.assembly:
        writer.writeByte(7);
        break;
      case MovementType.reorder:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
