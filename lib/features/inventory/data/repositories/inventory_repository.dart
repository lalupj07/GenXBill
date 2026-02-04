import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';

class InventoryRepository {
  static const String _boxName = 'inventory_items';

  Box<InventoryItem> get box => Hive.box<InventoryItem>(_boxName);

  // CRUD Operations
  Future<void> addItem(InventoryItem item) async {
    await box.put(item.id, item);
  }

  Future<void> updateItem(InventoryItem item) async {
    await box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  InventoryItem? getItem(String id) {
    return box.get(id);
  }

  List<InventoryItem> getAllItems() {
    return box.values.toList();
  }

  // Query Operations
  List<InventoryItem> getItemsByLocation(String location) {
    return box.values.where((item) => item.location == location).toList();
  }

  List<InventoryItem> getItemsByWarehouse(String warehouse) {
    return box.values.where((item) => item.warehouse == warehouse).toList();
  }

  List<InventoryItem> getLowStockItems() {
    return box.values.where((item) => item.isLowStock).toList();
  }

  List<InventoryItem> getOutOfStockItems() {
    return box.values.where((item) => item.isOutOfStock).toList();
  }

  List<InventoryItem> getItemsNeedingReorder() {
    return box.values.where((item) => item.needsReorder).toList();
  }

  List<InventoryItem> getExpiringSoonItems() {
    return box.values.where((item) => item.isExpiringSoon).toList();
  }

  List<InventoryItem> getExpiredItems() {
    return box.values.where((item) => item.isExpired).toList();
  }

  List<InventoryItem> getItemsByStatus(InventoryStatus status) {
    return box.values.where((item) => item.status == status).toList();
  }

  List<InventoryItem> searchItems(String query) {
    final lowerQuery = query.toLowerCase();
    return box.values.where((item) {
      return item.productName.toLowerCase().contains(lowerQuery) ||
          item.sku.toLowerCase().contains(lowerQuery) ||
          (item.batchNumber?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.serialNumber?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Analytics
  double getTotalStockValue() {
    return box.values.fold(0.0, (sum, item) => sum + item.stockValue);
  }

  double getTotalPotentialRevenue() {
    return box.values.fold(0.0, (sum, item) => sum + item.potentialRevenue);
  }

  Map<String, double> getStockValueByLocation() {
    final Map<String, double> result = {};
    for (final item in box.values) {
      result[item.location] = (result[item.location] ?? 0) + item.stockValue;
    }
    return result;
  }

  Map<InventoryStatus, int> getItemCountByStatus() {
    final Map<InventoryStatus, int> result = {};
    for (final item in box.values) {
      result[item.status] = (result[item.status] ?? 0) + 1;
    }
    return result;
  }

  // Batch Operations
  InventoryItem? getItemByBatch(String batchNumber) {
    try {
      return box.values.firstWhere((item) => item.batchNumber == batchNumber);
    } catch (e) {
      return null;
    }
  }

  List<InventoryItem> getItemsByProduct(String productId) {
    return box.values.where((item) => item.productId == productId).toList();
  }

  // Serial Number Operations
  InventoryItem? getItemBySerialNumber(String serialNumber) {
    try {
      return box.values.firstWhere((item) => item.serialNumber == serialNumber);
    } catch (e) {
      return null;
    }
  }

  bool isSerialNumberUnique(String serialNumber) {
    return !box.values.any((item) => item.serialNumber == serialNumber);
  }

  // Stock Level Checks
  bool hasMinimumStock(String productId, double requiredQuantity) {
    final items = getItemsByProduct(productId);
    final totalStock = items.fold(0.0, (sum, item) => sum + item.currentStock);
    return totalStock >= requiredQuantity;
  }

  double getAvailableStock(String productId) {
    final items = getItemsByProduct(productId);
    return items.fold(0.0, (sum, item) => sum + item.currentStock);
  }
}
