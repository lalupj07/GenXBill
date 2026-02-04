import 'package:hive/hive.dart';

part 'inventory_transaction.g.dart';

@HiveType(typeId: 13)
enum TransactionType {
  @HiveField(0)
  purchase,
  @HiveField(1)
  sale,
  @HiveField(2)
  returnIn,
  @HiveField(3)
  returnOut,
  @HiveField(4)
  adjustment, // e.g. stock take
  @HiveField(5)
  damage,
}

@HiveType(typeId: 14)
class InventoryTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final double
      quantity; // Positive for in, Negative for out? Or just absolute value and Type determines? Best to keep absolute and let Type dictate logic, but signed makes summation easier. Let's use signed. + for in, - for out.

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? batchId;

  @HiveField(7)
  final String? serialNumber;

  @HiveField(8)
  final String? performedBy;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final String? referenceId; // e.g., Invoice ID or PO ID

  InventoryTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.batchId,
    this.serialNumber,
    this.performedBy,
    this.notes,
    this.referenceId,
  });
}
