import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:genx_bill/core/services/pdf_service.dart';

class ClientLedgerPage extends ConsumerStatefulWidget {
  final Client? initialClient;

  const ClientLedgerPage({super.key, this.initialClient});

  @override
  ConsumerState<ClientLedgerPage> createState() => _ClientLedgerPageState();
}

class _ClientLedgerPageState extends ConsumerState<ClientLedgerPage> {
  Client? _selectedClient;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
  }

  @override
  Widget build(BuildContext context) {
    final clientBox = ref.watch(clientBoxProvider);
    final invoiceRepo = ref.watch(invoiceRepositoryProvider);
    // Listen to changes in invoiceBoxProvider to trigger rebuilds on invoice updates
    ref.watch(invoiceBoxProvider);
    final settings = ref.watch(settingsProvider);

    List<Invoice> clientInvoices = [];
    if (_selectedClient != null) {
      // Fetch invoices for the selected client
      // Note: This relies on exact name match, which is brittle but consistent with current model.
      clientInvoices =
          invoiceRepo.getInvoicesByClientName(_selectedClient!.name);

      // Filter by date range if set
      if (_dateRange != null) {
        clientInvoices = clientInvoices.where((invoice) {
          return invoice.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              invoice.date
                  .isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }

      // Sort by date descending
      clientInvoices.sort((a, b) => b.date.compareTo(a.date));
    }

    // Calculate Totals
    double totalBilled = 0;
    double totalPaid = 0;
    double balanceDue = 0;

    for (var invoice in clientInvoices) {
      // Exclude drafts from financial statements
      if (invoice.status == InvoiceStatus.draft) continue;

      totalBilled += invoice.total;

      if (invoice.status == InvoiceStatus.paid) {
        totalPaid += invoice.total;
      } else {
        balanceDue += invoice.total;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Ensure consistent background
      appBar: AppBar(
        title: const Text('Client Ledger'),
        actions: [
          if (_selectedClient != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                final pdfService = PdfService();
                final pdfData = await pdfService.generateClientLedger(
                  client: _selectedClient!,
                  invoices: clientInvoices,
                  settings: settings,
                  dateRange: _dateRange,
                );
                await Printing.layoutPdf(
                  onLayout: (format) => pdfData,
                  name: 'Client_Ledger_${_selectedClient!.name}.pdf',
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Client Selection & Date Filter
            Card(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Select Client',
                              prefixIcon: Icon(Icons.people),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Client>(
                                value: _selectedClient,
                                isExpanded: true,
                                hint: const Text('Select Client'),
                                items: clientBox.values.map((client) {
                                  return DropdownMenuItem(
                                    value: client,
                                    child: Text(client.name,
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClient = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          tooltip: 'Select Date Range',
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: _dateRange,
                            );
                            if (picked != null) {
                              setState(() {
                                _dateRange = picked;
                              });
                            }
                          },
                        ),
                        if (_dateRange != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear Date Filter',
                            onPressed: () {
                              setState(() {
                                _dateRange = null;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_dateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Date Range: ${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                          style: const TextStyle(
                              color: AppTheme.primaryColor, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 16),

            if (_selectedClient == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search,
                          size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Select a client to view their ledger',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Billed',
                      CurrencyUtils.formatAmount(
                          totalBilled, settings.currency),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Received',
                      CurrencyUtils.formatAmount(totalPaid, settings.currency),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Unpaid Due',
                      CurrencyUtils.formatAmount(balanceDue, settings.currency),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Transaction List
              Expanded(
                child: clientInvoices.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found for this period.',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: clientInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = clientInvoices[index];
                          final isCredit = invoice.status == InvoiceStatus.paid;
                          return Card(
                            color: AppTheme.surfaceColor.withValues(alpha: 0.3),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCredit
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color:
                                      isCredit ? Colors.green : Colors.orange,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                invoice.invoiceNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy').format(invoice.date),
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyUtils.formatAmount(
                                        invoice.total, settings.currency),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isCredit
                                          ? Colors.green
                                          : AppTheme
                                              .primaryColor, // Green if paid, purple if billed
                                    ),
                                  ),
                                  Text(
                                    invoice.status.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getStatusColor(invoice.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (50 * index).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.sent:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.draft:
        return Colors.grey;
    }
  }
}
