// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 8;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      description: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      category: fields[4] as ExpenseCategory,
      notes: fields[5] as String?,
      vendor: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.vendor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 7;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.office;
      case 1:
        return ExpenseCategory.travel;
      case 2:
        return ExpenseCategory.supplies;
      case 3:
        return ExpenseCategory.utilities;
      case 4:
        return ExpenseCategory.marketing;
      case 5:
        return ExpenseCategory.salary;
      case 6:
        return ExpenseCategory.rent;
      case 7:
        return ExpenseCategory.equipment;
      case 8:
        return ExpenseCategory.software;
      case 9:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.office;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.office:
        writer.writeByte(0);
        break;
      case ExpenseCategory.travel:
        writer.writeByte(1);
        break;
      case ExpenseCategory.supplies:
        writer.writeByte(2);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(3);
        break;
      case ExpenseCategory.marketing:
        writer.writeByte(4);
        break;
      case ExpenseCategory.salary:
        writer.writeByte(5);
        break;
      case ExpenseCategory.rent:
        writer.writeByte(6);
        break;
      case ExpenseCategory.equipment:
        writer.writeByte(7);
        break;
      case ExpenseCategory.software:
        writer.writeByte(8);
        break;
      case ExpenseCategory.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
