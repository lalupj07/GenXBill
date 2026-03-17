import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:genx_bill/features/reminders/data/models/payment_reminder.dart';

class ReminderSettingsWidget extends ConsumerWidget {
  const ReminderSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);
    final activeReminders = ref.watch(activeRemindersProvider);
    final overdueReminders = ref.watch(overdueRemindersProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active,
                  color: AppTheme.primaryColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Payment Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Automated reminders for overdue invoices',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions,
                  label: 'Active Reminders',
                  value: activeReminders.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning,
                  label: 'Overdue',
                  value: overdueReminders.length.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings Toggles
          _SettingToggle(
            icon: Icons.auto_mode,
            title: 'Auto Reminders',
            subtitle: 'Automatically send reminders for overdue invoices',
            value: settings.enableAutoReminders,
            onChanged: (value) {
              ref.read(reminderSettingsProvider.notifier).toggleAutoReminders();
            },
          ),
          const SizedBox(height: 16),

          _SettingToggle(
            icon: Icons.email,
            title: 'Email Reminders',
            subtitle: 'Send reminders via email',
            value: settings.enableEmailReminders,
            onChanged: (value) {
              ref
                  .read(reminderSettingsProvider.notifier)
                  .toggleEmailReminders();
            },
          ),
          const SizedBox(height: 16),

          _SettingToggle(
            icon: Icons.chat,
            title: 'WhatsApp Reminders',
            subtitle: 'Send reminders via WhatsApp (requires phone numbers)',
            value: settings.enableWhatsAppReminders,
            onChanged: (value) {
              ref
                  .read(reminderSettingsProvider.notifier)
                  .toggleWhatsAppReminders();
            },
          ),
          const SizedBox(height: 24),

          // Default Schedule Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule,
                        color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Default Reminder Schedule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...settings.defaultSchedules.map((schedule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getScheduleColor(schedule.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getScheduleDescription(schedule),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reminders are checked daily. Configure SMTP settings in Email Settings for email reminders to work.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScheduleColor(ReminderType type) {
    switch (type) {
      case ReminderType.friendly:
        return Colors.green;
      case ReminderType.dueDate:
        return Colors.blue;
      case ReminderType.overdue:
        return Colors.orange;
      case ReminderType.finalReminder:
        return Colors.red;
    }
  }

  String _getScheduleDescription(ReminderSchedule schedule) {
    if (schedule.daysBeforeDue > 0) {
      return '${schedule.daysBeforeDue} days before due date (${schedule.type.name})';
    } else if (schedule.daysAfterDue > 0) {
      return '${schedule.daysAfterDue} days after due date (${schedule.type.name})';
    } else {
      return 'On due date (${schedule.type.name})';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
