import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/features/hr/presentation/widgets/employee_details_tab.dart';
import 'package:genx_bill/features/hr/presentation/widgets/employee_documents_tab.dart';
import 'package:genx_bill/features/hr/presentation/widgets/employee_leave_tab.dart';
import 'package:genx_bill/features/hr/presentation/widgets/employee_payroll_tab.dart';

class EmployeeProfilePage extends ConsumerStatefulWidget {
  final hr.HREmployee employee;
  const EmployeeProfilePage({super.key, required this.employee});

  @override
  ConsumerState<EmployeeProfilePage> createState() =>
      _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends ConsumerState<EmployeeProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.employee.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal & Job'),
            Tab(text: 'Documents'),
            Tab(text: 'Leave & Attendance'),
            Tab(text: 'Payroll'),
          ],
        ),
      ),
      body: ThemeBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              EmployeeDetailsTab(employee: widget.employee),
              EmployeeDocumentsTab(employee: widget.employee),
              EmployeeLeaveTab(employee: widget.employee),
              EmployeePayrollTab(employee: widget.employee),
            ],
          ),
        ),
      ),
    );
  }
}
