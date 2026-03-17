import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'order_model.g.dart';

@HiveType(typeId: 70)
enum OrderType {
  @HiveField(0)
  sales,
  @HiveField(1)
  purchase,
}

@HiveType(typeId: 71)
enum OrderStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  processing,
  @HiveField(3)
  shipped,
  @HiveField(4)
  delivered,
  @HiveField(5)
  cancelled,
  @HiveField(6)
  returned,
}

@HiveType(typeId: 74)
enum OrderSource {
  @HiveField(0)
  manual,
  @HiveField(1)
  whatsapp,
  @HiveField(2)
  email,
  @HiveField(3)
  phone,
  @HiveField(4)
  website,
  @HiveField(5)
  other,
}

@HiveType(typeId: 72)
class OrderItem {
  @HiveField(0)
  final String productId;
  @HiveField(1)
  final String productName;
  @HiveField(2)
  final double quantity;
  @HiveField(3)
  final double unitPrice;
  @HiveField(4)
  final double taxRate;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0.0,
  });

  double get total => quantity * unitPrice * (1 + taxRate);
}

@HiveType(typeId: 73)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String orderNumber;
  @HiveField(2)
  final String clientId; // Customer or Supplier ID
  @HiveField(3)
  final String clientName;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final OrderType type;
  @HiveField(6)
  final OrderStatus status;
  @HiveField(7)
  final List<OrderItem> items;
  @HiveField(8)
  final String? notes;
  @HiveField(9)
  final double totalAmount;
  @HiveField(10)
  final OrderSource source;
  @HiveField(11)
  final String? assignedEmployeeId;
  @HiveField(12)
  final String? assignedEmployeeName;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.type,
    this.status = OrderStatus.pending,
    required this.items,
    this.notes,
    required this.totalAmount,
    this.source = OrderSource.manual,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
  });

  factory OrderModel.create({
    required String orderNumber,
    required String clientId,
    required String clientName,
    required OrderType type,
    required List<OrderItem> items,
    String? notes,
    OrderSource source = OrderSource.manual,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
  }) {
    final total = items.fold(0.0, (sum, item) => sum + item.total);
    return OrderModel(
      id: const Uuid().v4(),
      orderNumber: orderNumber,
      clientId: clientId,
      clientName: clientName,
      date: DateTime.now(),
      type: type,
      items: items,
      notes: notes,
      totalAmount: total,
      source: source,
      assignedEmployeeId: assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'clientId': clientId,
      'clientName': clientName,
      'date': date.toIso8601String(),
      'type': type.index,
      'status': status.index,
      'items': items
          .map((i) => {
                'productId': i.productId,
                'productName': i.productName,
                'quantity': i.quantity,
                'unitPrice': i.unitPrice,
                'taxRate': i.taxRate,
              })
          .toList(),
      'notes': notes,
      'totalAmount': totalAmount,
      'source': source.index,
      'assignedEmployeeId': assignedEmployeeId,
      'assignedEmployeeName': assignedEmployeeName,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      date: DateTime.parse(json['date'] as String),
      type: OrderType.values[json['type'] as int],
      status: OrderStatus.values[json['status'] as int],
      items: (json['items'] as List)
          .map((i) => OrderItem(
                productId: i['productId'] as String,
                productName: i['productName'] as String,
                quantity: (i['quantity'] as num).toDouble(),
                unitPrice: (i['unitPrice'] as num).toDouble(),
                taxRate: (i['taxRate'] as num).toDouble(),
              ))
          .toList(),
      notes: json['notes'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      source: json['source'] != null
          ? OrderSource.values[json['source'] as int]
          : OrderSource.manual,
      assignedEmployeeId: json['assignedEmployeeId'] as String?,
      assignedEmployeeName: json['assignedEmployeeName'] as String?,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? clientId,
    String? clientName,
    DateTime? date,
    OrderType? type,
    OrderStatus? status,
    List<OrderItem>? items,
    String? notes,
    double? totalAmount,
    OrderSource? source,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      source: source ?? this.source,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
    );
  }
}
