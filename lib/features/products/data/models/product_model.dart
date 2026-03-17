import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 10)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double unitPrice;
  @HiveField(4)
  final double taxRate;
  @HiveField(5)
  final bool isActive;
  @HiveField(6)
  final String sku;
  @HiveField(7)
  final double stockQuantity;
  @HiveField(8)
  final double minStockLevel;
  @HiveField(9)
  final String hsnCode;

  // New Inventory Fields
  @HiveField(10)
  final bool isBatchTracked;

  @HiveField(11)
  final bool isSerialized;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    this.taxRate = 0.0,
    this.isActive = true,
    this.sku = '',
    this.stockQuantity = 0.0,
    this.minStockLevel = 0.0,
    this.hsnCode = '',
    this.isBatchTracked = false,
    this.isSerialized = false,
  });

  factory Product.create({
    required String name,
    required String description,
    required double unitPrice,
    double taxRate = 0.0,
    String sku = '',
    double stockQuantity = 0.0,
    double minStockLevel = 0.0,
    String hsnCode = '',
    bool isSerialized = false,
    bool isBatchTracked = false,
  }) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      description: description,
      unitPrice: unitPrice,
      taxRate: taxRate,
      sku: sku,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      hsnCode: hsnCode,
      isSerialized: isSerialized,
      isBatchTracked: isBatchTracked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'isActive': isActive,
      'sku': sku,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'hsnCode': hsnCode,
      'isBatchTracked': isBatchTracked,
      'isSerialized': isSerialized,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      sku: json['sku'] as String? ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 0.0,
      hsnCode: json['hsnCode'] as String? ?? '',
      isBatchTracked: json['isBatchTracked'] as bool? ?? false,
      isSerialized: json['isSerialized'] as bool? ?? false,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? unitPrice,
    double? taxRate,
    bool? isActive,
    String? sku,
    double? stockQuantity,
    double? minStockLevel,
    String? hsnCode,
    bool? isBatchTracked,
    bool? isSerialized,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      hsnCode: hsnCode ?? this.hsnCode,
      isBatchTracked: isBatchTracked ?? this.isBatchTracked,
      isSerialized: isSerialized ?? this.isSerialized,
    );
  }
}
