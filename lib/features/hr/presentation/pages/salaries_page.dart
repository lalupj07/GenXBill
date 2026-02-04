import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/data/models/salary_record.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/core/services/logger_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';

class SalariesPage extends ConsumerStatefulWidget {
  const SalariesPage({super.key});

  @override
  ConsumerState<SalariesPage> createState() => _SalariesPageState();
}

class _SalariesPageState extends ConsumerState<SalariesPage> {
  @override
  Widget build(BuildContext context) {
    var salaryBox = Hive.box<SalaryRecord>('salary_records');
    final employees = ref.watch(allEmployeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Salary Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ThemeBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildSummaryHeader(salaryBox.values.toList()),
              const SizedBox(height: 24),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: salaryBox.listenable(),
                  builder: (context, Box<SalaryRecord> box, _) {
                    final records = box.values.toList();
                    records.sort((a, b) => b.payDate.compareTo(a.payDate));

                    if (records.isEmpty) {
                      return const Center(
                          child: Text('No salary records found.'));
                    }

                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final employee = employees.firstWhere(
                          (e) => e.id == record.employeeId,
                          orElse: () => HREmployee(
                            id: '',
                            employeeCode: 'N/A',
                            name: 'Unknown Staff',
                            email: '',
                            phone: '',
                            department: 'N/A',
                            position: 'N/A',
                            joinDate: DateTime.now(),
                            salary: 0,
                          ),
                        );

                        return _buildSalaryCard(record, employee);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSalaryDialog(context),
        icon: const Icon(Icons.add_card),
        label: const Text('Record Payment'),
        backgroundColor: AppTheme.primaryColor,
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildSummaryHeader(List<SalaryRecord> records) {
    final thisMonth = DateTime.now().month;
    final thisYear = DateTime.now().year;
    final monthlyTotal = records
        .where(
            (r) => r.payDate.month == thisMonth && r.payDate.year == thisYear)
        .fold<double>(0, (sum, r) => sum + r.netSalary);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Payout (This Month)',
                  style: TextStyle(color: Colors.grey)),
              Text('\$${monthlyTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent)),
            ],
          ),
          const Icon(Icons.account_balance_wallet,
              size: 48, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildSalaryCard(SalaryRecord record, HREmployee employee) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Text(employee.name.isNotEmpty ? employee.name[0] : '?'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('dd MMM yyyy').format(record.payDate),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${record.netSalary.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              Text(record.paymentMethod,
                  style: TextStyle(color: Colors.grey[400], fontSize: 10)),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () => _deleteRecord(record),
          ),
        ],
      ),
    );
  }

  void _showAddSalaryDialog(BuildContext context) {
    final employeesList = ref.read(allEmployeesProvider);
    HREmployee? selectedEmployee;
    final amountController = TextEditingController();
    final bonusController = TextEditingController(text: '0');
    final deductController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String paymentMethod = 'Bank Transfer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Record Salary Payment'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<HREmployee>(
                    decoration: const InputDecoration(labelText: 'Employee *'),
                    items: employeesList.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e.name));
                    }).toList(),
                    onChanged: (val) {
                      selectedEmployee = val;
                      if (val != null) {
                        amountController.text = val.salary.toString();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration:
                        const InputDecoration(labelText: 'Basic Salary *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bonusController,
                          decoration: const InputDecoration(labelText: 'Bonus'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: deductController,
                          decoration:
                              const InputDecoration(labelText: 'Deductions'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMethod,
                    decoration:
                        const InputDecoration(labelText: 'Payment Method'),
                    items: ['Bank Transfer', 'Cash', 'Cheque', 'UPI']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => paymentMethod = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedEmployee != null &&
                    amountController.text.isNotEmpty) {
                  final base = double.tryParse(amountController.text) ?? 0;
                  final bonus = double.tryParse(bonusController.text) ?? 0;
                  final deduct = double.tryParse(deductController.text) ?? 0;

                  final record = SalaryRecord(
                    id: const Uuid().v4(),
                    employeeId: selectedEmployee!.id,
                    payDate: DateTime.now(),
                    basicSalary: base,
                    bonuses: bonus,
                    deductions: deduct,
                    notes: notesController.text,
                    paymentMethod: paymentMethod,
                  );

                  await Hive.box<SalaryRecord>('salary_records')
                      .put(record.id, record);
                  ref.read(loggerServiceProvider).log('Salary Payment',
                      'Paid salary to ${selectedEmployee!.name}');

                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRecord(SalaryRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('This will remove the salary payment record.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await record.delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
