import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/inventory/data/models/reorder_suggestion_model.dart';
import 'package:genx_bill/features/inventory/data/repositories/inventory_repository.dart';
import 'package:genx_bill/features/inventory/data/repositories/stock_movement_repository.dart';
import 'package:genx_bill/features/inventory/services/inventory_service.dart';

// Repositories
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

final stockMovementRepositoryProvider =
    Provider<StockMovementRepository>((ref) {
  return StockMovementRepository();
});

// Service
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(
    inventoryRepo: ref.read(inventoryRepositoryProvider),
    movementRepo: ref.read(stockMovementRepositoryProvider),
  );
});

// State Providers
final inventoryItemsProvider =
    StateNotifierProvider<InventoryItemsNotifier, List<InventoryItem>>((ref) {
  return InventoryItemsNotifier(ref.read(inventoryRepositoryProvider));
});

final stockMovementsProvider =
    StateNotifierProvider<StockMovementsNotifier, List<StockMovement>>((ref) {
  return StockMovementsNotifier(ref.read(stockMovementRepositoryProvider));
});

final reorderSuggestionsProvider =
    StateNotifierProvider<ReorderSuggestionsNotifier, List<ReorderSuggestion>>(
        (ref) {
  return ReorderSuggestionsNotifier(ref.read(inventoryServiceProvider));
});

// Filtered Providers
final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.where((item) => item.isLowStock).toList();
});

final outOfStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.where((item) => item.isOutOfStock).toList();
});

final reorderNeededItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.where((item) => item.needsReorder).toList();
});

final expiringSoonItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryItemsProvider);
  return items.where((item) => item.isExpiringSoon).toList();
});

// Analytics Provider
final inventoryAnalyticsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.read(inventoryServiceProvider);
  return service.getInventoryAnalytics();
});

// Notifiers
class InventoryItemsNotifier extends StateNotifier<List<InventoryItem>> {
  final InventoryRepository repository;

  InventoryItemsNotifier(this.repository) : super([]) {
    loadItems();
  }

  void loadItems() {
    state = repository.getAllItems();
  }

  Future<void> addItem(InventoryItem item) async {
    await repository.addItem(item);
    loadItems();
  }

  Future<void> updateItem(InventoryItem item) async {
    await repository.updateItem(item);
    loadItems();
  }

  Future<void> deleteItem(String id) async {
    await repository.deleteItem(id);
    loadItems();
  }

  void searchItems(String query) {
    if (query.isEmpty) {
      loadItems();
    } else {
      state = repository.searchItems(query);
    }
  }

  void filterByLocation(String location) {
    state = repository.getItemsByLocation(location);
  }

  void filterByStatus(InventoryStatus status) {
    state = repository.getItemsByStatus(status);
  }
}

class StockMovementsNotifier extends StateNotifier<List<StockMovement>> {
  final StockMovementRepository repository;

  StockMovementsNotifier(this.repository) : super([]) {
    loadMovements();
  }

  void loadMovements() {
    state = repository.getAllMovements();
  }

  Future<void> addMovement(StockMovement movement) async {
    await repository.addMovement(movement);
    loadMovements();
  }

  void filterByProduct(String productId) {
    state = repository.getMovementsByProduct(productId);
  }

  void filterByType(MovementType type) {
    state = repository.getMovementsByType(type);
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    state = repository.getMovementsByDateRange(startDate, endDate);
  }

  void loadRecent({int limit = 50}) {
    state = repository.getRecentMovements(limit: limit);
  }
}

class ReorderSuggestionsNotifier
    extends StateNotifier<List<ReorderSuggestion>> {
  final InventoryService service;

  ReorderSuggestionsNotifier(this.service) : super([]) {
    generateSuggestions();
  }

  void generateSuggestions() {
    state = service.generateReorderSuggestions();
  }

  void filterByPriority(SuggestionPriority priority) {
    final allSuggestions = service.generateReorderSuggestions();
    state = allSuggestions.where((s) => s.priority == priority).toList();
  }

  void filterUrgent() {
    final allSuggestions = service.generateReorderSuggestions();
    state = allSuggestions.where((s) => s.isUrgent).toList();
  }
}
