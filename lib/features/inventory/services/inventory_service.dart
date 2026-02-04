import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/inventory/data/models/reorder_suggestion_model.dart';
import 'package:genx_bill/features/inventory/data/repositories/inventory_repository.dart';
import 'package:genx_bill/features/inventory/data/repositories/stock_movement_repository.dart';

class InventoryService {
  final InventoryRepository inventoryRepo;
  final StockMovementRepository movementRepo;

  InventoryService({
    required this.inventoryRepo,
    required this.movementRepo,
  });

  // Stock Movement Operations
  Future<void> addStock({
    required String inventoryItemId,
    required double quantity,
    required String performedBy,
    required String reason,
    MovementType type = MovementType.purchase,
    String? referenceId,
    String? referenceType,
    double? costPrice,
    String? notes,
  }) async {
    final item = inventoryRepo.getItem(inventoryItemId);
    if (item == null) throw Exception('Inventory item not found');

    final previousStock = item.currentStock;
    final newStock = previousStock + quantity;

    // Create movement record
    final movement = StockMovement.create(
      inventoryItemId: inventoryItemId,
      productId: item.productId,
      productName: item.productName,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      toLocation: item.location,
      referenceId: referenceId,
      referenceType: referenceType,
      reason: reason,
      performedBy: performedBy,
      notes: notes,
      costPrice: costPrice ?? item.costPrice,
    );

    await movementRepo.addMovement(movement);

    // Update inventory item
    final updatedItem = item.copyWith(
      currentStock: newStock,
      lastUpdated: DateTime.now(),
      updatedBy: performedBy,
      status: _calculateStatus(newStock, item.minimumStock, item.reorderPoint),
    );

    await inventoryRepo.updateItem(updatedItem);
  }

  Future<void> removeStock({
    required String inventoryItemId,
    required double quantity,
    required String performedBy,
    required String reason,
    MovementType type = MovementType.sale,
    String? referenceId,
    String? referenceType,
    double? sellingPrice,
    String? notes,
  }) async {
    final item = inventoryRepo.getItem(inventoryItemId);
    if (item == null) throw Exception('Inventory item not found');

    if (item.currentStock < quantity) {
      throw Exception('Insufficient stock. Available: ${item.currentStock}');
    }

    final previousStock = item.currentStock;
    final newStock = previousStock - quantity;

    // Create movement record
    final movement = StockMovement.create(
      inventoryItemId: inventoryItemId,
      productId: item.productId,
      productName: item.productName,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      fromLocation: item.location,
      referenceId: referenceId,
      referenceType: referenceType,
      reason: reason,
      performedBy: performedBy,
      notes: notes,
      sellingPrice: sellingPrice ?? item.sellingPrice,
    );

    await movementRepo.addMovement(movement);

    // Update inventory item
    final updatedItem = item.copyWith(
      currentStock: newStock,
      lastUpdated: DateTime.now(),
      updatedBy: performedBy,
      status: _calculateStatus(newStock, item.minimumStock, item.reorderPoint),
    );

    await inventoryRepo.updateItem(updatedItem);
  }

  Future<void> transferStock({
    required String inventoryItemId,
    required String toLocation,
    required double quantity,
    required String performedBy,
    required String reason,
    String? notes,
  }) async {
    final item = inventoryRepo.getItem(inventoryItemId);
    if (item == null) throw Exception('Inventory item not found');

    if (item.currentStock < quantity) {
      throw Exception('Insufficient stock for transfer');
    }

    final previousStock = item.currentStock;
    final newStock = previousStock - quantity;

    // Create movement record
    final movement = StockMovement.create(
      inventoryItemId: inventoryItemId,
      productId: item.productId,
      productName: item.productName,
      type: MovementType.transfer,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      fromLocation: item.location,
      toLocation: toLocation,
      reason: reason,
      performedBy: performedBy,
      notes: notes,
    );

    await movementRepo.addMovement(movement);

    // Update source item
    final updatedItem = item.copyWith(
      currentStock: newStock,
      lastUpdated: DateTime.now(),
      updatedBy: performedBy,
      status: _calculateStatus(newStock, item.minimumStock, item.reorderPoint),
    );

    await inventoryRepo.updateItem(updatedItem);

    // Create or update destination item
    final destinationItems = inventoryRepo
        .getItemsByProduct(item.productId)
        .where((i) => i.location == toLocation)
        .toList();

    if (destinationItems.isNotEmpty) {
      final destItem = destinationItems.first;
      final destUpdated = destItem.copyWith(
        currentStock: destItem.currentStock + quantity,
        lastUpdated: DateTime.now(),
        updatedBy: performedBy,
      );
      await inventoryRepo.updateItem(destUpdated);
    }
  }

  Future<void> adjustStock({
    required String inventoryItemId,
    required double newQuantity,
    required String performedBy,
    required String reason,
    String? notes,
  }) async {
    final item = inventoryRepo.getItem(inventoryItemId);
    if (item == null) throw Exception('Inventory item not found');

    final previousStock = item.currentStock;
    final difference = newQuantity - previousStock;

    // Create movement record
    final movement = StockMovement.create(
      inventoryItemId: inventoryItemId,
      productId: item.productId,
      productName: item.productName,
      type: MovementType.adjustment,
      quantity: difference.abs(),
      previousStock: previousStock,
      newStock: newQuantity,
      reason: reason,
      performedBy: performedBy,
      notes: notes,
    );

    await movementRepo.addMovement(movement);

    // Update inventory item
    final updatedItem = item.copyWith(
      currentStock: newQuantity,
      lastUpdated: DateTime.now(),
      updatedBy: performedBy,
      status:
          _calculateStatus(newQuantity, item.minimumStock, item.reorderPoint),
    );

    await inventoryRepo.updateItem(updatedItem);
  }

  // Demand Forecasting
  Map<String, dynamic> forecastDemand(String productId, {int days = 30}) {
    final avgDailySales =
        movementRepo.getAverageDailySales(productId, days: days);
    final salesHistory =
        movementRepo.getDailySalesHistory(productId, days: days);

    // Calculate trend
    double trend = 0.0;
    if (salesHistory.length >= 2) {
      final recentSales = salesHistory
          .skip(salesHistory.length - 7)
          .fold(0.0, (sum, day) => sum + (day['quantity'] as double));
      final olderSales = salesHistory
          .take(7)
          .fold(0.0, (sum, day) => sum + (day['quantity'] as double));

      if (olderSales > 0) {
        trend = ((recentSales - olderSales) / olderSales) * 100;
      }
    }

    // Forecast next 30 days
    final forecastedDemand = avgDailySales * 30 * (1 + (trend / 100));

    return {
      'averageDailySales': avgDailySales,
      'trend': trend,
      'forecastedDemand30Days': forecastedDemand,
      'salesHistory': salesHistory,
    };
  }

  // Reorder Suggestions
  List<ReorderSuggestion> generateReorderSuggestions() {
    final suggestions = <ReorderSuggestion>[];
    final itemsNeedingReorder = inventoryRepo.getItemsNeedingReorder();

    for (final item in itemsNeedingReorder) {
      final forecast = forecastDemand(item.productId);
      final avgDailySales = forecast['averageDailySales'] as double;
      const leadTimeDays = 7; // Default lead time
      final safetyStock = avgDailySales * leadTimeDays;

      // Calculate suggested quantity using Economic Order Quantity (EOQ) concept
      final suggestedQuantity = _calculateOptimalOrderQuantity(
        item,
        avgDailySales,
        leadTimeDays,
      );

      final suggestion = ReorderSuggestion.create(
        inventoryItemId: item.id,
        productId: item.productId,
        productName: item.productName,
        currentStock: item.currentStock,
        minimumStock: item.minimumStock,
        reorderPoint: item.reorderPoint,
        suggestedQuantity: suggestedQuantity,
        averageDailySales: avgDailySales,
        leadTimeDays: leadTimeDays,
        safetyStock: safetyStock,
      );

      suggestions.add(suggestion);
    }

    // Sort by priority
    suggestions.sort((a, b) {
      final priorityOrder = {
        SuggestionPriority.critical: 0,
        SuggestionPriority.high: 1,
        SuggestionPriority.medium: 2,
        SuggestionPriority.low: 3,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return suggestions;
  }

  double _calculateOptimalOrderQuantity(
    InventoryItem item,
    double avgDailySales,
    int leadTimeDays,
  ) {
    // Simple EOQ calculation
    // In production, you'd use: sqrt((2 * demand * orderCost) / holdingCost)
    final demandDuringLeadTime = avgDailySales * leadTimeDays;
    final safetyStock = avgDailySales * (leadTimeDays / 2);
    final reorderQuantity = item.reorderQuantity > 0
        ? item.reorderQuantity
        : demandDuringLeadTime + safetyStock;

    return reorderQuantity;
  }

  InventoryStatus _calculateStatus(
    double currentStock,
    double minimumStock,
    double reorderPoint,
  ) {
    if (currentStock <= 0) {
      return InventoryStatus.outOfStock;
    } else if (currentStock <= minimumStock) {
      return InventoryStatus.lowStock;
    } else if (currentStock <= reorderPoint) {
      return InventoryStatus.reorderNeeded;
    } else {
      return InventoryStatus.inStock;
    }
  }

  // Analytics
  Map<String, dynamic> getInventoryAnalytics() {
    final allItems = inventoryRepo.getAllItems();
    final totalValue = inventoryRepo.getTotalStockValue();
    final potentialRevenue = inventoryRepo.getTotalPotentialRevenue();
    final lowStockCount = inventoryRepo.getLowStockItems().length;
    final outOfStockCount = inventoryRepo.getOutOfStockItems().length;
    final reorderNeededCount = inventoryRepo.getItemsNeedingReorder().length;

    return {
      'totalItems': allItems.length,
      'totalStockValue': totalValue,
      'potentialRevenue': potentialRevenue,
      'projectedProfit': potentialRevenue - totalValue,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'reorderNeededCount': reorderNeededCount,
      'stockTurnoverRate': _calculateStockTurnoverRate(),
    };
  }

  double _calculateStockTurnoverRate() {
    // Calculate for last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final allMovements =
        movementRepo.getMovementsByDateRange(startDate, endDate);
    final salesMovements =
        allMovements.where((m) => m.type == MovementType.sale).toList();

    final totalSalesValue = salesMovements.fold(0.0, (sum, m) => sum + m.value);
    final avgInventoryValue = inventoryRepo.getTotalStockValue();

    if (avgInventoryValue == 0) return 0.0;
    return (totalSalesValue / avgInventoryValue) * 12; // Annualized
  }
}
