import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/reminders/data/models/payment_reminder.dart';
import 'package:genx_bill/features/reminders/data/repositories/reminder_repository.dart';

/// Repository provider
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

/// All reminders provider
final allRemindersProvider = Provider<List<PaymentReminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getAllReminders();
});

/// Active reminders provider
final activeRemindersProvider = Provider<List<PaymentReminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getActiveReminders();
});

/// Overdue reminders provider
final overdueRemindersProvider = Provider<List<PaymentReminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getOverdueReminders();
});

/// Reminder settings state
class ReminderSettings {
  final bool enableAutoReminders;
  final bool enableEmailReminders;
  final bool enableWhatsAppReminders;
  final List<ReminderSchedule> defaultSchedules;

  ReminderSettings({
    this.enableAutoReminders = true,
    this.enableEmailReminders = true,
    this.enableWhatsAppReminders = false,
    List<ReminderSchedule>? defaultSchedules,
  }) : defaultSchedules = defaultSchedules ?? DefaultReminderSchedules.standard;

  ReminderSettings copyWith({
    bool? enableAutoReminders,
    bool? enableEmailReminders,
    bool? enableWhatsAppReminders,
    List<ReminderSchedule>? defaultSchedules,
  }) {
    return ReminderSettings(
      enableAutoReminders: enableAutoReminders ?? this.enableAutoReminders,
      enableEmailReminders: enableEmailReminders ?? this.enableEmailReminders,
      enableWhatsAppReminders: enableWhatsAppReminders ?? this.enableWhatsAppReminders,
      defaultSchedules: defaultSchedules ?? this.defaultSchedules,
    );
  }
}

/// Reminder settings notifier
class ReminderSettingsNotifier extends StateNotifier<ReminderSettings> {
  ReminderSettingsNotifier() : super(ReminderSettings());

  void updateSettings({
    bool? enableAutoReminders,
    bool? enableEmailReminders,
    bool? enableWhatsAppReminders,
    List<ReminderSchedule>? defaultSchedules,
  }) {
    state = state.copyWith(
      enableAutoReminders: enableAutoReminders,
      enableEmailReminders: enableEmailReminders,
      enableWhatsAppReminders: enableWhatsAppReminders,
      defaultSchedules: defaultSchedules,
    );
  }

  void toggleAutoReminders() {
    state = state.copyWith(enableAutoReminders: !state.enableAutoReminders);
  }

  void toggleEmailReminders() {
    state = state.copyWith(enableEmailReminders: !state.enableEmailReminders);
  }

  void toggleWhatsAppReminders() {
    state = state.copyWith(enableWhatsAppReminders: !state.enableWhatsAppReminders);
  }
}

final reminderSettingsProvider = StateNotifierProvider<ReminderSettingsNotifier, ReminderSettings>((ref) {
  return ReminderSettingsNotifier();
});

/// Reminder actions notifier
class ReminderNotifier extends StateNotifier<AsyncValue<void>> {
  final ReminderRepository _repository;

  ReminderNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createReminder(PaymentReminder reminder) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteReminder(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsCompleted(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsCompleted(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(String reminderId, ReminderLog log) async {
    try {
      await _repository.addLog(reminderId, log);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return ReminderNotifier(repository);
});
