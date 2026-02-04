import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/models/user_role.dart';
import 'package:genx_bill/core/services/logger_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:genx_bill/core/widgets/main_layout.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productBox = ref.watch(productBoxProvider);

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
                          tooltip: 'Back to Home',
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Inventory & Products',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Text(
                      'Manage products and stock levels',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.1),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add Product'),
                ).animate().fadeIn().slideX(begin: 0.1),
              ],
            ),
            const SizedBox(height: 16),
            _buildLowStockAlerts(productBox.values.toList()),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products by name or HSN...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.surfaceColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: productBox.listenable(),
                builder: (context, Box<Product> box, _) {
                  var products = box.values.toList();

                  if (_searchQuery.isNotEmpty) {
                    products = products.where((product) {
                      return product.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          product.hsnCode
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          product.sku
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          product.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No products yet'
                                : 'No products found',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                    ).animate().fadeIn();
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product, index);
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

  Widget _buildLowStockAlerts(List<Product> products) {
    final lowStockItems =
        products.where((p) => p.stockQuantity <= p.minStockLevel).toList();
    if (lowStockItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${lowStockItems.length} products are below minimum stock level! Consider reordering soon.',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = ''); // Reset search
            },
            child:
                const Text('View All', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildProductCard(Product product, int index) {
    final isLowStock = product.stockQuantity <= product.minStockLevel;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2,
                    color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.hsnCode.isNotEmpty)
                      Text(
                        'HSN: ${product.hsnCode}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    if (product.sku.isNotEmpty && product.hsnCode.isEmpty)
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                  const PopupMenuItem(value: 'history', child: Text('History')),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditProductDialog(context, product);
                  } else if (value == 'delete') {
                    _deleteProduct(product);
                  } else if (value == 'history') {
                    _showProductHistory(context, product);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isEmpty
                ? 'No description'
                : product.description,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${product.unitPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: isLowStock ? Colors.red : Colors.green),
                ),
                child: Text(
                  'Qty: ${product.stockQuantity.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final skuController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    final minStockController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name *'))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextField(
                            controller: skuController,
                            decoration:
                                const InputDecoration(labelText: 'HSN/SKU'))),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                            labelText: 'Price *',
                            prefixIcon: Icon(Icons.attach_money)),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Qty'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: minStockController,
                        decoration: const InputDecoration(labelText: 'Min Qty'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final product = Product.create(
                  name: nameController.text,
                  description: descController.text,
                  unitPrice: double.tryParse(priceController.text) ?? 0.0,
                  sku: skuController.text,
                  stockQuantity: double.tryParse(stockController.text) ?? 0.0,
                  minStockLevel:
                      double.tryParse(minStockController.text) ?? 0.0,
                );
                ref.read(productRepositoryProvider).addProduct(product);

                ref
                    .read(loggerServiceProvider)
                    .log('Add Product', 'Added new product: ${product.name}');

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully!')),
                );
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController =
        TextEditingController(text: product.unitPrice.toString());
    final skuController = TextEditingController(text: product.sku);
    final stockController =
        TextEditingController(text: product.stockQuantity.toInt().toString());
    final minStockController =
        TextEditingController(text: product.minStockLevel.toInt().toString());

    final userRole = ref.read(settingsProvider).currentUserRole;
    final canEditPrice = userRole.canEditPrice;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!canEditPrice)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Price editing is restricted for your role.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name *'))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextField(
                            controller: skuController,
                            decoration:
                                const InputDecoration(labelText: 'HSN/SKU'))),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        enabled: canEditPrice,
                        decoration: InputDecoration(
                            labelText: 'Price *',
                            prefixIcon: const Icon(Icons.attach_money),
                            fillColor: canEditPrice ? null : Colors.white10,
                            filled: !canEditPrice),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Qty'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: minStockController,
                        decoration: const InputDecoration(labelText: 'Min Qty'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Async
              if (nameController.text.isNotEmpty &&
                  (priceController.text.isNotEmpty || !canEditPrice)) {
                final newStock = double.tryParse(stockController.text) ?? 0.0;
                final oldStock = product.stockQuantity;

                // Update basic info first
                final updatedProduct = product.copyWith(
                  name: nameController.text,
                  description: descController.text,
                  unitPrice: double.tryParse(priceController.text) ??
                      product.unitPrice,
                  sku: skuController.text,
                  // Don't update stock here if it changed, handle separately for audit
                  minStockLevel:
                      double.tryParse(minStockController.text) ?? 0.0,
                );

                final repo = ref.read(productRepositoryProvider);
                await repo.updateProduct(updatedProduct);

                // Handle Stock Adjustment
                if (newStock != oldStock) {
                  final currentUser = ref
                      .read(settingsProvider)
                      .currentUserRole
                      .name; // Simple role name as user
                  await repo.adjustStock(product.id, newStock,
                      notes: "Manual adjustment", performedBy: currentUser);
                }

                ref
                    .read(loggerServiceProvider)
                    .log('Edit Product', 'Updated product: ${product.name}');

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Product updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showProductHistory(BuildContext context, Product product) {
    final transactions = ref
        .read(productRepositoryProvider)
        .getTransactionsForProduct(product.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Stock History: ${product.name}'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: transactions.isEmpty
              ? const Center(child: Text('No transaction history.'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPositive = tx.quantity >= 0;
                    return ListTile(
                      leading: Icon(
                        isPositive
                            ? Icons.arrow_circle_down
                            : Icons.arrow_circle_up, // In/Out visual
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      title: Text(tx.type.name.toUpperCase()),
                      subtitle: Text(
                        '${DateFormat('dd MMM yyyy HH:mm').format(tx.date)}\n${tx.notes ?? ''} (${tx.performedBy})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${isPositive ? '+' : ''}${tx.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(productRepositoryProvider).deleteProduct(product.id);
              ref
                  .read(loggerServiceProvider)
                  .log('Delete Product', 'Deleted product: ${product.name}');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully!')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
