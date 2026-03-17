import 'package:hive/hive.dart';
import 'package:genx_bill/features/reminders/data/models/payment_reminder.dart';

/// Repository for managing payment reminders
class ReminderRepository {
  static const String _boxName = 'payment_reminders';

  Box<PaymentReminder> get _box => Hive.box<PaymentReminder>(_boxName);

  /// Get all reminders
  List<PaymentReminder> getAllReminders() {
    return _box.values.toList();
  }

  /// Get reminder by ID
  PaymentReminder? getReminderById(String id) {
    return _box.get(id);
  }

  /// Get reminders for invoice
  List<PaymentReminder> getRemindersForInvoice(String invoiceId) {
    return _box.values.where((r) => r.invoiceId == invoiceId).toList();
  }

  /// Get active reminders (not completed)
  List<PaymentReminder> getActiveReminders() {
    return _box.values.where((r) => r.isActive).toList();
  }

  /// Get overdue reminders
  List<PaymentReminder> getOverdueReminders() {
    final now = DateTime.now();
    return _box.values.where((r) {
      return r.isActive && r.dueDate.isBefore(now);
    }).toList();
  }

  /// Save reminder
  Future<void> saveReminder(PaymentReminder reminder) async {
    await _box.put(reminder.id, reminder);
  }

  /// Delete reminder
  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  /// Mark reminder as completed (deactivate)
  Future<void> markAsCompleted(String id) async {
    final reminder = _box.get(id);
    if (reminder != null) {
      final updated = PaymentReminder(
        id: reminder.id,
        invoiceId: reminder.invoiceId,
        clientName: reminder.clientName,
        amount: reminder.amount,
        dueDate: reminder.dueDate,
        schedules: reminder.schedules,
        sendEmail: reminder.sendEmail,
        sendWhatsApp: reminder.sendWhatsApp,
        customMessage: reminder.customMessage,
        createdAt: reminder.createdAt,
        logs: reminder.logs,
        isActive: false,
      );
      await _box.put(id, updated);
    }
  }

  /// Add log to reminder
  Future<void> addLog(String reminderId, ReminderLog log) async {
    final reminder = _box.get(reminderId);
    if (reminder != null) {
      final logs = List<ReminderLog>.from(reminder.logs)..add(log);
      final updated = PaymentReminder(
        id: reminder.id,
        invoiceId: reminder.invoiceId,
        clientName: reminder.clientName,
        amount: reminder.amount,
        dueDate: reminder.dueDate,
        schedules: reminder.schedules,
        sendEmail: reminder.sendEmail,
        sendWhatsApp: reminder.sendWhatsApp,
        customMessage: reminder.customMessage,
        createdAt: reminder.createdAt,
        logs: logs,
        isActive: reminder.isActive,
      );
      await _box.put(reminderId, updated);
    }
  }

  /// Clear all reminders
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Delete inactive reminders older than days
  Future<void> deleteOldCompletedReminders({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final toDelete = _box.values
        .where((r) {
          return !r.isActive && r.dueDate.isBefore(cutoffDate);
        })
        .map((r) => r.id)
        .toList();

    for (var id in toDelete) {
      await _box.delete(id);
    }
  }
}
