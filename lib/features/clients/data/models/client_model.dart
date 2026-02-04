import 'package:hive/hive.dart';

enum ClientType { customer, supplier }

class Client extends HiveObject {
  final String id;
  String name;
  String email;
  String phone;
  String address;
  String? taxId;
  DateTime createdAt;
  String? notes;
  ClientType type;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.taxId,
    required this.createdAt,
    this.notes,
    this.type = ClientType.customer,
  });

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxId,
    DateTime? createdAt,
    String? notes,
    ClientType? type,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      type: type ?? this.type,
    );
  }
}

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 3;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      address: fields[4] as String,
      taxId: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      notes: fields[7] as String?,
      type: fields.containsKey(8)
          ? ClientType.values[fields[8] as int]
          : ClientType.customer,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.taxId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.type.index);
  }
}
