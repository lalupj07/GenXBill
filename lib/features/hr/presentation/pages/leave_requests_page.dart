import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/hr/providers/hr_providers.dart';
import 'package:genx_bill/features/hr/data/models/leave_model.dart';
import 'package:genx_bill/core/widgets/theme_background.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/core/models/user_role.dart';
import 'package:intl/intl.dart';

class LeaveRequestsPage extends ConsumerWidget {
  const LeaveRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to fetch pending leaves and also the corresponding employees to show names
    final pendingLeaves = ref.watch(pendingLeavesProvider);
    final employeeRepo = ref.watch(employeeRepositoryProvider);

    // Authorization check (optional, but good practice)
    final currentUserRole = ref.watch(settingsProvider).currentUserRole;
    final canApprove = currentUserRole == UserRole.admin ||
        currentUserRole == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ThemeBackground(
        child: pendingLeaves.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt,
                        size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('No pending requests',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingLeaves.length,
                itemBuilder: (context, index) {
                  final leave = pendingLeaves[index];
                  final employee = employeeRepo.getEmployee(leave.employeeId);
                  final empName = employee?.name ?? 'Unknown Employee';
                  final designation = employee?.position ?? '';

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
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.2),
                                    child: Text(empName.substring(0, 1),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(empName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(designation,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(leave.leaveTypeName,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor:
                                    Colors.blue.withValues(alpha: 0.1),
                              )
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.date_range,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                  '${DateFormat('dd MMM').format(leave.startDate)} - ${DateFormat('dd MMM yyyy').format(leave.endDate)}'),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text('${leave.numberOfDays} days',
                                    style: const TextStyle(fontSize: 12)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (leave.reason.isNotEmpty)
                            Text('Reason: ${leave.reason}',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)),
                          const SizedBox(height: 16),
                          if (canApprove)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () =>
                                      _rejectLeave(context, ref, leave),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: const Text("Reject"),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () =>
                                      _approveLeave(context, ref, leave),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text("Approve"),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _approveLeave(
      BuildContext context, WidgetRef ref, Leave leave) async {
    final currentUser = ref.read(settingsProvider).currentUserRole.name;
    await ref.read(leaveRepositoryProvider).approveLeave(leave.id, currentUser);

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Leave Approved")));
      ref.invalidate(pendingLeavesProvider); // Refresh list
    }
  }

  Future<void> _rejectLeave(
      BuildContext context, WidgetRef ref, Leave leave) async {
    final currentUser = ref.read(settingsProvider).currentUserRole.name;
    // Assuming simple reject for now, could add reason dialog
    await ref
        .read(leaveRepositoryProvider)
        .rejectLeave(leave.id, currentUser, "Rejected by Admin");

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Leave Rejected")));
      ref.invalidate(pendingLeavesProvider); // Refresh list
    }
  }
}
