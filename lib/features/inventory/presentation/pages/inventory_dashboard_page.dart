import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/features/inventory/providers/inventory_providers.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:intl/intl.dart';
import 'package:genx_bill/features/inventory/presentation/widgets/add_inventory_dialog.dart';
import 'package:genx_bill/features/inventory/presentation/pages/inventory_item_detail_page.dart';

class InventoryDashboardPage extends ConsumerStatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  ConsumerState<InventoryDashboardPage> createState() =>
      _InventoryDashboardPageState();
}

class _InventoryDashboardPageState
    extends ConsumerState<InventoryDashboardPage> {
  InventoryStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(inventoryAnalyticsProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final outOfStockItems = ref.watch(outOfStockItemsProvider);
    final reorderNeeded = ref.watch(reorderNeededItemsProvider);

    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Analytics Cards
            _buildAnalyticsCards(analytics, lowStockItems.length,
                outOfStockItems.length, reorderNeeded.length),

            // Search & Filter
            _buildSearchAndFilter(),

            // Inventory List
            Expanded(
              child: _buildInventoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInventoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.2),
                  AppTheme.secondaryColor.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.inventory_2,
                color: AppTheme.primaryColor, size: 32),
          ).animate().scale(delay: 200.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Management',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideX(begin: -0.2),
                const Text(
                  'Real-time stock tracking & intelligent forecasting',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(inventoryItemsProvider.notifier).loadItems();
              ref
                  .read(reorderSuggestionsProvider.notifier)
                  .generateSuggestions();
            },
            tooltip: 'Refresh',
          ).animate().rotate(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics, int lowStock,
      int outOfStock, int reorderNeeded) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 140,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildAnalyticsCard(
              'Total Stock Value',
              currencyFormat.format(analytics['totalStockValue'] ?? 0),
              Icons.account_balance_wallet,
              Colors.blue,
              'Current inventory worth',
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            const SizedBox(width: 16),
            _buildAnalyticsCard(
              'Potential Revenue',
              currencyFormat.format(analytics['potentialRevenue'] ?? 0),
              Icons.trending_up,
              Colors.green,
              'If all stock sold',
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(width: 16),
            _buildAnalyticsCard(
              'Low Stock Alerts',
              '$lowStock items',
              Icons.warning_amber,
              Colors.orange,
              'Need attention',
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(width: 16),
            _buildAnalyticsCard(
              'Out of Stock',
              '$outOfStock items',
              Icons.error_outline,
              Colors.red,
              'Urgent reorder',
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(width: 16),
            _buildAnalyticsCard(
              'Reorder Needed',
              '$reorderNeeded items',
              Icons.shopping_cart,
              Colors.purple,
              'Suggested orders',
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, SKU, batch, or serial number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
              ),
              onChanged: (value) {
                ref.read(inventoryItemsProvider.notifier).searchItems(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<InventoryStatus?>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Status')),
                ...InventoryStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                if (value == null) {
                  ref.read(inventoryItemsProvider.notifier).loadItems();
                } else {
                  ref
                      .read(inventoryItemsProvider.notifier)
                      .filterByStatus(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    final items = ref.watch(inventoryItemsProvider);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No inventory items found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first item to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildInventoryCard(item)
            .animate(delay: (index * 50).ms)
            .fadeIn()
            .slideX(begin: 0.2);
      },
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final stockPercentage = item.minimumStock > 0
        ? (item.currentStock / item.minimumStock).clamp(0.0, 1.0)
        : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Product Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(item.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory,
                      color: _getStatusColor(item.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${item.sku} • ${item.location}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (item.batchNumber != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Batch: ${item.batchNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(item.status),
                ],
              ),
              const SizedBox(height: 16),

              // Stock Level Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${item.currentStock.toStringAsFixed(0)} units',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Min: ${item.minimumStock.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: stockPercentage,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStockLevelColor(stockPercentage),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Financial Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Cost',
                      currencyFormat.format(item.costPrice),
                      Icons.attach_money,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Selling',
                      currencyFormat.format(item.sellingPrice),
                      Icons.sell,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Value',
                      currencyFormat.format(item.stockValue),
                      Icons.account_balance,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              // Warnings
              if (item.isExpiringSoon || item.needsReorder) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (item.needsReorder)
                      _buildWarningChip(
                        'Reorder Needed',
                        Icons.shopping_cart,
                        Colors.orange,
                      ),
                    if (item.isExpiringSoon)
                      _buildWarningChip(
                        'Expiring Soon',
                        Icons.access_time,
                        Colors.red,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InventoryStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.inStock:
        return Colors.green;
      case InventoryStatus.lowStock:
        return Colors.orange;
      case InventoryStatus.outOfStock:
        return Colors.red;
      case InventoryStatus.reorderNeeded:
        return Colors.purple;
      case InventoryStatus.discontinued:
        return Colors.grey;
      case InventoryStatus.damaged:
        return Colors.brown;
      case InventoryStatus.expired:
        return Colors.red.shade900;
    }
  }

  String _getStatusLabel(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.inStock:
        return 'In Stock';
      case InventoryStatus.lowStock:
        return 'Low Stock';
      case InventoryStatus.outOfStock:
        return 'Out of Stock';
      case InventoryStatus.reorderNeeded:
        return 'Reorder';
      case InventoryStatus.discontinued:
        return 'Discontinued';
      case InventoryStatus.damaged:
        return 'Damaged';
      case InventoryStatus.expired:
        return 'Expired';
    }
  }

  Color _getStockLevelColor(double percentage) {
    if (percentage <= 0.2) return Colors.red;
    if (percentage <= 0.5) return Colors.orange;
    return Colors.green;
  }

  void _showItemDetails(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryItemDetailPage(item: item),
      ),
    );
  }

  void _showAddInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddInventoryDialog(),
    ).then((_) {
      ref.read(inventoryItemsProvider.notifier).loadItems();
    });
  }
}
