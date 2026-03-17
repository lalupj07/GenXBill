import 'package:hive/hive.dart';

part 'payment_reminder.g.dart';

/// Payment reminder configuration
@HiveType(typeId: 82)
class PaymentReminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceId;

  @HiveField(2)
  final String clientName;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final List<ReminderSchedule> schedules;

  @HiveField(6)
  final bool sendEmail;

  @HiveField(7)
  final bool sendWhatsApp;

  @HiveField(8)
  final String? customMessage;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final List<ReminderLog> logs;

  @HiveField(11)
  final bool isActive;

  PaymentReminder({
    required this.id,
    required this.invoiceId,
    required this.clientName,
    required this.dueDate,
    required this.amount,
    required this.schedules,
    required this.sendEmail,
    required this.sendWhatsApp,
    this.customMessage,
    required this.createdAt,
    required this.logs,
    this.isActive = true,
  });

  PaymentReminder copyWith({
    String? id,
    String? invoiceId,
    String? clientName,
    DateTime? dueDate,
    double? amount,
    List<ReminderSchedule>? schedules,
    bool? sendEmail,
    bool? sendWhatsApp,
    String? customMessage,
    DateTime? createdAt,
    List<ReminderLog>? logs,
    bool? isActive,
  }) {
    return PaymentReminder(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      clientName: clientName ?? this.clientName,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      schedules: schedules ?? this.schedules,
      sendEmail: sendEmail ?? this.sendEmail,
      sendWhatsApp: sendWhatsApp ?? this.sendWhatsApp,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
      logs: logs ?? this.logs,
      isActive: isActive ?? this.isActive,
    );
  }
}

@HiveType(typeId: 83)
class ReminderSchedule {
  @HiveField(0)
  final int daysBeforeDue;

  @HiveField(1)
  final int daysAfterDue;

  @HiveField(2)
  final ReminderType type;

  @HiveField(3)
  final bool sent;

  @HiveField(4)
  final DateTime? sentAt;

  ReminderSchedule({
    this.daysBeforeDue = 0,
    this.daysAfterDue = 0,
    required this.type,
    this.sent = false,
    this.sentAt,
  });

  ReminderSchedule copyWith({
    int? daysBeforeDue,
    int? daysAfterDue,
    ReminderType? type,
    bool? sent,
    DateTime? sentAt,
  }) {
    return ReminderSchedule(
      daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
      daysAfterDue: daysAfterDue ?? this.daysAfterDue,
      type: type ?? this.type,
      sent: sent ?? this.sent,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  DateTime getScheduledDate(DateTime dueDate) {
    if (daysBeforeDue > 0) {
      return dueDate.subtract(Duration(days: daysBeforeDue));
    } else if (daysAfterDue > 0) {
      return dueDate.add(Duration(days: daysAfterDue));
    }
    return dueDate;
  }

  String get description {
    if (daysBeforeDue > 0) {
      return '$daysBeforeDue days before due date';
    } else if (daysAfterDue > 0) {
      return '$daysAfterDue days after due date';
    }
    return 'On due date';
  }
}

@HiveType(typeId: 84)
enum ReminderType {
  @HiveField(0)
  friendly, // Polite reminder before due date
  @HiveField(1)
  dueDate, // Reminder on due date
  @HiveField(2)
  overdue, // Reminder after due date
  @HiveField(3)
  finalReminder, // Final reminder
}

@HiveType(typeId: 85)
class ReminderLog {
  @HiveField(0)
  final DateTime sentAt;

  @HiveField(1)
  final ReminderType type;

  @HiveField(2)
  final String channel; // email, whatsapp

  @HiveField(3)
  final bool success;

  @HiveField(4)
  final String? errorMessage;

  ReminderLog({
    required this.sentAt,
    required this.type,
    required this.channel,
    required this.success,
    this.errorMessage,
  });
}

/// Reminder template for generating messages
class ReminderTemplate {
  static String getFriendlyReminder(String clientName, String invoiceNumber,
      DateTime dueDate, double amount, String currency) {
    return '''
Dear $clientName,

This is a friendly reminder that invoice #$invoiceNumber for $currency ${amount.toStringAsFixed(2)} is due on ${_formatDate(dueDate)}.

We appreciate your business and look forward to your timely payment.

If you have any questions or concerns, please don't hesitate to contact us.

Best regards,
GenXBill Team
''';
  }

  static String getDueDateReminder(
      String clientName, String invoiceNumber, double amount, String currency) {
    return '''
Dear $clientName,

This is a reminder that invoice #$invoiceNumber for $currency ${amount.toStringAsFixed(2)} is due today.

Please process the payment at your earliest convenience.

Thank you for your prompt attention to this matter.

Best regards,
GenXBill Team
''';
  }

  static String getOverdueReminder(String clientName, String invoiceNumber,
      int daysOverdue, double amount, String currency) {
    return '''
Dear $clientName,

We noticed that invoice #$invoiceNumber for $currency ${amount.toStringAsFixed(2)} is now $daysOverdue days overdue.

We kindly request that you process this payment as soon as possible to avoid any service interruptions.

If you have already made the payment, please disregard this message and accept our apologies.

If you're experiencing any difficulties, please contact us to discuss payment arrangements.

Best regards,
GenXBill Team
''';
  }

  static String getFinalReminder(String clientName, String invoiceNumber,
      int daysOverdue, double amount, String currency) {
    return '''
Dear $clientName,

This is a final reminder regarding invoice #$invoiceNumber for $currency ${amount.toStringAsFixed(2)}, which is now $daysOverdue days overdue.

We must receive payment within the next 7 days to avoid further action.

Please contact us immediately if you need to discuss payment arrangements or if there are any issues with this invoice.

We value our business relationship and hope to resolve this matter promptly.

Best regards,
GenXBill Team
''';
  }

  static String getWhatsAppMessage(String clientName, String invoiceNumber,
      DateTime dueDate, double amount, String currency, ReminderType type) {
    switch (type) {
      case ReminderType.friendly:
        return 'Hi $clientName! Friendly reminder: Invoice #$invoiceNumber ($currency ${amount.toStringAsFixed(2)}) is due on ${_formatDate(dueDate)}. Thank you! 😊';
      case ReminderType.dueDate:
        return 'Hi $clientName! Invoice #$invoiceNumber ($currency ${amount.toStringAsFixed(2)}) is due today. Please process payment at your convenience. Thanks!';
      case ReminderType.overdue:
        return 'Hi $clientName, Invoice #$invoiceNumber ($currency ${amount.toStringAsFixed(2)}) is overdue. Please arrange payment soon. Contact us if you need assistance.';
      case ReminderType.finalReminder:
        return 'Hi $clientName, FINAL REMINDER: Invoice #$invoiceNumber ($currency ${amount.toStringAsFixed(2)}) requires immediate attention. Please contact us urgently.';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Default reminder schedules
class DefaultReminderSchedules {
  static List<ReminderSchedule> get standard => [
        ReminderSchedule(daysBeforeDue: 7, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 3, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 0, type: ReminderType.dueDate),
        ReminderSchedule(daysAfterDue: 3, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 7, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 14, type: ReminderType.finalReminder),
      ];

  static List<ReminderSchedule> get aggressive => [
        ReminderSchedule(daysBeforeDue: 7, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 3, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 1, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 0, type: ReminderType.dueDate),
        ReminderSchedule(daysAfterDue: 1, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 3, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 7, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 14, type: ReminderType.finalReminder),
      ];

  static List<ReminderSchedule> get gentle => [
        ReminderSchedule(daysBeforeDue: 7, type: ReminderType.friendly),
        ReminderSchedule(daysBeforeDue: 0, type: ReminderType.dueDate),
        ReminderSchedule(daysAfterDue: 7, type: ReminderType.overdue),
        ReminderSchedule(daysAfterDue: 21, type: ReminderType.finalReminder),
      ];
}
