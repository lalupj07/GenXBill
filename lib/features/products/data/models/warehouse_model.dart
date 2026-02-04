import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 11)
class Warehouse extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String location;
  @HiveField(3)
  final bool isActive;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    this.isActive = true,
  });

  factory Warehouse.create({
    required String name,
    required String location,
  }) {
    return Warehouse(
      id: const Uuid().v4(),
      name: name,
      location: location,
    );
  }
}

class WarehouseAdapter extends TypeAdapter<Warehouse> {
  @override
  final int typeId = 11;

  @override
  Warehouse read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return Warehouse(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Warehouse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.isActive);
  }
}
