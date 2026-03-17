import 'package:hive/hive.dart';

part 'stock_movement_model.g.dart';

@HiveType(typeId: 22)
class StockMovement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inventoryItemId;

  @HiveField(2)
  final String productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final MovementType type;

  @HiveField(5)
  final double quantity;

  @HiveField(6)
  final double previousStock;

  @HiveField(7)
  final double newStock;

  @HiveField(8)
  final String? fromLocation;

  @HiveField(9)
  final String? toLocation;

  @HiveField(10)
  final String? referenceId; // Invoice ID, Purchase Order ID, etc.

  @HiveField(11)
  final String? referenceType; // 'sale', 'purchase', 'transfer', 'adjustment'

  @HiveField(12)
  final String reason;

  @HiveField(13)
  final DateTime timestamp;

  @HiveField(14)
  final String performedBy;

  @HiveField(15)
  final String? notes;

  @HiveField(16)
  final double? costPrice;

  @HiveField(17)
  final double? sellingPrice;

  @HiveField(18)
  final Map<String, dynamic>? metadata;

  StockMovement({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.fromLocation,
    this.toLocation,
    this.referenceId,
    this.referenceType,
    required this.reason,
    required this.timestamp,
    required this.performedBy,
    this.notes,
    this.costPrice,
    this.sellingPrice,
    this.metadata,
  });

  factory StockMovement.create({
    required String inventoryItemId,
    required String productId,
    required String productName,
    required MovementType type,
    required double quantity,
    required double previousStock,
    required double newStock,
    String? fromLocation,
    String? toLocation,
    String? referenceId,
    String? referenceType,
    required String reason,
    required String performedBy,
    String? notes,
    double? costPrice,
    double? sellingPrice,
  }) {
    return StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryItemId: inventoryItemId,
      productId: productId,
      productName: productName,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      fromLocation: fromLocation,
      toLocation: toLocation,
      referenceId: referenceId,
      referenceType: referenceType,
      reason: reason,
      timestamp: DateTime.now(),
      performedBy: performedBy,
      notes: notes,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
    );
  }

  double get stockChange => newStock - previousStock;
  double get value => quantity * (costPrice ?? 0);
  bool get isInbound =>
      type == MovementType.purchase ||
      type == MovementType.customerReturn ||
      type == MovementType.adjustment && stockChange > 0;
  bool get isOutbound =>
      type == MovementType.sale ||
      type == MovementType.damage ||
      type == MovementType.adjustment && stockChange < 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'productId': productId,
      'productName': productName,
      'type': type.index,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'notes': notes,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'metadata': metadata,
    };
  }

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      inventoryItemId: json['inventoryItemId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: MovementType.values[json['type'] as int],
      quantity: (json['quantity'] as num).toDouble(),
      previousStock: (json['previousStock'] as num).toDouble(),
      newStock: (json['newStock'] as num).toDouble(),
      fromLocation: json['fromLocation'] as String?,
      toLocation: json['toLocation'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      performedBy: json['performedBy'] as String,
      notes: json['notes'] as String?,
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

@HiveType(typeId: 23)
enum MovementType {
  @HiveField(0)
  purchase, // Stock in from supplier

  @HiveField(1)
  sale, // Stock out to customer

  @HiveField(2)
  transfer, // Stock transfer between locations

  @HiveField(3)
  adjustment, // Manual stock adjustment

  @HiveField(4)
  customerReturn, // Customer return

  @HiveField(5)
  damage, // Damaged/lost stock

  @HiveField(6)
  production, // Stock used in production

  @HiveField(7)
  assembly, // Stock created from assembly

  @HiveField(8)
  reorder, // Automatic reorder
}
