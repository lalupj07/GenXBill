import 'dart:io';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for sending invoices via WhatsApp
/// Uses WhatsApp Web API to send PDF files
class WhatsAppService {
  /// Send invoice PDF to WhatsApp number
  ///
  /// [phoneNumber] - Phone number with country code (e.g., +919876543210)
  /// [pdfBytes] - PDF file bytes
  /// [invoiceNumber] - Invoice number for filename
  ///
  /// Returns true if WhatsApp was opened successfully
  static Future<bool> sendInvoicePDF({
    required String phoneNumber,
    required Uint8List pdfBytes,
    required String invoiceNumber,
  }) async {
    try {
      // Clean phone number - remove spaces, dashes, and ensure it starts with country code
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // If doesn't start with +, assume India (+91)
      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.startsWith('91')) {
          cleanPhone = '+$cleanPhone';
        } else {
          cleanPhone = '+91$cleanPhone';
        }
      }

      // Save PDF to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'Invoice_${invoiceNumber.replaceAll('/', '_')}.pdf';
      final filePath = path.join(tempDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Create WhatsApp message with file
      // Note: WhatsApp Web doesn't support direct file sending via URL
      // We'll open WhatsApp with a message and the user can manually attach the saved PDF
      final message = Uri.encodeComponent(
          'Hi! Please find attached Invoice $invoiceNumber.\n\n'
          'The invoice PDF has been saved to: $filePath\n\n'
          'Thank you for your business!');

      // WhatsApp Web URL format
      final whatsappUrl =
          'https://web.whatsapp.com/send?phone=$cleanPhone&text=$message';

      // Try to launch WhatsApp Web
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback: Try WhatsApp desktop app URL
        final appUrl = 'whatsapp://send?phone=$cleanPhone&text=$message';
        final appUri = Uri.parse(appUrl);
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Should have at least 10 digits (Indian mobile number)
    return digitsOnly.length >= 10;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('91')) {
        cleaned = '+$cleaned';
      } else {
        cleaned = '+91$cleaned';
      }
    }

    return cleaned;
  }
}
