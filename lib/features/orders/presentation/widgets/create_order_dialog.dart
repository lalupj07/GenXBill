import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/orders/data/models/order_model.dart';
import 'package:genx_bill/features/orders/data/repositories/order_repository.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;
import 'package:uuid/uuid.dart';

class CreateOrderDialog extends ConsumerStatefulWidget {
  const CreateOrderDialog({super.key});

  @override
  ConsumerState<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends ConsumerState<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController(
      text: 'ORD-${DateTime.now().millisecondsSinceEpoch}');
  Client? _selectedClient;
  OrderType _orderType = OrderType.sales;
  OrderSource _orderSource = OrderSource.manual;
  hr.HREmployee? _assignedEmployee;
  final List<OrderItem> _items = [];
  final _notesController = TextEditingController();

  // Item form controllers
  Product? _selectedProduct;
  final _prodSearchController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _orderNumberController.dispose();
    _notesController.dispose();
    _prodSearchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addItem() {
    if ((_selectedProduct == null && _prodSearchController.text.isEmpty) ||
        _qtyController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    setState(() {
      _items.add(OrderItem(
        productId: _selectedProduct?.id ?? const Uuid().v4(),
        productName: _selectedProduct?.name ?? _prodSearchController.text,
        quantity: double.tryParse(_qtyController.text) ?? 0,
        unitPrice: double.tryParse(_priceController.text) ?? 0,
      ));
      _selectedProduct = null;
      _prodSearchController.clear();
      _qtyController.clear();
      _priceController.clear();
    });
  }

  void _saveOrder() {
    if (!_formKey.currentState!.validate() ||
        _selectedClient == null ||
        _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all details and add at least one item.')),
      );
      return;
    }

    final newOrder = OrderModel.create(
      orderNumber: _orderNumberController.text,
      clientId: _selectedClient!.id,
      clientName: _selectedClient!.name,
      type: _orderType,
      items: _items,
      notes: _notesController.text,
      source: _orderSource,
      assignedEmployeeId: _assignedEmployee?.id,
      assignedEmployeeName: _assignedEmployee?.name,
    );

    ref.read(orderRepositoryProvider).addOrder(newOrder);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientRepositoryProvider).getAllClients();
    final employees = ref.watch(activeEmployeesProvider);

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Order', style: AppTheme.textTheme.titleLarge),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _orderNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Order Number'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<OrderType>(
                      initialValue: _orderType,
                      decoration:
                          const InputDecoration(labelText: 'Order Type'),
                      items: OrderType.values.map((t) {
                        return DropdownMenuItem(
                            value: t, child: Text(t.name.toUpperCase()));
                      }).toList(),
                      onChanged: (v) => setState(() => _orderType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<OrderSource>(
                      initialValue: _orderSource,
                      decoration:
                          const InputDecoration(labelText: 'Order Source'),
                      items: OrderSource.values.map((s) {
                        IconData icon;
                        switch (s) {
                          case OrderSource.whatsapp:
                            icon = Icons.chat;
                            break;
                          case OrderSource.email:
                            icon = Icons.email;
                            break;
                          case OrderSource.phone:
                            icon = Icons.phone;
                            break;
                          case OrderSource.website:
                            icon = Icons.language;
                            break;
                          default:
                            icon = Icons.create;
                        }
                        return DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Icon(icon, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(s.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _orderSource = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<hr.HREmployee?>(
                      initialValue: _assignedEmployee,
                      decoration: const InputDecoration(labelText: 'Assign To'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Not Assigned'),
                        ),
                        ...employees.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.name),
                          );
                        }),
                      ],
                      onChanged: (v) => setState(() => _assignedEmployee = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Autocomplete<Client>(
                displayStringForOption: (c) => c.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Client>.empty();
                  }
                  return clients.where((c) {
                    return c.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()) ||
                        c.email
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (v) => setState(() => _selectedClient = v),
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Select Client/Supplier (Search Name/Email) *',
                      prefixIcon: Icon(Icons.person_search),
                    ),
                    validator: (v) =>
                        _selectedClient == null ? 'Select a client' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Autocomplete<Product>(
                      displayStringForOption: (p) => "${p.name} [ID: ${p.sku}]",
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<Product>.empty();
                        }
                        final allProducts = ref
                            .read(productRepositoryProvider)
                            .getAllProducts();
                        return allProducts.where((p) {
                          final query = textEditingValue.text.toLowerCase();
                          return p.name.toLowerCase().contains(query) ||
                              p.sku.toLowerCase().contains(query) ||
                              p.hsnCode.toLowerCase().contains(query) ||
                              p.id.toLowerCase().contains(query);
                        });
                      },
                      onSelected: (p) {
                        setState(() {
                          _selectedProduct = p;
                          _priceController.text = p.unitPrice.toString();
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Search Name, ID, SKU or HSN',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            if (_selectedProduct != null &&
                                val != _selectedProduct!.name) {
                              setState(() => _selectedProduct = null);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      decoration: const InputDecoration(hintText: 'Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(hintText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryColor, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.productName),
                        subtitle:
                            Text('Qty: ${item.quantity} x ₹${item.unitPrice}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () =>
                              setState(() => _items.removeAt(index)),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveOrder,
                    child: const Text('Create Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
