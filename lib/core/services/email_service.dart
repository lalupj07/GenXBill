import 'dart:typed_data';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';

class EmailService {
  Future<bool> sendPayslipEmail({
    required String recipientEmail,
    required String employeeName,
    required String monthYear,
    required Uint8List pdfBytes,
    required AppSettings settings,
  }) async {
    if (settings.smtpServer == null ||
        settings.smtpUsername == null ||
        settings.smtpPassword == null) {
      throw Exception('Email settings not configured');
    }

    final smtpServer = SmtpServer(
      settings.smtpServer!,
      port: settings.smtpPort ?? 587,
      username: settings.smtpUsername,
      password: settings.smtpPassword,
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/payslip.pdf');
    await tempFile.writeAsBytes(pdfBytes);

    final message = Message()
      ..from = Address(settings.smtpUsername!, settings.companyName)
      ..recipients.add(recipientEmail)
      ..subject = 'Payslip for $monthYear - $employeeName'
      ..text =
          'Dear $employeeName,\n\nPlease find attached your payslip for $monthYear.\n\nBest regards,\n${settings.companyName}'
      ..attachments.add(
        FileAttachment(
          tempFile,
          fileName: 'Payslip_$monthYear.pdf',
          contentType: 'application/pdf',
        ),
      );

    try {
      final sendReport = await send(message, smtpServer);
      return sendReport.toString().contains('Message sent');
    } catch (e) {
      rethrow;
    }
  }
}
