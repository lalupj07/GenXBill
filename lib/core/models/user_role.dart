import 'package:hive/hive.dart';

@HiveType(typeId: 30)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  manager,
  @HiveField(2)
  cashier,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
    }
  }

  bool get canEditPrice => this == UserRole.admin || this == UserRole.manager;
  bool get canApplyHighDiscount =>
      this == UserRole.admin || this == UserRole.manager;
  bool get canSeeFullReports =>
      this == UserRole.admin || this == UserRole.manager;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 30;

  @override
  UserRole read(BinaryReader reader) {
    return UserRole.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    writer.writeByte(obj.index);
  }
}
