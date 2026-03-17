import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/providers/navigation_provider.dart';
import 'package:genx_bill/features/orders/data/models/order_model.dart';
import 'package:genx_bill/features/orders/data/repositories/order_repository.dart';
import 'package:genx_bill/features/orders/presentation/pages/order_detail_page.dart';
import 'package:genx_bill/features/orders/presentation/widgets/create_order_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  OrderType? _filterType;

  @override
  Widget build(BuildContext context) {
    final orderBox = ref.watch(orderBoxProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            ref.read(navigationProvider.notifier).state = 0;
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Orders',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Text(
                      'Manage your sales and purchase orders',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateOrderDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New Order'),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderType.sales, 'Sales'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderType.purchase, 'Purchase'),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: orderBox.listenable(),
                builder: (context, Box<OrderModel> box, _) {
                  var orders = box.values.toList();
                  if (_filterType != null) {
                    orders =
                        orders.where((o) => o.type == _filterType).toList();
                  }

                  if (orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(OrderType? type, String label) {
    final isSelected = _filterType == type;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() => _filterType = type);
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey.withAlpha(128)),
          const SizedBox(height: 16),
          const Text('No orders found',
              style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.05),
      child: ListTile(
        title: Text(order.orderNumber,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${order.clientName} • ${DateFormat.yMMMd().format(order.date)}'),
            if (order.assignedEmployeeName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Assigned to: ${order.assignedEmployeeName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.source == OrderSource.whatsapp)
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.chat_bubble_outline,
                    color: Colors.green, size: 20),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateOrderDialog(),
    );
  }
}
