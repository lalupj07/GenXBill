import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/activity_log.dart';
import '../models/user_role.dart';
import '../providers/settings_provider.dart';

final activityLogBoxProvider = Provider<Box<ActivityLog>>((ref) {
  return Hive.box<ActivityLog>('activity_logs');
});

final loggerServiceProvider = Provider<LoggerService>((ref) {
  final box = ref.watch(activityLogBoxProvider);
  final settings = ref.watch(settingsProvider);
  return LoggerService(box, settings.currentUserRole);
});

class LoggerService {
  final Box<ActivityLog> _box;
  final UserRole _currentRole;

  LoggerService(this._box, this._currentRole);

  Future<void> log(String action, String details) async {
    final log = ActivityLog.create(
      action: action,
      details: details,
      userRole: _currentRole,
    );
    await _box.add(log);
  }

  List<ActivityLog> getLogs() {
    return _box.values.toList().reversed.toList();
  }

  Future<void> clearLogs() async {
    await _box.clear();
  }
}
