import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../../models/app_settings.dart';
import '../../../features/invoices/data/models/invoice_model.dart';
import '../../../features/invoices/data/models/invoice_template.dart';
import 'corporate_blue_template.dart';
import '../enhanced_invoice_template.dart';

/// Template Manager - Routes to appropriate template based on selection
class TemplateManager {
  static Future<Uint8List> generateInvoicePDF({
    required Invoice invoice,
    required AppSettings settings,
    InvoiceTemplate? templateType,
  }) async {
    final selectedTemplate = templateType ?? settings.defaultTemplate;
    
    pw.Document pdf;
    
    switch (selectedTemplate) {
      case InvoiceTemplate.modern:
      case InvoiceTemplate.corporate:
        pdf = await CorporateBlueTemplate.generatePDF(invoice, settings);
        break;
      
      case InvoiceTemplate.professional:
      case InvoiceTemplate.gst:
      case InvoiceTemplate.detailed:
      default:
        // Use enhanced template as default
        pdf = await EnhancedInvoiceTemplate.generatePDF(invoice, settings);
        break;
    }
    
    return pdf.save();
  }
  
  static String getTemplateName(InvoiceTemplate template) {
    switch (template) {
      case InvoiceTemplate.modern:
        return 'Corporate Blue';
      case InvoiceTemplate.classic:
        return 'Minimal Mono';
      case InvoiceTemplate.minimal:
        return 'Dark Luxury';
      case InvoiceTemplate.bold:
        return 'Teal Modern';
      case InvoiceTemplate.gst:
        return 'Editorial Red';
      case InvoiceTemplate.creative:
        return 'Dev/Code';
      case InvoiceTemplate.professional:
        return 'Enhanced Professional';
      case InvoiceTemplate.executive:
        return 'Soft Pastel';
      case InvoiceTemplate.corporate:
        return 'Corporate Blue';
      case InvoiceTemplate.elegant:
        return 'Art Deco Gold';
      case InvoiceTemplate.standard:
        return 'Split Panel';
      case InvoiceTemplate.enterprise:
        return 'Futuristic Purple';
      case InvoiceTemplate.compact:
        return 'Compact';
      case InvoiceTemplate.detailed:
        return 'Detailed';
      case InvoiceTemplate.retail:
        return 'Retail';
      case InvoiceTemplate.service:
        return 'Service';
    }
  }
  
  static String getTemplateDescription(InvoiceTemplate template) {
    switch (template) {
      case InvoiceTemplate.modern:
      case InvoiceTemplate.corporate:
        return 'Professional blue headers with clean white body';
      case InvoiceTemplate.classic:
        return 'Black serif typography with dashed dividers';
      case InvoiceTemplate.minimal:
        return 'Dark background with gold accents';
      case InvoiceTemplate.bold:
        return 'Gradient teal header with rounded cards';
      case InvoiceTemplate.gst:
        return 'Bold red accent bar with magazine-style typography';
      case InvoiceTemplate.creative:
        return 'Dark terminal aesthetic with monospace font';
      case InvoiceTemplate.professional:
        return 'Comprehensive GST-compliant invoice with all details';
      case InvoiceTemplate.executive:
        return 'Warm orange sidebar with pastel background';
      case InvoiceTemplate.elegant:
        return 'Gold ornaments on dark with Cinzel serif font';
      case InvoiceTemplate.standard:
        return 'Dark sidebar left with white content right';
      case InvoiceTemplate.enterprise:
        return 'Gradient dark background with purple neon accents';
      case InvoiceTemplate.compact:
        return 'Space-efficient layout for quick invoices';
      case InvoiceTemplate.detailed:
        return 'Comprehensive invoice with extensive details';
      case InvoiceTemplate.retail:
        return 'Retail-focused invoice template';
      case InvoiceTemplate.service:
        return 'Service-oriented invoice template';
    }
  }
}
