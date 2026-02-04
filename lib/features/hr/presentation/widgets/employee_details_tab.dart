import 'package:flutter/material.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;

class EmployeeDetailsTab extends StatelessWidget {
  final hr.HREmployee employee;
  const EmployeeDetailsTab({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSection('Personal Information', [
            _DetailItem('Full Name', employee.name),
            _DetailItem('Date of Birth',
                employee.dateOfBirth?.toString().split(' ')[0] ?? 'N/A'),
            _DetailItem('Email', employee.email),
            _DetailItem('Phone', employee.phone),
            _DetailItem('Address', employee.address ?? 'N/A'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Job Details', [
            _DetailItem('Employee ID', employee.employeeCode),
            _DetailItem('Department', employee.department),
            _DetailItem('Position', employee.position),
            _DetailItem(
                'Joining Date', employee.joinDate.toString().split(' ')[0]),
            _DetailItem('Status', employee.status.name.toUpperCase()),
          ]),
          const SizedBox(height: 24),
          _buildSection('Emergency Contact', [
            _DetailItem('Name', employee.emergencyContactName ?? 'N/A'),
            _DetailItem('Phone', employee.emergencyContactPhone ?? 'N/A'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const Divider(),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// Reusing GlassContainer since it's common
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassContainer({super.key, required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}
