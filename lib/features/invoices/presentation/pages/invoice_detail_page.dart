import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/features/payments/presentation/widgets/payment_dialog.dart';
import 'package:genx_bill/features/payments/presentation/widgets/payment_history_widget.dart';
import 'package:genx_bill/features/payments/data/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class InvoiceDetailPage extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ThemeBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: Text('Invoice ${invoice.invoiceNumber}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export PDF',
                  onPressed: () => _exportPDF(context, ref),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_paid',
                      enabled: invoice.status != InvoiceStatus.paid,
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Mark as Paid'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'mark_sent',
                      enabled: invoice.status == InvoiceStatus.draft,
                      child: const Row(
                        children: [
                          Icon(Icons.send, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Mark as Sent'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Duplicate Invoice'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) =>
                      _handleAction(context, ref, value.toString()),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INVOICE',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                invoice.invoiceNumber,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(invoice.status)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(invoice.status),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              invoice.status.name.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(invoice.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),

                    const SizedBox(height: 24),

                    // Client & Date Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BILL TO',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  invoice.clientName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Invoice Date',
                                    DateFormat.yMMMd().format(invoice.date)),
                                const SizedBox(height: 12),
                                _buildInfoRow('Due Date',
                                    DateFormat.yMMMd().format(invoice.dueDate)),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Days Until Due',
                                  '${invoice.dueDate.difference(DateTime.now()).inDays} days',
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Items Table
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ITEMS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[700]!),
                                  ),
                                ),
                                children: [
                                  _buildTableHeader('Description'),
                                  _buildTableHeader('Qty'),
                                  _buildTableHeader('Price'),
                                  _buildTableHeader('Total'),
                                ],
                              ),
                              ...invoice.items.map((item) {
                                return TableRow(
                                  children: [
                                    _buildTableCell(item.description),
                                    _buildTableCell(item.quantity.toString()),
                                    _buildTableCell(
                                        '\$${item.unitPrice.toStringAsFixed(2)}'),
                                    _buildTableCell(
                                        '\$${item.total.toStringAsFixed(2)}'),
                                  ],
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Subtotal: \$${invoice.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tax: \$${invoice.tax.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'TOTAL: \$${invoice.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                    // Notes Section (if exists)
                    if (invoice.notes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.note_outlined,
                                    color: AppTheme.primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'NOTES',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                invoice.notes,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                    ],

                    const SizedBox(height: 24),

                    // Payment Tracking Section
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PAYMENTS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _recordPayment(context, ref),
                                icon: const Icon(Icons.add),
                                label: const Text('Record Payment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Payment Summary
                          Consumer(
                            builder: (context, ref, child) {
                              final paymentRepo =
                                  ref.watch(paymentRepositoryProvider);
                              final totalPaid = paymentRepo
                                  .getTotalPaidForInvoice(invoice.id);
                              final outstanding = invoice.total - totalPaid;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Paid',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${totalPaid.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Outstanding',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${outstanding.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: outstanding > 0
                                                    ? Colors.orange
                                                    : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Payment History
                          PaymentHistoryWidget(invoiceId: invoice.id),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _recordPayment(context, ref),
        icon: const Icon(Icons.payment),
        label: const Text('Record Payment'),
        backgroundColor: Colors.green,
      ).animate().scale(delay: 500.ms),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RecordPaymentDialog(invoice: invoice),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
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

  Future<void> _exportPDF(BuildContext context, WidgetRef ref) async {
    try {
      final settings = ref.read(settingsProvider);
      final pdfData = await PdfService().generateInvoice(
        invoice: invoice,
        settings: settings,
      );

      await Printing.layoutPdf(onLayout: (format) async => pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'mark_paid':
        final updatedInvoice = Invoice(
          id: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          clientName: invoice.clientName,
          date: invoice.date,
          dueDate: invoice.dueDate,
          items: invoice.items,
          status: InvoiceStatus.paid,
        );
        ref.read(invoiceRepositoryProvider).updateInvoice(updatedInvoice);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice marked as paid!')),
        );
        break;
      case 'mark_sent':
        final updatedInvoice = Invoice(
          id: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          clientName: invoice.clientName,
          date: invoice.date,
          dueDate: invoice.dueDate,
          items: invoice.items,
          status: InvoiceStatus.sent,
        );
        ref.read(invoiceRepositoryProvider).updateInvoice(updatedInvoice);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice marked as sent!')),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text('Delete Invoice'),
            content:
                const Text('Are you sure you want to delete this invoice?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ref.read(invoiceRepositoryProvider).deleteInvoice(invoice.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice deleted!')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
      case 'duplicate':
        // Create a duplicate invoice with new ID and draft status
        final duplicatedInvoice = Invoice(
          id: const Uuid().v4(),
          invoiceNumber: 'DRAFT-${DateTime.now().millisecondsSinceEpoch}',
          clientName: invoice.clientName,
          date: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
          items: invoice.items
              .map((item) => InvoiceItem(
                    id: const Uuid().v4(),
                    description: item.description,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                  ))
              .toList(),
          status: InvoiceStatus.draft,
        );

        ref.read(invoiceRepositoryProvider).addInvoice(duplicatedInvoice);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice duplicated! Check your invoices list.'),
            backgroundColor: Colors.green,
          ),
        );
        break;
    }
  }
}
