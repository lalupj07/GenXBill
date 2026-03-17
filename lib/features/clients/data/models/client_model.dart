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
  double creditLimit;

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
    this.creditLimit = 0.0,
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
    double? creditLimit,
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
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxId': taxId,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'type': type.index,
      'creditLimit': creditLimit,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      taxId: json['taxId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      type: ClientType.values[json['type'] as int? ?? 0],
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
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
      id: (fields.containsKey(0) && fields[0] != null) ? fields[0] as String : '',
      name: (fields.containsKey(1) && fields[1] != null) ? fields[1] as String : '',
      email: (fields.containsKey(2) && fields[2] != null) ? fields[2] as String : '',
      phone: (fields.containsKey(3) && fields[3] != null) ? fields[3] as String : '',
      address: (fields.containsKey(4) && fields[4] != null) ? fields[4] as String : '',
      taxId: fields.containsKey(5) ? fields[5] as String? : null,
      createdAt: (fields.containsKey(6) && fields[6] != null) ? fields[6] as DateTime : DateTime.now(),
      notes: fields.containsKey(7) ? fields[7] as String? : null,
      type: fields.containsKey(8)
          ? ClientType.values[fields[8] as int]
          : ClientType.customer,
      creditLimit: fields.containsKey(9) ? fields[9] as double : 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.type.index)
      ..writeByte(9)
      ..write(obj.creditLimit);
  }
}
