import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

class Employee {
  final String id;
  final String name;
  final String role;
  final String email;
  final String phone;
  final DateTime joinDate;
  final double salary;
  final bool isActive;
  final String notes;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.salary,
    this.isActive = true,
    this.notes = '',
  });

  factory Employee.create({
    required String name,
    required String role,
    required String email,
    required String phone,
    required double salary,
    String notes = '',
  }) {
    return Employee(
      id: const Uuid().v4(),
      name: name,
      role: role,
      email: email,
      phone: phone,
      joinDate: DateTime.now(),
      salary: salary,
      notes: notes,
    );
  }

  Employee copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? phone,
    DateTime? joinDate,
    double? salary,
    bool? isActive,
    String? notes,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 60;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String,
      joinDate: fields[5] as DateTime,
      salary: fields[6] as double,
      isActive: fields[7] as bool,
      notes: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.joinDate)
      ..writeByte(6)
      ..write(obj.salary)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.notes);
  }
}
