// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 72;

  @override
  OrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as double,
      unitPrice: fields[3] as double,
      taxRate: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.taxRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 73;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      orderNumber: fields[1] as String,
      clientId: fields[2] as String,
      clientName: fields[3] as String,
      date: fields[4] as DateTime,
      type: fields[5] as OrderType,
      status: fields[6] as OrderStatus,
      items: (fields[7] as List).cast<OrderItem>(),
      notes: fields[8] as String?,
      totalAmount: fields[9] as double,
      source: fields[10] as OrderSource,
      assignedEmployeeId: fields[11] as String?,
      assignedEmployeeName: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.clientId)
      ..writeByte(3)
      ..write(obj.clientName)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.totalAmount)
      ..writeByte(10)
      ..write(obj.source)
      ..writeByte(11)
      ..write(obj.assignedEmployeeId)
      ..writeByte(12)
      ..write(obj.assignedEmployeeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderTypeAdapter extends TypeAdapter<OrderType> {
  @override
  final int typeId = 70;

  @override
  OrderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderType.sales;
      case 1:
        return OrderType.purchase;
      default:
        return OrderType.sales;
    }
  }

  @override
  void write(BinaryWriter writer, OrderType obj) {
    switch (obj) {
      case OrderType.sales:
        writer.writeByte(0);
        break;
      case OrderType.purchase:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 71;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.pending;
      case 1:
        return OrderStatus.confirmed;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.shipped;
      case 4:
        return OrderStatus.delivered;
      case 5:
        return OrderStatus.cancelled;
      case 6:
        return OrderStatus.returned;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.pending:
        writer.writeByte(0);
        break;
      case OrderStatus.confirmed:
        writer.writeByte(1);
        break;
      case OrderStatus.processing:
        writer.writeByte(2);
        break;
      case OrderStatus.shipped:
        writer.writeByte(3);
        break;
      case OrderStatus.delivered:
        writer.writeByte(4);
        break;
      case OrderStatus.cancelled:
        writer.writeByte(5);
        break;
      case OrderStatus.returned:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderSourceAdapter extends TypeAdapter<OrderSource> {
  @override
  final int typeId = 74;

  @override
  OrderSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderSource.manual;
      case 1:
        return OrderSource.whatsapp;
      case 2:
        return OrderSource.email;
      case 3:
        return OrderSource.phone;
      case 4:
        return OrderSource.website;
      case 5:
        return OrderSource.other;
      default:
        return OrderSource.manual;
    }
  }

  @override
  void write(BinaryWriter writer, OrderSource obj) {
    switch (obj) {
      case OrderSource.manual:
        writer.writeByte(0);
        break;
      case OrderSource.whatsapp:
        writer.writeByte(1);
        break;
      case OrderSource.email:
        writer.writeByte(2);
        break;
      case OrderSource.phone:
        writer.writeByte(3);
        break;
      case OrderSource.website:
        writer.writeByte(4);
        break;
      case OrderSource.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
