import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 7)
enum ExpenseCategory {
  @HiveField(0)
  office,
  @HiveField(1)
  travel,
  @HiveField(2)
  supplies,
  @HiveField(3)
  utilities,
  @HiveField(4)
  marketing,
  @HiveField(5)
  salary,
  @HiveField(6)
  rent,
  @HiveField(7)
  equipment,
  @HiveField(8)
  software,
  @HiveField(9)
  other,
}

@HiveType(typeId: 8)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? vendor;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.vendor,
  });

  String getCategoryName() {
    switch (category) {
      case ExpenseCategory.office:
        return 'Office Supplies';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.salary:
        return 'Salary';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.software:
        return 'Software';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index,
      'notes': notes,
      'vendor': vendor,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.values[json['category'] as int],
      notes: json['notes'] as String?,
      vendor: json['vendor'] as String?,
    );
  }
}
