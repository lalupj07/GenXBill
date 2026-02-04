import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/services/pdf_service.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class CreateInvoicePage extends ConsumerStatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  ConsumerState<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends ConsumerState<CreateInvoicePage> {
  // Helper to get Financial Year
  // Helper to get Financial Year
  String _calculateFinancialYear() {
    final now = DateTime.now();
    final year = now.month >= 4 ? now.year : now.year - 1;
    return '$year-${year + 1}';
  }

  // State Variables
  late String _financialYear;
  final List<String> _financialYears = [
    '2023-2024',
    '2024-2025',
    '2025-2026',
    '2026-2027'
  ];

  DateTime _invoiceDate = DateTime.now();
  TimeOfDay _invoiceTime = TimeOfDay.now();
  final _invoiceNumberController = TextEditingController();

  // State Variables

  // Billing
  Client? _selectedClient;
  final _billingAddressController = TextEditingController();
  final _billingAddressL2Controller = TextEditingController(); // Add_L2

  // Shipping
  bool _shippingSameAsBilling = true;
  Client? _selectedShippingClient;
  final _shippingAddressController = TextEditingController();
  final _shippingAddressL2Controller = TextEditingController();

  // Transport & Logistics
  final _transportModeController = TextEditingController();
  final _courierChargesController = TextEditingController();

  // Tax & Terms
  final _gstinController = TextEditingController();
  final _stateCodeController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  bool _isInterstate = false;

  // Order Info
  final _orderNoController = TextEditingController();
  DateTime _orderDate = DateTime.now();
  final _notesController = TextEditingController();

  // Items
  final List<Map<String, dynamic>> _items = [];

  // Temporary Item Entry Handlers
  Product? _selectedProduct;
  final _qtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _financialYear = _calculateFinancialYear();
    // Auto-generate invoice number (editable)
    _invoiceNumberController.text =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Default Payment Terms from Settings
    final settings = ref.read(settingsProvider);
    _paymentTermsController.text = settings.defaultPaymentTerms;
  }

  @override
  void dispose() {
    _billingAddressController.dispose();
    _billingAddressL2Controller.dispose();
    _shippingAddressController.dispose();
    _shippingAddressL2Controller.dispose();
    _transportModeController.dispose();
    _courierChargesController.dispose();
    _gstinController.dispose();
    _stateCodeController.dispose();
    _paymentTermsController.dispose();
    _orderNoController.dispose();
    _notesController.dispose();
    _qtyController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  void _onClientSelected(Client? client) {
    setState(() {
      _selectedClient = client;
      if (client != null) {
        _billingAddressController.text = client.address;
        _gstinController.text = client.taxId ?? '';
      }
    });
  }

  void _addItem() {
    if (_selectedProduct == null) return;

    final qty = double.tryParse(_qtyController.text) ?? 1.0;

    setState(() {
      _items.add({
        'id': _selectedProduct!.id,
        'desc': _selectedProduct!.name,
        'qty': qty,
        'price': _selectedProduct!.unitPrice,
        'hsn': _selectedProduct!.hsnCode,
        'unit': 'Pcs',
        'total': qty * _selectedProduct!.unitPrice
      });
      _selectedProduct = null;
      _qtyController.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
  double get _courier => double.tryParse(_courierChargesController.text) ?? 0.0;
  // Tax logic (Simple 18% or based on Interstate)
  double get _taxTotal => _subtotal * 0.18;
  double get _grandTotal => _subtotal + _taxTotal + _courier;

  Future<void> _saveAndPrint() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer.')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item.')));
      return;
    }

    final invoiceItems = _items
        .map((e) => InvoiceItem.create(
              description: e['desc'],
              quantity: num.parse(e['qty'].toString()).toDouble(),
              price: num.parse(e['price'].toString()).toDouble(),
              hsnCode: e['hsn'] ?? '',
              unit: e['unit'] ?? 'Pcs',
            ))
        .toList();

    final newInvoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: _invoiceNumberController.text, // User defined or auto
      clientName: _selectedClient!.name,
      date: _invoiceDate,
      dueDate: _invoiceDate.add(const Duration(days: 30)), // Default 30 days
      items: invoiceItems,
      status: InvoiceStatus.draft,
      notes: _notesController.text,
      poNumber: _orderNoController.text,
      poDate: _orderDate,
      transportMode: _transportModeController.text,
      courierCharges: _courier,
      gstin: _gstinController.text,
      stateCode: _stateCodeController.text,
      isInterstate: _isInterstate,
      shippingAddress: _shippingSameAsBilling
          ? _billingAddressController.text
          : _shippingAddressController.text,
    );

    // Save to Repository
    await ref.read(invoiceRepositoryProvider).addInvoice(newInvoice);

    // Update Inventory
    final productRepo = ref.read(productRepositoryProvider);
    for (var item in _items) {
      if (item['id'] != null) {
        await productRepo.decreaseStock(
            item['id'], double.parse(item['qty'].toString()));
      }
    }

    // Generate PDF Data
    final pdfData = await PdfService().generateInvoice(
      invoice: newInvoice,
      settings: ref.read(settingsProvider),
    );

    // Show Preview/Print
    await Printing.layoutPdf(onLayout: (format) async => pdfData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice Saved Successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientRepositoryProvider).getAllClients();

    return Scaffold(
      body: ThemeBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // --- HEADER ---
              _buildHeader(),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- ROW 1: ADDRESSES & LOGISTICS ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildBillingSection(clients)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInfoSection()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildShippingSection(clients)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- ROW 2: ITEM ENTRY ---
                      _buildItemEntrySection(),
                      const SizedBox(height: 24),

                      // --- ROW 3: ORDER INFO ---
                      _buildOrderInfoSection(),
                      const SizedBox(height: 24),

                      // --- ROW 4: GRID ---
                      _buildItemsTable(),
                    ],
                  ),
                ),
              ),

              // --- FOOTER ---
              _buildFooter(),
            ],
          ), // Column
        ), // Padding
      ), // ThemeBackground
    ); // Scaffold
  }

  Widget _buildHeader() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Go Back',
          ),
          // Invoice Number (Editable)
          Row(children: [
            const Text("INVOICE NO : ", style: TextStyle(color: Colors.grey)),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _invoiceNumberController,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ]),

          // Financial Year (Selectable)
          Row(children: [
            const Text("FY : ", style: TextStyle(color: Colors.grey)),
            DropdownButton<String>(
              value: _financialYear,
              underline: const SizedBox(),
              items: _financialYears
                  .map((y) => DropdownMenuItem(
                      value: y,
                      child: Text(y,
                          style: const TextStyle(fontWeight: FontWeight.bold))))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _financialYear = v);
              },
            ),
          ]),

          // Date & Time (Selectable)
          Row(children: [
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: _invoiceDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100));
                if (d != null) setState(() => _invoiceDate = d);
              },
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM/yyyy').format(_invoiceDate)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () async {
                final t = await showTimePicker(
                    context: context, initialTime: _invoiceTime);
                if (t != null) setState(() => _invoiceTime = t);
              },
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(_invoiceTime.format(context)),
                ],
              ),
            ),
          ]),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _invoiceNumberController.text =
                    'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                _items.clear();
                _selectedClient = null;
                _shippingSameAsBilling = true;
                _selectedShippingClient = null;
                _billingAddressController.clear();
                _billingAddressL2Controller.clear();
                _shippingAddressController.clear();
                _shippingAddressL2Controller.clear();
                _gstinController.clear();
                _transportModeController.clear();
              });
            },
            child: const Text("RESET"),
          )
        ],
      ),
    );
  }

  Widget _buildBillingSection(List<Client> clients) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BILLING ADDRESS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            return DropdownMenu<Client>(
              width: constraints.maxWidth,
              initialSelection: _selectedClient,
              enableFilter: true,
              label: const Text("Customer (Search)"),
              dropdownMenuEntries: clients
                  .map(
                      (c) => DropdownMenuEntry<Client>(value: c, label: c.name))
                  .toList(),
              onSelected: _onClientSelected,
            );
          }),
          const SizedBox(height: 8),
          TextField(
              controller: _billingAddressController,
              decoration: const InputDecoration(labelText: "Address"),
              maxLines: 2),
          const SizedBox(height: 8),
          TextField(
              controller: _billingAddressL2Controller,
              decoration: const InputDecoration(labelText: "Add_L2")),
          const SizedBox(height: 8),
          TextField(
              controller: _transportModeController,
              decoration:
                  const InputDecoration(labelText: "Mode of Transport")),
          const SizedBox(height: 8),
          TextField(
            controller: _courierChargesController,
            decoration: const InputDecoration(labelText: "Courier Charges"),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40), // Spacing to align with Dropdown
          TextField(
              controller: _gstinController,
              decoration: const InputDecoration(labelText: "GST No.")),
          const SizedBox(height: 8),
          TextField(
              controller: _stateCodeController,
              decoration: const InputDecoration(labelText: "State Code")),
          const SizedBox(height: 8),
          TextField(
              controller: _paymentTermsController,
              decoration: const InputDecoration(labelText: "Payment Terms")),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Tax Type: "),
              const SizedBox(width: 8),
              ChoiceChip(
                  label: const Text("Within State"),
                  selected: !_isInterstate,
                  onSelected: (v) => setState(() => _isInterstate = false)),
              const SizedBox(width: 8),
              ChoiceChip(
                  label: const Text("Interstate"),
                  selected: _isInterstate,
                  onSelected: (v) => setState(() => _isInterstate = true)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildShippingSection(List<Client> clients) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SHIPPING ADDRESS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Checkbox(
                  value: _shippingSameAsBilling,
                  onChanged: (v) {
                    setState(() => _shippingSameAsBilling = v ?? true);
                  })
            ],
          ),
          const Text("Same as billing",
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          if (!_shippingSameAsBilling) ...[
            DropdownButtonFormField<Client>(
              key: ValueKey(_selectedShippingClient),
              initialValue: _selectedShippingClient,
              items: clients
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedShippingClient = v;
                if (v != null) _shippingAddressController.text = v.address;
              }),
              decoration: const InputDecoration(labelText: "Customer"),
              isExpanded: true,
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _shippingAddressController,
                decoration: const InputDecoration(labelText: "Address"),
                maxLines: 2),
            const SizedBox(height: 8),
            TextField(
                controller: _shippingAddressL2Controller,
                decoration: const InputDecoration(labelText: "Add_L2")),
          ] else ...[
            const SizedBox(height: 100),
            const Center(
                child: Icon(Icons.copy_all, size: 48, color: Colors.grey)),
          ]
        ],
      ),
    );
  }

  Widget _buildItemEntrySection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(builder: (context, constraints) {
              final products =
                  ref.read(productRepositoryProvider).getActiveProducts();
              return DropdownMenu<Product>(
                width: constraints.maxWidth,
                enableFilter: true,
                label: const Text("Product (Search)"),
                dropdownMenuEntries: products
                    .map((p) =>
                        DropdownMenuEntry<Product>(value: p, label: p.name))
                    .toList(),
                onSelected: (p) {
                  if (p != null) {
                    setState(() => _selectedProduct = p);
                  }
                },
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: "Qty"),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text("Add Item"),
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: AppTheme.primaryColor),
          )
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 2),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                TextField(
                    controller: _orderNoController,
                    decoration: const InputDecoration(labelText: "Order No.")),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _orderDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (d != null) setState(() => _orderDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: "Order Date",
                        suffixIcon: Icon(Icons.calendar_today, size: 16)),
                    child: Text(DateFormat('dd/MM/yyyy').format(_orderDate)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withValues(alpha: 0.05)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8))),
            child: const Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text("Sl. No.",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 4,
                    child: Text("Item",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("HSNCode",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text("Qty",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text("Unit",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Rate",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Total",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text("Action",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Body
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                  child: Text("No items added",
                      style: TextStyle(color: Colors.grey))),
            ),

          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1)))),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text("${i + 1}")),
                  Expanded(flex: 4, child: Text(item['desc'])),
                  Expanded(flex: 2, child: Text(item['hsn'] ?? '-')),
                  Expanded(flex: 1, child: Text(item['qty'].toString())),
                  Expanded(flex: 1, child: Text(item['unit'] ?? 'Pcs')),
                  Expanded(flex: 2, child: Text(item['price'].toString())),
                  Expanded(
                      flex: 2,
                      child: Text(
                          (item['qty'] * item['price']).toStringAsFixed(2))),
                  Expanded(
                      flex: 1,
                      child: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 16),
                          onPressed: () => _removeItem(i))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Subtotal: ${_subtotal.toStringAsFixed(2)}"),
              Text("Courier: ${_courier.toStringAsFixed(2)}"),
              if (_isInterstate)
                Text("IGST (18%): ${_taxTotal.toStringAsFixed(2)}")
              else ...[
                Text("CGST (9%): ${(_taxTotal / 2).toStringAsFixed(2)}"),
                Text("SGST (9%): ${(_taxTotal / 2).toStringAsFixed(2)}"),
              ],
              const SizedBox(height: 8),
              Text("GRAND TOTAL: ${_grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: _saveAndPrint,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text("PRINT / SAVE", style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }
}
