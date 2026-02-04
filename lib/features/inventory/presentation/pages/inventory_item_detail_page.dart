import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class InventoryItemDetailPage extends ConsumerWidget {
  final InventoryItem item;
  const InventoryItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(item.productName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection('Overview', [
              _buildDetailItem('Product Name', item.productName),
              _buildDetailItem('SKU', item.sku),
              _buildDetailItem('Location', item.location),
              if (item.warehouse != null)
                _buildDetailItem('Warehouse', item.warehouse!),
              _buildDetailItem('Status', item.status.name.toUpperCase()),
            ]),
            const SizedBox(height: 24),
            _buildDetailSection('Stock Levels', [
              _buildDetailItem('Current Stock', '${item.currentStock} units'),
              _buildDetailItem('Minimum Stock', '${item.minimumStock} units'),
              _buildDetailItem('Reorder Point', '${item.reorderPoint} units'),
              _buildDetailItem(
                  'Reorder Quantity', '${item.reorderQuantity} units'),
            ]),
            const SizedBox(height: 24),
            _buildDetailSection('Financials', [
              _buildDetailItem(
                  'Cost Price', currencyFormat.format(item.costPrice)),
              _buildDetailItem(
                  'Selling Price', currencyFormat.format(item.sellingPrice)),
              _buildDetailItem(
                  'Stock Value', currencyFormat.format(item.stockValue)),
              _buildDetailItem(
                  'Profit Margin', currencyFormat.format(item.profitMargin)),
            ]),
            const SizedBox(height: 24),
            _buildDetailSection('Additional Info', [
              if (item.batchNumber != null)
                _buildDetailItem('Batch Number', item.batchNumber!),
              if (item.serialNumber != null)
                _buildDetailItem('Serial Number', item.serialNumber!),
              if (item.expiryDate != null)
                _buildDetailItem(
                    'Expiry Date', dateFormat.format(item.expiryDate!)),
              _buildDetailItem(
                  'Last Updated', dateFormat.format(item.lastUpdated)),
              _buildDetailItem('Updated By', item.updatedBy),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
