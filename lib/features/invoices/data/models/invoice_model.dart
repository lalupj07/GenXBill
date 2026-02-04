import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

enum InvoiceStatus { draft, sent, paid, overdue }

class InvoiceItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final String hsnCode;
  final String unit;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.hsnCode = '',
    this.unit = 'Pcs',
  });

  double get total => quantity * unitPrice;

  factory InvoiceItem.create({
    required String description,
    required double quantity,
    required double price,
    String hsnCode = '',
    String unit = 'Pcs',
  }) {
    return InvoiceItem(
      id: const Uuid().v4(),
      description: description,
      quantity: quantity,
      unitPrice: price,
      hsnCode: hsnCode,
      unit: unit,
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final String notes;

  // New Fields
  final String poNumber;
  final DateTime? poDate;
  final String transportMode;
  final double courierCharges;
  final String gstin;
  final String stateCode;
  final bool isInterstate;
  final String shippingAddress;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.status,
    this.notes = '',
    this.poNumber = '',
    this.poDate,
    this.transportMode = '',
    this.courierCharges = 0.0,
    this.gstin = '',
    this.stateCode = '',
    this.isInterstate = false,
    this.shippingAddress = '',
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  // Tax Logic: If interstate, IGST. Else CGST+SGST.
  // For simplicity, we stick to 18% GST (9+9 or 18).
  // This logic should probably be more complex, but for now:
  double get tax => subtotal * 0.18; // Default 18% GST

  double get total => subtotal + tax + courierCharges;
}

class InvoiceAdapter extends TypeAdapter<Invoice> {
  @override
  final int typeId = 0;

  @override
  Invoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoice(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      clientName: fields[2] as String,
      date: fields[3] as DateTime,
      dueDate: fields[4] as DateTime,
      items: (fields[5] as List).cast<InvoiceItem>(),
      status: fields[6] as InvoiceStatus,
      notes: fields[7] as String,
      poNumber: fields.containsKey(8) ? fields[8] as String : '',
      poDate: fields.containsKey(9) ? fields[9] as DateTime? : null,
      transportMode: fields.containsKey(10) ? fields[10] as String : '',
      courierCharges: fields.containsKey(11) ? fields[11] as double : 0.0,
      gstin: fields.containsKey(12) ? fields[12] as String : '',
      stateCode: fields.containsKey(13) ? fields[13] as String : '',
      isInterstate: fields.containsKey(14) ? fields[14] as bool : false,
      shippingAddress: fields.containsKey(15) ? fields[15] as String : '',
    );
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.poNumber)
      ..writeByte(9)
      ..write(obj.poDate)
      ..writeByte(10)
      ..write(obj.transportMode)
      ..writeByte(11)
      ..write(obj.courierCharges)
      ..writeByte(12)
      ..write(obj.gstin)
      ..writeByte(13)
      ..write(obj.stateCode)
      ..writeByte(14)
      ..write(obj.isInterstate)
      ..writeByte(15)
      ..write(obj.shippingAddress);
  }
}

class InvoiceItemAdapter extends TypeAdapter<InvoiceItem> {
  @override
  final int typeId = 1;

  @override
  InvoiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItem(
      id: fields[0] as String,
      description: fields[1] as String,
      quantity: fields[2] as double,
      unitPrice: fields[3] as double,
      hsnCode: fields.containsKey(4) ? fields[4] as String : '',
      unit: fields.containsKey(5) ? fields[5] as String : 'Pcs',
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.hsnCode)
      ..writeByte(5)
      ..write(obj.unit);
  }
}

class InvoiceStatusAdapter extends TypeAdapter<InvoiceStatus> {
  @override
  final int typeId = 2;

  @override
  InvoiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceStatus.draft;
      case 1:
        return InvoiceStatus.sent;
      case 2:
        return InvoiceStatus.paid;
      case 3:
        return InvoiceStatus.overdue;
      default:
        return InvoiceStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceStatus obj) {
    switch (obj) {
      case InvoiceStatus.draft:
        writer.writeByte(0);
        break;
      case InvoiceStatus.sent:
        writer.writeByte(1);
        break;
      case InvoiceStatus.paid:
        writer.writeByte(2);
        break;
      case InvoiceStatus.overdue:
        writer.writeByte(3);
        break;
    }
  }
}
