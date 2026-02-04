import 'package:hive/hive.dart';

part 'inventory_item_model.g.dart';

@HiveType(typeId: 20)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String sku;

  @HiveField(4)
  final double currentStock;

  @HiveField(5)
  final double minimumStock;

  @HiveField(6)
  final double reorderPoint;

  @HiveField(7)
  final double reorderQuantity;

  @HiveField(8)
  final String? batchNumber;

  @HiveField(9)
  final String? serialNumber;

  @HiveField(10)
  final String location;

  @HiveField(11)
  final String? warehouse;

  @HiveField(12)
  final double costPrice;

  @HiveField(13)
  final double sellingPrice;

  @HiveField(14)
  final DateTime? expiryDate;

  @HiveField(15)
  final DateTime lastUpdated;

  @HiveField(16)
  final String updatedBy;

  @HiveField(17)
  final InventoryStatus status;

  @HiveField(18)
  final Map<String, dynamic>? metadata;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.currentStock,
    required this.minimumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    this.batchNumber,
    this.serialNumber,
    required this.location,
    this.warehouse,
    required this.costPrice,
    required this.sellingPrice,
    this.expiryDate,
    required this.lastUpdated,
    required this.updatedBy,
    required this.status,
    this.metadata,
  });

  factory InventoryItem.create({
    required String productId,
    required String productName,
    required String sku,
    required double currentStock,
    required double minimumStock,
    required double reorderPoint,
    required double reorderQuantity,
    String? batchNumber,
    String? serialNumber,
    required String location,
    String? warehouse,
    required double costPrice,
    required double sellingPrice,
    DateTime? expiryDate,
    required String updatedBy,
  }) {
    return InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: productId,
      productName: productName,
      sku: sku,
      currentStock: currentStock,
      minimumStock: minimumStock,
      reorderPoint: reorderPoint,
      reorderQuantity: reorderQuantity,
      batchNumber: batchNumber,
      serialNumber: serialNumber,
      location: location,
      warehouse: warehouse,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      expiryDate: expiryDate,
      lastUpdated: DateTime.now(),
      updatedBy: updatedBy,
      status: currentStock <= minimumStock
          ? InventoryStatus.lowStock
          : currentStock <= reorderPoint
              ? InventoryStatus.reorderNeeded
              : InventoryStatus.inStock,
    );
  }

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    double? currentStock,
    double? minimumStock,
    double? reorderPoint,
    double? reorderQuantity,
    String? batchNumber,
    String? serialNumber,
    String? location,
    String? warehouse,
    double? costPrice,
    double? sellingPrice,
    DateTime? expiryDate,
    DateTime? lastUpdated,
    String? updatedBy,
    InventoryStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      batchNumber: batchNumber ?? this.batchNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      warehouse: warehouse ?? this.warehouse,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get needsReorder => currentStock <= reorderPoint;
  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock <= 0;
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  double get stockValue => currentStock * costPrice;
  double get potentialRevenue => currentStock * sellingPrice;
  double get profitMargin => sellingPrice - costPrice;
  double get profitMarginPercentage =>
      costPrice > 0 ? ((profitMargin / costPrice) * 100) : 0;
}

@HiveType(typeId: 21)
enum InventoryStatus {
  @HiveField(0)
  inStock,

  @HiveField(1)
  lowStock,

  @HiveField(2)
  outOfStock,

  @HiveField(3)
  reorderNeeded,

  @HiveField(4)
  discontinued,

  @HiveField(5)
  damaged,

  @HiveField(6)
  expired,
}
