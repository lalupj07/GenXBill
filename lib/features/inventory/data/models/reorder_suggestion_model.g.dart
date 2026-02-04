// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_suggestion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReorderSuggestionAdapter extends TypeAdapter<ReorderSuggestion> {
  @override
  final int typeId = 24;

  @override
  ReorderSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReorderSuggestion(
      id: fields[0] as String,
      inventoryItemId: fields[1] as String,
      productId: fields[2] as String,
      productName: fields[3] as String,
      currentStock: fields[4] as double,
      minimumStock: fields[5] as double,
      reorderPoint: fields[6] as double,
      suggestedQuantity: fields[7] as double,
      averageDailySales: fields[8] as double,
      leadTimeDays: fields[9] as int,
      safetyStock: fields[10] as double,
      priority: fields[11] as SuggestionPriority,
      generatedDate: fields[12] as DateTime,
      status: fields[13] as ReorderStatus,
      orderId: fields[14] as String?,
      orderDate: fields[15] as DateTime?,
      notes: fields[16] as String?,
      forecastData: (fields[17] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReorderSuggestion obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inventoryItemId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.currentStock)
      ..writeByte(5)
      ..write(obj.minimumStock)
      ..writeByte(6)
      ..write(obj.reorderPoint)
      ..writeByte(7)
      ..write(obj.suggestedQuantity)
      ..writeByte(8)
      ..write(obj.averageDailySales)
      ..writeByte(9)
      ..write(obj.leadTimeDays)
      ..writeByte(10)
      ..write(obj.safetyStock)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.generatedDate)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.orderId)
      ..writeByte(15)
      ..write(obj.orderDate)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.forecastData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReorderSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuggestionPriorityAdapter extends TypeAdapter<SuggestionPriority> {
  @override
  final int typeId = 25;

  @override
  SuggestionPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SuggestionPriority.low;
      case 1:
        return SuggestionPriority.medium;
      case 2:
        return SuggestionPriority.high;
      case 3:
        return SuggestionPriority.critical;
      default:
        return SuggestionPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, SuggestionPriority obj) {
    switch (obj) {
      case SuggestionPriority.low:
        writer.writeByte(0);
        break;
      case SuggestionPriority.medium:
        writer.writeByte(1);
        break;
      case SuggestionPriority.high:
        writer.writeByte(2);
        break;
      case SuggestionPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReorderStatusAdapter extends TypeAdapter<ReorderStatus> {
  @override
  final int typeId = 26;

  @override
  ReorderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReorderStatus.pending;
      case 1:
        return ReorderStatus.approved;
      case 2:
        return ReorderStatus.ordered;
      case 3:
        return ReorderStatus.received;
      case 4:
        return ReorderStatus.rejected;
      case 5:
        return ReorderStatus.cancelled;
      default:
        return ReorderStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ReorderStatus obj) {
    switch (obj) {
      case ReorderStatus.pending:
        writer.writeByte(0);
        break;
      case ReorderStatus.approved:
        writer.writeByte(1);
        break;
      case ReorderStatus.ordered:
        writer.writeByte(2);
        break;
      case ReorderStatus.received:
        writer.writeByte(3);
        break;
      case ReorderStatus.rejected:
        writer.writeByte(4);
        break;
      case ReorderStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReorderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
