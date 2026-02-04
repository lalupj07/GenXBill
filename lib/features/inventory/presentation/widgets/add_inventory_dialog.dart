import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/providers/inventory_providers.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';

class AddInventoryDialog extends ConsumerStatefulWidget {
  const AddInventoryDialog({super.key});

  @override
  ConsumerState<AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends ConsumerState<AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQtyController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _locationController = TextEditingController(text: 'Main Warehouse');
  final _batchController = TextEditingController();
  final _serialController = TextEditingController();
  DateTime? _expiryDate;

  @override
  void dispose() {
    _skuController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _reorderPointController.dispose();
    _reorderQtyController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _locationController.dispose();
    _batchController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productRepositoryProvider).getAllProducts();

    return AlertDialog(
      title: const Text('Add Inventory Item'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  decoration:
                      const InputDecoration(labelText: 'Select Product'),
                  items: products.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                      if (value != null) {
                        _skuController.text = value.sku;
                        _costPriceController.text = value.unitPrice.toString();
                        _sellingPriceController.text =
                            (value.unitPrice * 1.2).toStringAsFixed(2);
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(labelText: 'SKU'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration:
                            const InputDecoration(labelText: 'Current Stock'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration:
                            const InputDecoration(labelText: 'Min Stock'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _reorderPointController,
                        decoration:
                            const InputDecoration(labelText: 'Reorder Point'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _reorderQtyController,
                        decoration:
                            const InputDecoration(labelText: 'Reorder Qty'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        decoration:
                            const InputDecoration(labelText: 'Cost Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration:
                            const InputDecoration(labelText: 'Selling Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _batchController,
                        decoration: const InputDecoration(labelText: 'Batch #'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListTile(
                        title: Text(_expiryDate == null
                            ? 'Expiry Date'
                            : 'Expires: ${_expiryDate!.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) setState(() => _expiryDate = date);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final settings = ref.read(settingsProvider);
      final item = InventoryItem.create(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        sku: _skuController.text,
        currentStock: double.parse(_stockController.text),
        minimumStock: double.parse(_minStockController.text),
        reorderPoint: double.parse(_reorderPointController.text),
        reorderQuantity: double.parse(_reorderQtyController.text),
        location: _locationController.text,
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        batchNumber:
            _batchController.text.isEmpty ? null : _batchController.text,
        serialNumber:
            _serialController.text.isEmpty ? null : _serialController.text,
        expiryDate: _expiryDate,
        updatedBy: settings.companyName,
      );

      await ref.read(inventoryRepositoryProvider).addItem(item);
      if (mounted) Navigator.pop(context);
    }
  }
}
