import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';

class StockMovementRepository {
  static const String _boxName = 'stock_movements';

  Box<StockMovement> get box => Hive.box<StockMovement>(_boxName);

  // CRUD Operations
  Future<void> addMovement(StockMovement movement) async {
    await box.put(movement.id, movement);
  }

  Future<void> deleteMovement(String id) async {
    await box.delete(id);
  }

  StockMovement? getMovement(String id) {
    return box.get(id);
  }

  List<StockMovement> getAllMovements() {
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Query Operations
  List<StockMovement> getMovementsByItem(String inventoryItemId) {
    return box.values
        .where((m) => m.inventoryItemId == inventoryItemId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getMovementsByProduct(String productId) {
    return box.values.where((m) => m.productId == productId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getMovementsByType(MovementType type) {
    return box.values.where((m) => m.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getMovementsByLocation(String location) {
    return box.values.where((m) {
      return m.fromLocation == location || m.toLocation == location;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getMovementsByDateRange(
      DateTime startDate, DateTime endDate) {
    return box.values.where((m) {
      return m.timestamp.isAfter(startDate) && m.timestamp.isBefore(endDate);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getMovementsByUser(String userId) {
    return box.values.where((m) => m.performedBy == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockMovement> getRecentMovements({int limit = 50}) {
    final movements = getAllMovements();
    return movements.take(limit).toList();
  }

  // Analytics
  double getTotalInboundQuantity(String productId,
      {DateTime? startDate, DateTime? endDate}) {
    var movements = getMovementsByProduct(productId);

    if (startDate != null && endDate != null) {
      movements = movements.where((m) {
        return m.timestamp.isAfter(startDate) && m.timestamp.isBefore(endDate);
      }).toList();
    }

    return movements
        .where((m) => m.isInbound)
        .fold(0.0, (sum, m) => sum + m.quantity);
  }

  double getTotalOutboundQuantity(String productId,
      {DateTime? startDate, DateTime? endDate}) {
    var movements = getMovementsByProduct(productId);

    if (startDate != null && endDate != null) {
      movements = movements.where((m) {
        return m.timestamp.isAfter(startDate) && m.timestamp.isBefore(endDate);
      }).toList();
    }

    return movements
        .where((m) => m.isOutbound)
        .fold(0.0, (sum, m) => sum + m.quantity);
  }

  Map<MovementType, int> getMovementCountByType() {
    final Map<MovementType, int> result = {};
    for (final movement in box.values) {
      result[movement.type] = (result[movement.type] ?? 0) + 1;
    }
    return result;
  }

  Map<String, double> getMovementValueByType() {
    final Map<String, double> result = {};
    for (final movement in box.values) {
      final typeName = movement.type.name;
      result[typeName] = (result[typeName] ?? 0) + movement.value;
    }
    return result;
  }

  // Historical Analysis
  List<Map<String, dynamic>> getDailySalesHistory(String productId,
      {int days = 30}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final movements = getMovementsByProduct(productId)
        .where((m) =>
            m.type == MovementType.sale &&
            m.timestamp.isAfter(startDate) &&
            m.timestamp.isBefore(endDate))
        .toList();

    final Map<String, double> dailySales = {};

    for (final movement in movements) {
      final dateKey =
          '${movement.timestamp.year}-${movement.timestamp.month.toString().padLeft(2, '0')}-${movement.timestamp.day.toString().padLeft(2, '0')}';
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + movement.quantity;
    }

    return dailySales.entries
        .map((e) => {'date': e.key, 'quantity': e.value})
        .toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  double getAverageDailySales(String productId, {int days = 30}) {
    final history = getDailySalesHistory(productId, days: days);
    if (history.isEmpty) return 0.0;

    final totalSales =
        history.fold(0.0, (sum, day) => sum + (day['quantity'] as double));
    return totalSales / days;
  }

  // Audit Trail
  List<StockMovement> getAuditTrail({
    String? productId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var movements = getAllMovements();

    if (productId != null) {
      movements = movements.where((m) => m.productId == productId).toList();
    }

    if (userId != null) {
      movements = movements.where((m) => m.performedBy == userId).toList();
    }

    if (startDate != null && endDate != null) {
      movements = movements.where((m) {
        return m.timestamp.isAfter(startDate) && m.timestamp.isBefore(endDate);
      }).toList();
    }

    return movements;
  }
}
