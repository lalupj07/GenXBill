import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';

class InvoiceRepository {
  final Box<Invoice> _box;

  InvoiceRepository(this._box);

  List<Invoice> getAllInvoices() {
    return _box.values.toList();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _box.put(invoice.id, invoice);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await _box.put(invoice.id, invoice);
  }

  Future<void> deleteInvoice(String id) async {
    await _box.delete(id);
  }
}

final invoiceBoxProvider = Provider<Box<Invoice>>((ref) {
  return Hive.box<Invoice>('invoices');
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final box = ref.watch(invoiceBoxProvider);
  return InvoiceRepository(box);
});
