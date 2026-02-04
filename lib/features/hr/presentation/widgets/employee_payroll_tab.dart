import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart';
import 'package:genx_bill/features/hr/data/models/payslip_model.dart';
import 'package:genx_bill/features/hr/data/repositories/payslip_repository.dart';
import 'package:genx_bill/features/hr/services/payroll_service.dart';
import 'package:genx_bill/features/hr/services/payslip_pdf_service.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:genx_bill/core/services/email_service.dart';
import 'package:genx_bill/l10n/app_localizations.dart';

class EmployeePayrollTab extends ConsumerStatefulWidget {
  final HREmployee employee;

  const EmployeePayrollTab({super.key, required this.employee});

  @override
  ConsumerState<EmployeePayrollTab> createState() => _EmployeePayrollTabState();
}

class _EmployeePayrollTabState extends ConsumerState<EmployeePayrollTab> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final payslipRepo = PayslipRepository();
    final payslips = payslipRepo.getPayslipsByEmployee(widget.employee.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generate Payslip Button
          _buildGeneratePayslipSection(),
          const SizedBox(height: 24),

          // Payslip History
          const Text(
            'Payslip History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          if (payslips.isEmpty)
            _buildEmptyState()
          else
            _buildPayslipList(payslips),
        ],
      ),
    );
  }

  Widget _buildGeneratePayslipSection() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Generate Payslip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Generate payslip for ${DateFormat('MMMM yyyy').format(now)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating
                  ? null
                  : () => _generatePayslip(currentMonth, currentYear),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle),
              label: Text(_isGenerating
                  ? 'Generating...'
                  : 'Generate Current Month Payslip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No payslips generated yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate your first payslip using the button above',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayslipList(List<Payslip> payslips) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payslips.length,
      itemBuilder: (context, index) {
        final payslip = payslips[index];
        return _buildPayslipCard(payslip);
      },
    );
  }

  Widget _buildPayslipCard(Payslip payslip) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final monthYear =
        DateFormat('MMMM yyyy').format(DateTime(payslip.year, payslip.month));
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generated: ${DateFormat('dd MMM yyyy').format(payslip.generatedDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                _buildStatusChip(payslip.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                    'Payable Days', payslip.payableDays.toStringAsFixed(1)),
                _buildInfoColumn(
                    'Gross', currencyFormat.format(payslip.grossEarnings)),
                _buildInfoColumn('Deductions',
                    currencyFormat.format(payslip.totalDeductions)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Salary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    currencyFormat.format(payslip.netSalary),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _downloadPayslip(payslip),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download PDF'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      _isGenerating ? null : () => _emailPayslip(payslip),
                  icon: const Icon(Icons.email, size: 18),
                  label: Text(l10n.sendPayslip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PayslipStatus status) {
    Color color;
    String label;

    switch (status) {
      case PayslipStatus.draft:
        color = Colors.orange;
        label = 'Draft';
        break;
      case PayslipStatus.generated:
        color = Colors.blue;
        label = 'Generated';
        break;
      case PayslipStatus.paid:
        color = Colors.green;
        label = 'Paid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _generatePayslip(int month, int year) async {
    setState(() => _isGenerating = true);

    try {
      final payrollService = PayrollService(
        employeeRepository: ref.read(employeeRepositoryProvider),
        attendanceRepository: ref.read(attendanceRepositoryProvider),
        leaveRepository: ref.read(leaveRepositoryProvider),
      );

      // Check if payslip already exists
      final payslipRepo = PayslipRepository();
      final existing = payslipRepo.getPayslipByEmployeeAndMonth(
        employeeId: widget.employee.id,
        month: month,
        year: year,
      );

      if (existing != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payslip for this month already exists')),
        );
        setState(() => _isGenerating = false);
        return;
      }

      // Generate payslip
      final payslip = payrollService.calculatePayslip(
        employeeId: widget.employee.id,
        month: month,
        year: year,
      );

      // Save to repository
      await payslipRepo.addPayslip(payslip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payslip generated successfully!')),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating payslip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _downloadPayslip(Payslip payslip) async {
    try {
      final pdfService = PayslipPdfService();
      final settings = ref.read(settingsProvider);

      // Generate PDF
      final pdfBytes = await pdfService.generatePayslipPdf(
        payslip: payslip,
        settings: settings,
      );

      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Payslip_${payslip.employeeName}_${payslip.month}_${payslip.year}.pdf';
      final file = File('${directory.path}/$fileName');

      // Save file
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payslip saved to: ${file.path}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading payslip: $e')),
        );
      }
    }
  }

  Future<void> _emailPayslip(Payslip payslip) async {
    if (widget.employee.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee has no email address')),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    if (settings.smtpServer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('SMTP settings not configured in Settings > Email')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfService = PayslipPdfService();
      final pdfBytes = await pdfService.generatePayslipPdf(
        payslip: payslip,
        settings: settings,
      );

      final monthYear =
          DateFormat('MMMM yyyy').format(DateTime(payslip.year, payslip.month));
      final emailService = EmailService();

      final success = await emailService.sendPayslipEmail(
        recipientEmail: widget.employee.email,
        employeeName: widget.employee.name,
        monthYear: monthYear,
        pdfBytes: pdfBytes,
        settings: settings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Payslip emailed to ${widget.employee.email}'
                : 'Failed to send email'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending email: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
