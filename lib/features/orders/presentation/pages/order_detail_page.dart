import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/features/orders/data/models/order_model.dart';
import 'package:genx_bill/features/orders/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: Text('Order ${order.orderNumber}'),
              actions: [
                _buildStatusDropdown(context, ref),
                const SizedBox(width: 8),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildClientInfo(context),
                    const SizedBox(height: 24),
                    _buildItemsList(context),
                    const SizedBox(height: 24),
                    _buildSummary(context),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildNotes(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<OrderStatus>(
      initialValue: order.status,
      onSelected: (status) async {
        final updatedOrder = order.copyWith(status: status);
        await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Order status updated to ${status.name.toUpperCase()}')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(order.status.name.toUpperCase()),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => OrderStatus.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Text(s.name.toUpperCase()),
        );
      }).toList(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.type == OrderType.sales
                        ? 'SALES ORDER'
                        : 'PURCHASE ORDER',
                    style: TextStyle(
                      color: order.type == OrderType.sales
                          ? Colors.blue
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMMd().format(order.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TOTAL AMOUNT',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  order.type == OrderType.sales ? Icons.person : Icons.business,
                  color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              Text(
                order.type == OrderType.sales
                    ? 'CUSTOMER DETAILS'
                    : 'SUPPLIER DETAILS',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(order.clientName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('ID: c1',
              style: TextStyle(color: Colors.grey)), // Placeholder ID
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: AppTheme.secondaryColor),
              SizedBox(width: 8),
              Text('ORDER ITEMS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ],
          ),
          const Divider(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 32, color: Colors.white10),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                            'PID: ${item.productId.substring(0, 8).toUpperCase()}', // Showing short ID or SKU
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Qty: ${item.quantity} × ₹${item.unitPrice}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSummaryRow(
              'Subtotal', '₹${order.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax', '₹0.00'),
          const Divider(height: 32),
          _buildSummaryRow(
              'Grand Total', '₹${order.totalAmount.toStringAsFixed(2)}',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isTotal ? Colors.white : Colors.grey,
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: isTotal ? AppTheme.primaryColor : Colors.white,
                fontSize: isTotal ? 22 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.bold)),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NOTES',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(order.notes!, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
