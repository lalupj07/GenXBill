import 'package:hive/hive.dart';

part 'holiday_model.g.dart';

@HiveType(typeId: 52)
enum HolidayType {
  @HiveField(0)
  public,
  @HiveField(1)
  optional,
  @HiveField(2)
  company,
}

@HiveType(typeId: 53)
class Holiday extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final HolidayType type;

  @HiveField(4)
  final bool isOptional;

  @HiveField(5)
  final String? description;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    this.isOptional = false,
    this.description,
  });

  factory Holiday.create({
    required String name,
    required DateTime date,
    required HolidayType type,
    bool isOptional = false,
    String? description,
  }) {
    return Holiday(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: date,
      type: type,
      isOptional: isOptional,
      description: description,
    );
  }

  Holiday copyWith({
    String? name,
    DateTime? date,
    HolidayType? type,
    bool? isOptional,
    String? description,
  }) {
    return Holiday(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      isOptional: isOptional ?? this.isOptional,
      description: description ?? this.description,
    );
  }

  String get typeName {
    switch (type) {
      case HolidayType.public:
        return 'Public Holiday';
      case HolidayType.optional:
        return 'Optional Holiday';
      case HolidayType.company:
        return 'Company Holiday';
    }
  }
}
