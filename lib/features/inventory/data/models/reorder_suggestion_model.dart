import 'package:hive/hive.dart';

part 'reorder_suggestion_model.g.dart';

@HiveType(typeId: 24)
class ReorderSuggestion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inventoryItemId;

  @HiveField(2)
  final String productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final double currentStock;

  @HiveField(5)
  final double minimumStock;

  @HiveField(6)
  final double reorderPoint;

  @HiveField(7)
  final double suggestedQuantity;

  @HiveField(8)
  final double averageDailySales;

  @HiveField(9)
  final int leadTimeDays;

  @HiveField(10)
  final double safetyStock;

  @HiveField(11)
  final SuggestionPriority priority;

  @HiveField(12)
  final DateTime generatedDate;

  @HiveField(13)
  final ReorderStatus status;

  @HiveField(14)
  final String? orderId; // If order was created

  @HiveField(15)
  final DateTime? orderDate;

  @HiveField(16)
  final String? notes;

  @HiveField(17)
  final Map<String, dynamic>? forecastData;

  ReorderSuggestion({
    required this.id,
    required this.inventoryItemId,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minimumStock,
    required this.reorderPoint,
    required this.suggestedQuantity,
    required this.averageDailySales,
    required this.leadTimeDays,
    required this.safetyStock,
    required this.priority,
    required this.generatedDate,
    required this.status,
    this.orderId,
    this.orderDate,
    this.notes,
    this.forecastData,
  });

  factory ReorderSuggestion.create({
    required String inventoryItemId,
    required String productId,
    required String productName,
    required double currentStock,
    required double minimumStock,
    required double reorderPoint,
    required double suggestedQuantity,
    required double averageDailySales,
    required int leadTimeDays,
    required double safetyStock,
  }) {
    // Calculate priority based on urgency
    SuggestionPriority priority;
    if (currentStock <= 0) {
      priority = SuggestionPriority.critical;
    } else if (currentStock <= minimumStock) {
      priority = SuggestionPriority.high;
    } else if (currentStock <= reorderPoint) {
      priority = SuggestionPriority.medium;
    } else {
      priority = SuggestionPriority.low;
    }

    return ReorderSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryItemId: inventoryItemId,
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      minimumStock: minimumStock,
      reorderPoint: reorderPoint,
      suggestedQuantity: suggestedQuantity,
      averageDailySales: averageDailySales,
      leadTimeDays: leadTimeDays,
      safetyStock: safetyStock,
      priority: priority,
      generatedDate: DateTime.now(),
      status: ReorderStatus.pending,
    );
  }

  ReorderSuggestion copyWith({
    ReorderStatus? status,
    String? orderId,
    DateTime? orderDate,
    String? notes,
  }) {
    return ReorderSuggestion(
      id: id,
      inventoryItemId: inventoryItemId,
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      minimumStock: minimumStock,
      reorderPoint: reorderPoint,
      suggestedQuantity: suggestedQuantity,
      averageDailySales: averageDailySales,
      leadTimeDays: leadTimeDays,
      safetyStock: safetyStock,
      priority: priority,
      generatedDate: generatedDate,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      notes: notes ?? this.notes,
      forecastData: forecastData,
    );
  }

  int get daysUntilStockout {
    if (averageDailySales <= 0) return 999;
    return (currentStock / averageDailySales).floor();
  }

  bool get isUrgent => daysUntilStockout <= leadTimeDays;
  double get estimatedCost =>
      suggestedQuantity * (forecastData?['costPrice'] ?? 0);
}

@HiveType(typeId: 25)
enum SuggestionPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,

  @HiveField(3)
  critical,
}

@HiveType(typeId: 26)
enum ReorderStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  approved,

  @HiveField(2)
  ordered,

  @HiveField(3)
  received,

  @HiveField(4)
  rejected,

  @HiveField(5)
  cancelled,
}
