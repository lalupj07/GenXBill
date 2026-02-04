import 'package:hive/hive.dart';

enum PaymentMethod {
  cash,
  check,
  bankTransfer,
  card,
  other,
}

class Payment extends HiveObject {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final String? reference; // Check number, transaction ID, etc.
  final String? notes;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.reference,
    this.notes,
  });
}

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 5;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      id: fields[0] as String,
      invoiceId: fields[1] as String,
      amount: fields[2] as double,
      paymentDate: fields[3] as DateTime,
      method: PaymentMethod.values[fields[4] as int],
      reference: fields[5] as String?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentDate)
      ..writeByte(4)
      ..write(obj.method.index)
      ..writeByte(5)
      ..write(obj.reference)
      ..writeByte(6)
      ..write(obj.notes);
  }
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 6;

  @override
  PaymentMethod read(BinaryReader reader) {
    return PaymentMethod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    writer.writeByte(obj.index);
  }
}
