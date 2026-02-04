import 'package:hive/hive.dart';
import 'user_role.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 31)
class ActivityLog extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String action;
  @HiveField(2)
  final String details;
  @HiveField(3)
  final DateTime timestamp;
  @HiveField(4)
  final UserRole userRole;

  ActivityLog({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.userRole,
  });

  factory ActivityLog.create({
    required String action,
    required String details,
    required UserRole userRole,
  }) {
    return ActivityLog(
      id: const Uuid().v4(),
      action: action,
      details: details,
      timestamp: DateTime.now(),
      userRole: userRole,
    );
  }
}

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 31;

  @override
  ActivityLog read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return ActivityLog(
      id: fields[0] as String,
      action: fields[1] as String,
      details: fields[2] as String,
      timestamp: fields[3] as DateTime,
      userRole: fields[4] as UserRole,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.userRole);
  }
}
