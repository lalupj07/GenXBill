import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;
import 'package:genx_bill/features/hr/data/models/leave_model.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:intl/intl.dart';

class EmployeeLeaveTab extends ConsumerStatefulWidget {
  final hr.HREmployee employee;
  const EmployeeLeaveTab({super.key, required this.employee});

  @override
  ConsumerState<EmployeeLeaveTab> createState() => _EmployeeLeaveTabState();
}

class _EmployeeLeaveTabState extends ConsumerState<EmployeeLeaveTab> {
  @override
  Widget build(BuildContext context) {
    final leaveRepo = ref.watch(leaveRepositoryProvider);
    final upcomingHolidays = ref.watch(upcomingHolidaysProvider);

    // Fetch leaves for this employee
    final allLeaves = leaveRepo.getLeavesByEmployee(widget.employee.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Leave Balances
          const Text("Leave Balances",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: Row(
              children: [
                _buildBalanceCard("Casual Leave",
                    widget.employee.getLeaveBalance('casual'), Colors.orange),
                const SizedBox(width: 12),
                _buildBalanceCard("Earned Leave",
                    widget.employee.getLeaveBalance('earned'), Colors.green),
                const SizedBox(width: 12),
                _buildBalanceCard("Sick Leave",
                    widget.employee.getLeaveBalance('sick'), Colors.redAccent),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Action & Holiday Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Upcoming Holidays",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
              ElevatedButton.icon(
                onPressed: () => _showApplyLeaveDialog(context),
                icon: const Icon(Icons.add_task),
                label: const Text("Apply Leave"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor),
              )
            ],
          ),
          const SizedBox(height: 12),

          // 3. Holidays List (Horizontal)
          SizedBox(
            height: 80,
            child: upcomingHolidays.isEmpty
                ? const Center(
                    child: Text("No upcoming holidays",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingHolidays.length,
                    itemBuilder: (context, index) {
                      final holiday = upcomingHolidays[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .cardColor
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holiday.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(DateFormat('dd MMM yyyy').format(holiday.date),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 24),

          // 4. Leave History
          const Text("Leave History",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          allLeaves.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No leave history",
                      style: TextStyle(color: Colors.grey)),
                ))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allLeaves.length,
                  itemBuilder: (context, index) {
                    final leave = allLeaves[index];
                    return Card(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _buildStatusIcon(leave.status),
                        title: Text(
                            '${leave.leaveTypeName} (${leave.numberOfDays} days)'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${DateFormat('dd MMM').format(leave.startDate)} - ${DateFormat('dd MMM').format(leave.endDate)}'),
                              if (leave.reason.isNotEmpty)
                                Text("Reason: ${leave.reason}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic)),
                            ]),
                        trailing: Chip(
                          label: Text(leave.status.name.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white)),
                          backgroundColor: _getStatusColor(leave.status),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  },
                )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, double balance, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            Text(balance.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.cancelled:
        return Colors.grey;
    }
  }

  Widget _buildStatusIcon(LeaveStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case LeaveStatus.approved:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case LeaveStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case LeaveStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case LeaveStatus.cancelled:
        icon = Icons.remove_circle_outline;
        color = Colors.grey;
        break;
    }
    return Icon(icon, color: color);
  }

  void _showApplyLeaveDialog(BuildContext context) {
    // Form Controller
    final reasonController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    LeaveType selectedType = LeaveType.casual;
    bool isHalfDay = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Apply For Leave"),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<LeaveType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                          labelText: "Leave Type",
                          border: OutlineInputBorder()),
                      items: LeaveType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(startDate == null
                                ? "Start Date"
                                : DateFormat('dd-MM-yyyy').format(startDate!)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(endDate == null
                                ? "End Date"
                                : DateFormat('dd-MM-yyyy').format(endDate!)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text("Half Day?"),
                      value: isHalfDay,
                      onChanged: (val) =>
                          setDialogState(() => isHalfDay = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                          labelText: "Reason", border: OutlineInputBorder()),
                      maxLines: 3,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please select valid dates")));
                    return;
                  }

                  final leave = Leave.create(
                    employeeId: widget.employee.id,
                    leaveType: selectedType,
                    startDate: startDate!,
                    endDate: endDate!,
                    reason: reasonController.text,
                    isHalfDay: isHalfDay,
                  );

                  await ref.read(leaveRepositoryProvider).addLeave(leave);
                  if (context.mounted) Navigator.pop(context); // Close dialog
                  setState(() {}); // Refresh UI
                },
                child: const Text("Apply"),
              )
            ],
          );
        },
      ),
    );
  }
}
