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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'hsnCode': hsnCode,
      'unit': unit,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      hsnCode: json['hsnCode'] as String? ?? '',
      unit: json['unit'] as String? ?? 'Pcs',
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
  final String gstin; // Company GSTIN
  final String stateCode; // Company State Code
  final bool isInterstate;
  final String shippingAddress;
  
  // Client Details
  final String clientAddress;
  final String clientGstin;
  final String clientStateCode;
  final String clientPhone;
  final String clientEmail;
  
  // Additional Invoice Details
  final String orderNumber;
  final DateTime? orderDate;
  final String paymentTerms;
  final String deliveryNote;
  final String dispatchedThrough;
  final String destination;

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
    this.clientAddress = '',
    this.clientGstin = '',
    this.clientStateCode = '',
    this.clientPhone = '',
    this.clientEmail = '',
    this.orderNumber = '',
    this.orderDate,
    this.paymentTerms = '',
    this.deliveryNote = '',
    this.dispatchedThrough = '',
    this.destination = '',
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  // Tax Logic: If interstate, IGST. Else CGST+SGST.
  // For simplicity, we stick to 18% GST (9+9 or 18).
  // This logic should probably be more complex, but for now:
  double get tax => subtotal * 0.18; // Default 18% GST

  double get total => subtotal + tax + courierCharges;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'clientName': clientName,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'status': status.index,
      'notes': notes,
      'poNumber': poNumber,
      'poDate': poDate?.toIso8601String(),
      'transportMode': transportMode,
      'courierCharges': courierCharges,
      'gstin': gstin,
      'stateCode': stateCode,
      'isInterstate': isInterstate,
      'shippingAddress': shippingAddress,
      'clientAddress': clientAddress,
      'clientGstin': clientGstin,
      'clientStateCode': clientStateCode,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'orderNumber': orderNumber,
      'orderDate': orderDate?.toIso8601String(),
      'paymentTerms': paymentTerms,
      'deliveryNote': deliveryNote,
      'dispatchedThrough': dispatchedThrough,
      'destination': destination,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      clientName: json['clientName'] as String,
      date: DateTime.parse(json['date'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      items: (json['items'] as List)
          .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: InvoiceStatus.values[json['status'] as int],
      notes: json['notes'] as String? ?? '',
      poNumber: json['poNumber'] as String? ?? '',
      poDate: json['poDate'] != null ? DateTime.parse(json['poDate']) : null,
      transportMode: json['transportMode'] as String? ?? '',
      courierCharges: (json['courierCharges'] as num?)?.toDouble() ?? 0.0,
      gstin: json['gstin'] as String? ?? '',
      stateCode: json['stateCode'] as String? ?? '',
      isInterstate: json['isInterstate'] as bool? ?? false,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      clientAddress: json['clientAddress'] as String? ?? '',
      clientGstin: json['clientGstin'] as String? ?? '',
      clientStateCode: json['clientStateCode'] as String? ?? '',
      clientPhone: json['clientPhone'] as String? ?? '',
      clientEmail: json['clientEmail'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      paymentTerms: json['paymentTerms'] as String? ?? '',
      deliveryNote: json['deliveryNote'] as String? ?? '',
      dispatchedThrough: json['dispatchedThrough'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
    );
  }
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
      id: (fields.containsKey(0) && fields[0] != null) ? fields[0] as String : '',
      invoiceNumber: (fields.containsKey(1) && fields[1] != null) ? fields[1] as String : '',
      clientName: (fields.containsKey(2) && fields[2] != null) ? fields[2] as String : '',
      date: (fields.containsKey(3) && fields[3] != null) ? fields[3] as DateTime : DateTime.now(),
      dueDate: (fields.containsKey(4) && fields[4] != null) ? fields[4] as DateTime : DateTime.now(),
      items: (fields.containsKey(5) && fields[5] != null) ? (fields[5] as List).cast<InvoiceItem>() : [],
      status: (fields.containsKey(6) && fields[6] != null) ? fields[6] as InvoiceStatus : InvoiceStatus.draft,
      notes: (fields.containsKey(7) && fields[7] != null) ? fields[7] as String : '',
      poNumber: (fields.containsKey(8) && fields[8] != null) ? fields[8] as String : '',
      poDate: fields.containsKey(9) ? fields[9] as DateTime? : null,
      transportMode: (fields.containsKey(10) && fields[10] != null) ? fields[10] as String : '',
      courierCharges: (fields.containsKey(11) && fields[11] != null) ? fields[11] as double : 0.0,
      gstin: (fields.containsKey(12) && fields[12] != null) ? fields[12] as String : '',
      stateCode: (fields.containsKey(13) && fields[13] != null) ? fields[13] as String : '',
      isInterstate: (fields.containsKey(14) && fields[14] != null) ? fields[14] as bool : false,
      shippingAddress: (fields.containsKey(15) && fields[15] != null) ? fields[15] as String : '',
      clientAddress: (fields.containsKey(16) && fields[16] != null) ? fields[16] as String : '',
      clientGstin: (fields.containsKey(17) && fields[17] != null) ? fields[17] as String : '',
      clientStateCode: (fields.containsKey(18) && fields[18] != null) ? fields[18] as String : '',
      clientPhone: (fields.containsKey(19) && fields[19] != null) ? fields[19] as String : '',
      clientEmail: (fields.containsKey(20) && fields[20] != null) ? fields[20] as String : '',
      orderNumber: (fields.containsKey(21) && fields[21] != null) ? fields[21] as String : '',
      orderDate: fields.containsKey(22) ? fields[22] as DateTime? : null,
      paymentTerms: (fields.containsKey(23) && fields[23] != null) ? fields[23] as String : '',
      deliveryNote: (fields.containsKey(24) && fields[24] != null) ? fields[24] as String : '',
      dispatchedThrough: (fields.containsKey(25) && fields[25] != null) ? fields[25] as String : '',
      destination: (fields.containsKey(26) && fields[26] != null) ? fields[26] as String : '',
    );
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer
      ..writeByte(27)
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
      ..write(obj.shippingAddress)
      ..writeByte(16)
      ..write(obj.clientAddress)
      ..writeByte(17)
      ..write(obj.clientGstin)
      ..writeByte(18)
      ..write(obj.clientStateCode)
      ..writeByte(19)
      ..write(obj.clientPhone)
      ..writeByte(20)
      ..write(obj.clientEmail)
      ..writeByte(21)
      ..write(obj.orderNumber)
      ..writeByte(22)
      ..write(obj.orderDate)
      ..writeByte(23)
      ..write(obj.paymentTerms)
      ..writeByte(24)
      ..write(obj.deliveryNote)
      ..writeByte(25)
      ..write(obj.dispatchedThrough)
      ..writeByte(26)
      ..write(obj.destination);
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
