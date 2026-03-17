import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;
import 'package:intl/intl.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class AddEmployeePage extends ConsumerStatefulWidget {
  const AddEmployeePage({super.key});

  @override
  ConsumerState<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends ConsumerState<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deptController = TextEditingController();
  final _posController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime _joinDate = DateTime.now();
  DateTime? _dob;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    _posController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isJoinDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isJoinDate ? _joinDate : (_dob ?? DateTime(1990)),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isJoinDate) {
          _joinDate = picked;
        } else {
          _dob = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ThemeBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'Full Name *', Icons.person,
                    (v) => v!.isEmpty ? 'Name is required' : null),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _codeController,
                            'Employee Code *',
                            Icons.badge,
                            (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _salaryController,
                            'Monthly Salary *',
                            Icons.payments,
                            (v) => v!.isEmpty ? 'Required' : null,
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _emailController,
                            'Email Address *',
                            Icons.email,
                            (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _phoneController,
                            'Phone Number *',
                            Icons.phone,
                            (v) => v!.isEmpty ? 'Required' : null)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Job Details'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _deptController,
                            'Department *',
                            Icons.business,
                            (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_posController, 'Position *',
                            Icons.work, (v) => v!.isEmpty ? 'Required' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Joining Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd MMMM yyyy').format(_joinDate)),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Personal Details'),
                const SizedBox(height: 16),
                _buildTextField(_addressController, 'Address', Icons.home, null,
                    maxLines: 2),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    child: Text(_dob == null
                        ? 'Select Date'
                        : DateFormat('dd MMMM yyyy').format(_dob!)),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Emergency Contact'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_emergencyNameController,
                            'Contact Name', Icons.contact_emergency, null)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_emergencyPhoneController,
                            'Contact Phone', Icons.emergency, null)),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Employee',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  void _saveEmployee() {
    if (_formKey.currentState!.validate()) {
      final employee = hr.HREmployee.create(
        employeeCode: _codeController.text,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        department: _deptController.text,
        position: _posController.text,
        joinDate: _joinDate,
        salary: double.tryParse(_salaryController.text) ?? 0.0,
        address: _addressController.text,
        dateOfBirth: _dob,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );

      final repo = ref.read(employeeRepositoryProvider);
      repo.addEmployee(employee);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully')),
      );
      Navigator.pop(context);
    }
  }
}
