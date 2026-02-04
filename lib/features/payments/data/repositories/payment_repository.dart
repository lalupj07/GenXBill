import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/payments/data/models/payment_model.dart';

final paymentBoxProvider = Provider<Box<Payment>>((ref) {
  return Hive.box<Payment>('payments');
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final box = ref.watch(paymentBoxProvider);
  return PaymentRepository(box);
});

class PaymentRepository {
  final Box<Payment> _box;

  PaymentRepository(this._box);

  Future<void> addPayment(Payment payment) async {
    await _box.put(payment.id, payment);
  }

  Future<void> deletePayment(String id) async {
    await _box.delete(id);
  }

  Payment? getPayment(String id) {
    return _box.get(id);
  }

  List<Payment> getAllPayments() {
    return _box.values.toList();
  }

  List<Payment> getPaymentsByInvoice(String invoiceId) {
    return _box.values
        .where((payment) => payment.invoiceId == invoiceId)
        .toList();
  }

  double getTotalPaidForInvoice(String invoiceId) {
    final payments = getPaymentsByInvoice(invoiceId);
    return payments.fold<double>(0, (sum, payment) => sum + payment.amount);
  }

  Future<void> deletePaymentsByInvoice(String invoiceId) async {
    final payments = getPaymentsByInvoice(invoiceId);
    for (var payment in payments) {
      await _box.delete(payment.id);
    }
  }
}
