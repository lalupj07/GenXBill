import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';

import 'package:genx_bill/features/products/data/models/inventory_transaction.dart';
import 'package:uuid/uuid.dart';

final productBoxProvider = Provider<Box<Product>>((ref) {
  return Hive.box<Product>('products');
});

final transactionBoxProvider = Provider<Box<InventoryTransaction>>((ref) {
  return Hive.box<InventoryTransaction>('inventory_transactions');
});

class ProductRepository {
  final Box<Product> _box;
  final Box<InventoryTransaction> _transactionBox;

  ProductRepository(this._box, this._transactionBox);

  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  List<Product> getAllProducts() {
    return _box.values.toList();
  }

  List<Product> getActiveProducts() {
    return _box.values.where((p) => p.isActive).toList();
  }

  Future<void> decreaseStock(String productId, double quantity,
      {String? notes, String? performedBy}) async {
    final product = _box.get(productId);
    if (product != null) {
      final newStock = product.stockQuantity - quantity;
      final updatedProduct =
          product.copyWith(stockQuantity: newStock < 0 ? 0.0 : newStock);
      await updateProduct(updatedProduct);

      // Log transaction
      await _logTransaction(
        productId: productId,
        productName: product.name,
        type: TransactionType.sale, // Default to sale for decrease
        quantity: -quantity, // Negative for out
        notes: notes ?? 'Stock decrease',
        performedBy: performedBy,
      );
    }
  }

  Future<void> increaseStock(String productId, double quantity,
      {String? notes, String? performedBy}) async {
    final product = _box.get(productId);
    if (product != null) {
      final newStock = product.stockQuantity + quantity;
      final updatedProduct = product.copyWith(stockQuantity: newStock);
      await updateProduct(updatedProduct);

      // Log transaction
      await _logTransaction(
        productId: productId,
        productName: product.name,
        type: TransactionType.purchase, // Default to purchase for increase
        quantity: quantity,
        notes: notes ?? 'Stock increase',
        performedBy: performedBy,
      );
    }
  }

  Future<void> adjustStock(String productId, double actualQuantity,
      {String? notes, String? performedBy}) async {
    final product = _box.get(productId);
    if (product != null) {
      final diff = actualQuantity - product.stockQuantity;
      if (diff == 0) return;

      final updatedProduct = product.copyWith(stockQuantity: actualQuantity);
      await updateProduct(updatedProduct);

      await _logTransaction(
        productId: productId,
        productName: product.name,
        type: TransactionType.adjustment,
        quantity: diff,
        notes: notes ?? 'Stock adjustment',
        performedBy: performedBy,
      );
    }
  }

  Future<void> _logTransaction({
    required String productId,
    required String productName,
    required TransactionType type,
    required double quantity,
    String? notes,
    String? performedBy,
  }) async {
    final transaction = InventoryTransaction(
      id: const Uuid().v4(),
      productId: productId,
      productName: productName,
      type: type,
      quantity: quantity,
      date: DateTime.now(),
      notes: notes,
      performedBy: performedBy ?? 'System',
    );
    await _transactionBox.put(transaction.id, transaction);
  }

  List<InventoryTransaction> getTransactionsForProduct(String productId) {
    return _transactionBox.values
        .where((t) => t.productId == productId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final box = ref.watch(productBoxProvider);
  final transactionBox = ref.watch(transactionBoxProvider);
  return ProductRepository(box, transactionBox);
});
