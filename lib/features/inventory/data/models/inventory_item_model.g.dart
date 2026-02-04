// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 20;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItem(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      sku: fields[3] as String,
      currentStock: fields[4] as double,
      minimumStock: fields[5] as double,
      reorderPoint: fields[6] as double,
      reorderQuantity: fields[7] as double,
      batchNumber: fields[8] as String?,
      serialNumber: fields[9] as String?,
      location: fields[10] as String,
      warehouse: fields[11] as String?,
      costPrice: fields[12] as double,
      sellingPrice: fields[13] as double,
      expiryDate: fields[14] as DateTime?,
      lastUpdated: fields[15] as DateTime,
      updatedBy: fields[16] as String,
      status: fields[17] as InventoryStatus,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.sku)
      ..writeByte(4)
      ..write(obj.currentStock)
      ..writeByte(5)
      ..write(obj.minimumStock)
      ..writeByte(6)
      ..write(obj.reorderPoint)
      ..writeByte(7)
      ..write(obj.reorderQuantity)
      ..writeByte(8)
      ..write(obj.batchNumber)
      ..writeByte(9)
      ..write(obj.serialNumber)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.warehouse)
      ..writeByte(12)
      ..write(obj.costPrice)
      ..writeByte(13)
      ..write(obj.sellingPrice)
      ..writeByte(14)
      ..write(obj.expiryDate)
      ..writeByte(15)
      ..write(obj.lastUpdated)
      ..writeByte(16)
      ..write(obj.updatedBy)
      ..writeByte(17)
      ..write(obj.status)
      ..writeByte(18)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryStatusAdapter extends TypeAdapter<InventoryStatus> {
  @override
  final int typeId = 21;

  @override
  InventoryStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InventoryStatus.inStock;
      case 1:
        return InventoryStatus.lowStock;
      case 2:
        return InventoryStatus.outOfStock;
      case 3:
        return InventoryStatus.reorderNeeded;
      case 4:
        return InventoryStatus.discontinued;
      case 5:
        return InventoryStatus.damaged;
      case 6:
        return InventoryStatus.expired;
      default:
        return InventoryStatus.inStock;
    }
  }

  @override
  void write(BinaryWriter writer, InventoryStatus obj) {
    switch (obj) {
      case InventoryStatus.inStock:
        writer.writeByte(0);
        break;
      case InventoryStatus.lowStock:
        writer.writeByte(1);
        break;
      case InventoryStatus.outOfStock:
        writer.writeByte(2);
        break;
      case InventoryStatus.reorderNeeded:
        writer.writeByte(3);
        break;
      case InventoryStatus.discontinued:
        writer.writeByte(4);
        break;
      case InventoryStatus.damaged:
        writer.writeByte(5);
        break;
      case InventoryStatus.expired:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
