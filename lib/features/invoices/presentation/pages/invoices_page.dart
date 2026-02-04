import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:genx_bill/features/invoices/presentation/pages/invoice_detail_page.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:genx_bill/core/services/csv_export_service.dart';
import 'package:genx_bill/l10n/app_localizations.dart';
import 'package:genx_bill/core/utils/currency_utils.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';

import 'package:genx_bill/core/widgets/main_layout.dart';

class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  ConsumerState<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  InvoiceStatus? _filterStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final invoiceBox = ref.watch(invoiceBoxProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportToCsv(context, ref),
        icon: const Icon(Icons.download),
        label: Text(AppLocalizations.of(context)!.exportCsv),
        backgroundColor: AppTheme.primaryColor,
      ),
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
                          tooltip: AppLocalizations.of(context)!.dashboard,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.invoices,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Text(
                      'Manage and track your billings',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateInvoicePage()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.newInvoice),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter Bar
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchInvoices,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.surfaceColor.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InvoiceStatus?>(
                    initialValue: _filterStatus,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.filterByStatus,
                      filled: true,
                      fillColor: AppTheme.surfaceColor.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(AppLocalizations.of(context)!.all)),
                      ...InvoiceStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _filterStatus = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: invoiceBox.listenable(),
                builder: (context, Box<Invoice> box, _) {
                  var invoices = box.values.toList().cast<Invoice>();

                  // Apply filters
                  if (_filterStatus != null) {
                    invoices = invoices
                        .where((inv) => inv.status == _filterStatus)
                        .toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    invoices = invoices.where((inv) {
                      return inv.invoiceNumber
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          inv.clientName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _filterStatus != null
                                ? AppLocalizations.of(context)!.noInvoicesFound
                                : AppLocalizations.of(context)!.noInvoicesYet,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return Card(
                        color: AppTheme.surfaceColor.withValues(alpha: 0.6),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvoiceDetailPage(invoice: invoice),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.2),
                              child: const Icon(Icons.description,
                                  color: AppTheme.primaryColor),
                            ),
                            title: Text(
                              invoice.invoiceNumber,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${invoice.clientName}\n${DateFormat.yMMMd().format(invoice.date)}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyUtils.formatAmount(invoice.total,
                                      ref.read(settingsProvider).currency),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(invoice.status)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    invoice.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(invoice.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideX(begin: 0.1);
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

  Future<void> _exportToCsv(BuildContext context, WidgetRef ref) async {
    try {
      final invoices = ref.read(invoiceRepositoryProvider).getAllInvoices();

      if (invoices.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No invoices to export!')),
          );
        }
        return;
      }

      final csvService = CsvExportService();
      final filePath = await csvService.exportInvoicesToCsv(invoices);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Exported ${invoices.length} invoices to:\n$filePath'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting: $e')),
        );
      }
    }
  }
}
