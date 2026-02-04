// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryTransactionAdapter extends TypeAdapter<InventoryTransaction> {
  @override
  final int typeId = 14;

  @override
  InventoryTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryTransaction(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      type: fields[3] as TransactionType,
      quantity: fields[4] as double,
      date: fields[5] as DateTime,
      batchId: fields[6] as String?,
      serialNumber: fields[7] as String?,
      performedBy: fields[8] as String?,
      notes: fields[9] as String?,
      referenceId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryTransaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.batchId)
      ..writeByte(7)
      ..write(obj.serialNumber)
      ..writeByte(8)
      ..write(obj.performedBy)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.referenceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 13;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.purchase;
      case 1:
        return TransactionType.sale;
      case 2:
        return TransactionType.returnIn;
      case 3:
        return TransactionType.returnOut;
      case 4:
        return TransactionType.adjustment;
      case 5:
        return TransactionType.damage;
      default:
        return TransactionType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.purchase:
        writer.writeByte(0);
        break;
      case TransactionType.sale:
        writer.writeByte(1);
        break;
      case TransactionType.returnIn:
        writer.writeByte(2);
        break;
      case TransactionType.returnOut:
        writer.writeByte(3);
        break;
      case TransactionType.adjustment:
        writer.writeByte(4);
        break;
      case TransactionType.damage:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
