import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/hr_providers.dart';
import '../../../../core/widgets/main_layout.dart';
import '../../../../core/widgets/theme_background.dart';
import '../../../../core/providers/settings_provider.dart'; // Add import
import 'employees_page.dart';
import 'attendance_page.dart';
import 'salaries_page.dart';
import 'performance_page.dart';
import 'leave_requests_page.dart';

class HRDashboardPage extends ConsumerWidget {
  const HRDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(hrDashboardStatsProvider);
    final pendingLeaves = ref.watch(pendingLeavesProvider);
    final upcomingHolidays = ref.watch(upcomingHolidaysProvider);

    return Scaffold(
      body: ThemeBackground(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          // Go back to Home (index 0)
                          ref.read(navigationProvider.notifier).state = 0;
                        },
                        tooltip: 'Back to Home',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HR & Attendance',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Employee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Employees',
                      value: stats['totalEmployees'].toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Employees',
                      value: stats['activeEmployees'].toString(),
                      icon: Icons.person,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Present Today',
                      value: stats['todayPresent'].toString(),
                      icon: Icons.check_circle,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Pending Leaves',
                      value: stats['pendingLeaves'].toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Quick Actions
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Actions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _QuickActionButton(
                                  icon: Icons.people,
                                  label: 'Manage Employees',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EmployeesPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _QuickActionButton(
                                  icon: Icons.calendar_today,
                                  label: 'Mark Attendance',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AttendancePage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _QuickActionButton(
                                  icon: Icons.event_note,
                                  label: 'Leave Management',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LeaveRequestsPage(),
                                      ),
                                    );
                                  },
                                ),
                                _QuickActionButton(
                                  icon: Icons.payments,
                                  label: 'Manage Salaries',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SalariesPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _QuickActionButton(
                                  icon: Icons.trending_up,
                                  label: 'Staff Performance',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PerformancePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column - Pending Leaves & Holidays
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          // Pending Leaves
                          Expanded(
                            child: GlassContainer(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Pending Leave Requests',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LeaveRequestsPage(),
                                            ),
                                          );
                                        },
                                        child: const Text('View All'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: pendingLeaves.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No pending leave requests',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: pendingLeaves.length > 5
                                                ? 5
                                                : pendingLeaves.length,
                                            itemBuilder: (context, index) {
                                              final leave =
                                                  pendingLeaves[index];
                                              return Card(
                                                color: Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: ListTile(
                                                  leading: const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    leave.leaveTypeName,
                                                  ),
                                                  subtitle: Text(
                                                    '${leave.numberOfDays} days - ${leave.reason}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () async {
                                                          // Inline Approve
                                                          final currentUser = ref
                                                              .read(
                                                                  settingsProvider)
                                                              .currentUserRole
                                                              .name;
                                                          await ref
                                                              .read(
                                                                  leaveRepositoryProvider)
                                                              .approveLeave(
                                                                  leave.id,
                                                                  currentUser);
                                                          // ref.refresh(pendingLeavesProvider); // Riverpod auto-refreshes if provider watches repo, but here we depend on repo method
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () async {
                                                          // Inline Reject
                                                          final currentUser = ref
                                                              .read(
                                                                  settingsProvider)
                                                              .currentUserRole
                                                              .name;
                                                          await ref
                                                              .read(
                                                                  leaveRepositoryProvider)
                                                              .rejectLeave(
                                                                  leave.id,
                                                                  currentUser,
                                                                  "Rejected from Dashboard");
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Upcoming Holidays
                          GlassContainer(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upcoming Holidays',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 150,
                                  child: upcomingHolidays.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No upcoming holidays',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: upcomingHolidays.length > 3
                                              ? 3
                                              : upcomingHolidays.length,
                                          itemBuilder: (context, index) {
                                            final holiday =
                                                upcomingHolidays[index];
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.celebration,
                                                color: Colors.amber,
                                              ),
                                              title: Text(holiday.name),
                                              subtitle: Text(
                                                '${holiday.date.day}/${holiday.date.month}/${holiday.date.year}',
                                              ),
                                              trailing: Text(
                                                holiday.typeName,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
