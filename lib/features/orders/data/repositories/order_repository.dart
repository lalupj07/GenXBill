import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/orders/data/models/order_model.dart';

class OrderRepository {
  final Box<OrderModel> _box;

  OrderRepository(this._box);

  List<OrderModel> getAllOrders() {
    return _box.values.toList();
  }

  Future<void> addOrder(OrderModel order) async {
    await _box.put(order.id, order);
  }

  Future<void> updateOrder(OrderModel order) async {
    await _box.put(order.id, order);
  }

  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
  }

  List<OrderModel> getOrdersByType(OrderType type) {
    return _box.values.where((o) => o.type == type).toList();
  }
}

final orderBoxProvider = Provider<Box<OrderModel>>((ref) {
  return Hive.box<OrderModel>('orders');
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final box = ref.watch(orderBoxProvider);
  return OrderRepository(box);
});
