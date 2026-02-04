import 'package:flutter/material.dart';
import 'package:genx_bill/core/theme/app_theme.dart';

class AddEmployeePage extends StatelessWidget {
  const AddEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: const Center(
        child: Text('Add Employee Form - Coming Soon'),
      ),
    );
  }
}

class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: const Center(
        child: Text('Leave Management - Coming Soon'),
      ),
    );
  }
}
