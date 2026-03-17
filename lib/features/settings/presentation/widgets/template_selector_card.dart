import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../invoices/data/models/invoice_template.dart';
import '../../../../core/services/templates/template_manager.dart';

class TemplateSelectorCard extends StatelessWidget {
  final InvoiceTemplate selectedTemplate;
  final Function(InvoiceTemplate) onTemplateChanged;

  const TemplateSelectorCard({
    super.key,
    required this.selectedTemplate,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Invoice Template Design',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your preferred invoice design style',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: InvoiceTemplate.values.map((template) {
                return _buildTemplateOption(context, template);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(BuildContext context, InvoiceTemplate template) {
    final isSelected = template == selectedTemplate;
    final templateName = TemplateManager.getTemplateName(template);
    final templateDesc = TemplateManager.getTemplateDescription(template);

    return InkWell(
      onTap: () => onTemplateChanged(template),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    templateName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              templateDesc,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: _getTemplatePreviewColor(template),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Icon(
                  Icons.description,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemplatePreviewColor(InvoiceTemplate template) {
    switch (template) {
      case InvoiceTemplate.modern:
      case InvoiceTemplate.corporate:
        return Colors.blue.shade700;
      case InvoiceTemplate.classic:
        return Colors.grey.shade800;
      case InvoiceTemplate.minimal:
        return Colors.grey.shade900;
      case InvoiceTemplate.bold:
        return Colors.teal.shade600;
      case InvoiceTemplate.gst:
        return Colors.red.shade700;
      case InvoiceTemplate.creative:
        return Colors.grey.shade900;
      case InvoiceTemplate.professional:
        return Colors.indigo.shade700;
      case InvoiceTemplate.executive:
        return Colors.orange.shade400;
      case InvoiceTemplate.elegant:
        return Colors.amber.shade900;
      case InvoiceTemplate.standard:
        return Colors.blueGrey.shade800;
      case InvoiceTemplate.enterprise:
        return Colors.purple.shade900;
      case InvoiceTemplate.compact:
        return Colors.green.shade700;
      case InvoiceTemplate.detailed:
        return Colors.blue.shade900;
      case InvoiceTemplate.retail:
        return Colors.pink.shade700;
      case InvoiceTemplate.service:
        return Colors.cyan.shade700;
    }
  }
}
