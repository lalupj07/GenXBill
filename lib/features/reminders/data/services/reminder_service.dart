import 'package:genx_bill/features/reminders/data/models/payment_reminder.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Service for managing payment reminders
class ReminderService {
  /// Check and send due reminders
  static Future<List<ReminderResult>> checkAndSendReminders(
    List<PaymentReminder> reminders,
    List<Invoice> invoices,
    String smtpServer,
    int smtpPort,
    String smtpUsername,
    String smtpPassword,
    String currency,
  ) async {
    final results = <ReminderResult>[];
    final now = DateTime.now();

    for (var reminder in reminders) {
      if (!reminder.isActive) continue;

      final invoice = invoices.firstWhere(
        (inv) => inv.id == reminder.invoiceId,
        orElse: () => Invoice(
          id: '',
          invoiceNumber: '',
          clientName: '',
          date: DateTime.now(),
          dueDate: DateTime.now(),
          items: [],
          status: InvoiceStatus.draft,
        ),
      );

      if (invoice.id.isEmpty || invoice.status == InvoiceStatus.paid) {
        continue;
      }

      // Check each schedule
      for (var i = 0; i < reminder.schedules.length; i++) {
        final schedule = reminder.schedules[i];
        if (schedule.sent) continue;

        final scheduledDate = schedule.getScheduledDate(reminder.dueDate);
        final shouldSend = now.isAfter(scheduledDate) &&
            now.difference(scheduledDate).inHours < 24;

        if (shouldSend) {
          final result = await _sendReminder(
            reminder,
            schedule,
            invoice,
            smtpServer,
            smtpPort,
            smtpUsername,
            smtpPassword,
            currency,
          );

          results.add(result);

          // Update schedule as sent
          reminder.schedules[i] = schedule.copyWith(
            sent: true,
            sentAt: DateTime.now(),
          );
        }
      }
    }

    return results;
  }

  static Future<ReminderResult> _sendReminder(
    PaymentReminder reminder,
    ReminderSchedule schedule,
    Invoice invoice,
    String smtpServer,
    int smtpPort,
    String smtpUsername,
    String smtpPassword,
    String currency,
  ) async {
    final results = <String, bool>{};
    final errors = <String, String>{};

    // Send email if enabled
    if (reminder.sendEmail) {
      try {
        await _sendEmailReminder(
          reminder,
          schedule,
          invoice,
          smtpServer,
          smtpPort,
          smtpUsername,
          smtpPassword,
          currency,
        );
        results['email'] = true;
      } catch (e) {
        results['email'] = false;
        errors['email'] = e.toString();
      }
    }

    // Send WhatsApp if enabled
    if (reminder.sendWhatsApp) {
      try {
        final sent = await _sendWhatsAppReminder(
          reminder,
          schedule,
          invoice,
          currency,
        );
        results['whatsapp'] = sent;
      } catch (e) {
        results['whatsapp'] = false;
        errors['whatsapp'] = e.toString();
      }
    }

    return ReminderResult(
      reminderId: reminder.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: reminder.clientName,
      scheduleType: schedule.type,
      results: results,
      errors: errors,
      sentAt: DateTime.now(),
    );
  }

  static Future<void> _sendEmailReminder(
    PaymentReminder reminder,
    ReminderSchedule schedule,
    Invoice invoice,
    String smtpServer,
    int smtpPort,
    String smtpUsername,
    String smtpPassword,
    String currency,
  ) async {
    final smtp = SmtpServer(
      smtpServer,
      port: smtpPort,
      username: smtpUsername,
      password: smtpPassword,
    );

    String subject;
    String body;

    final daysOverdue = DateTime.now().difference(reminder.dueDate).inDays;

    switch (schedule.type) {
      case ReminderType.friendly:
        subject =
            'Friendly Reminder: Invoice #${invoice.invoiceNumber} Due Soon';
        body = reminder.customMessage ??
            ReminderTemplate.getFriendlyReminder(
              reminder.clientName,
              invoice.invoiceNumber,
              reminder.dueDate,
              reminder.amount,
              currency,
            );
        break;
      case ReminderType.dueDate:
        subject = 'Payment Due Today: Invoice #${invoice.invoiceNumber}';
        body = reminder.customMessage ??
            ReminderTemplate.getDueDateReminder(
              reminder.clientName,
              invoice.invoiceNumber,
              reminder.amount,
              currency,
            );
        break;
      case ReminderType.overdue:
        subject = 'Overdue Payment: Invoice #${invoice.invoiceNumber}';
        body = reminder.customMessage ??
            ReminderTemplate.getOverdueReminder(
              reminder.clientName,
              invoice.invoiceNumber,
              daysOverdue,
              reminder.amount,
              currency,
            );
        break;
      case ReminderType.finalReminder:
        subject = 'FINAL REMINDER: Invoice #${invoice.invoiceNumber}';
        body = reminder.customMessage ??
            ReminderTemplate.getFinalReminder(
              reminder.clientName,
              invoice.invoiceNumber,
              daysOverdue,
              reminder.amount,
              currency,
            );
        break;
    }

    final message = Message()
      ..from = Address(smtpUsername, 'GenXBill')
      ..recipients.add(invoice.clientName) // Should be email address
      ..subject = subject
      ..text = body;

    await send(message, smtp);
  }

  static Future<bool> _sendWhatsAppReminder(
    PaymentReminder reminder,
    ReminderSchedule schedule,
    Invoice invoice,
    String currency,
  ) async {
    return true;
  }

  /// Create reminder for invoice
  static PaymentReminder createReminderForInvoice(
    Invoice invoice,
    List<ReminderSchedule> schedules, {
    bool sendEmail = true,
    bool sendWhatsApp = false,
    String? customMessage,
  }) {
    return PaymentReminder(
      id: 'reminder_${invoice.id}',
      invoiceId: invoice.id,
      clientName: invoice.clientName,
      dueDate: invoice.dueDate,
      amount: invoice.total,
      schedules: schedules,
      sendEmail: sendEmail,
      sendWhatsApp: sendWhatsApp,
      customMessage: customMessage,
      createdAt: DateTime.now(),
      logs: [],
      isActive: true,
    );
  }

  /// Get upcoming reminders
  static List<UpcomingReminder> getUpcomingReminders(
    List<PaymentReminder> reminders,
  ) {
    final now = DateTime.now();
    final upcoming = <UpcomingReminder>[];

    for (var reminder in reminders) {
      if (!reminder.isActive) continue;

      for (var schedule in reminder.schedules) {
        if (schedule.sent) continue;

        final scheduledDate = schedule.getScheduledDate(reminder.dueDate);
        if (scheduledDate.isAfter(now)) {
          upcoming.add(UpcomingReminder(
            reminderId: reminder.id,
            invoiceId: reminder.invoiceId,
            clientName: reminder.clientName,
            scheduledDate: scheduledDate,
            type: schedule.type,
            amount: reminder.amount,
          ));
        }
      }
    }

    upcoming.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return upcoming;
  }
}

class ReminderResult {
  final String reminderId;
  final String invoiceNumber;
  final String clientName;
  final ReminderType scheduleType;
  final Map<String, bool> results;
  final Map<String, String> errors;
  final DateTime sentAt;

  ReminderResult({
    required this.reminderId,
    required this.invoiceNumber,
    required this.clientName,
    required this.scheduleType,
    required this.results,
    required this.errors,
    required this.sentAt,
  });

  bool get success => results.values.any((v) => v);
  bool get hasErrors => errors.isNotEmpty;
}

class UpcomingReminder {
  final String reminderId;
  final String invoiceId;
  final String clientName;
  final DateTime scheduledDate;
  final ReminderType type;
  final double amount;

  UpcomingReminder({
    required this.reminderId,
    required this.invoiceId,
    required this.clientName,
    required this.scheduledDate,
    required this.type,
    required this.amount,
  });

  int get daysUntil => scheduledDate.difference(DateTime.now()).inDays;
}
