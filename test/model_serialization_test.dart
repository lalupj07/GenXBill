import 'package:flutter_test/flutter_test.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';

void main() {
  group('Model JSON Serialization Tests', () {
    test('Expense toJson/fromJson', () {
      final expense = Expense(
        id: '1',
        description: 'Office Chair',
        amount: 5000.0,
        date: DateTime(2023, 10, 1),
        category: ExpenseCategory.office,
        vendor: 'Amazon',
      );

      final json = expense.toJson();
      final fromJson = Expense.fromJson(json);

      expect(fromJson.id, expense.id);
      expect(fromJson.description, expense.description);
      expect(fromJson.amount, expense.amount);
      expect(fromJson.category, expense.category);
    });

    test('InventoryItem toJson/fromJson', () {
      final item = InventoryItem(
        id: 'inv1',
        productId: 'p1',
        productName: 'Laptop',
        sku: 'LAP-001',
        currentStock: 10,
        minimumStock: 5,
        reorderPoint: 7,
        reorderQuantity: 5,
        location: 'Shelf A',
        costPrice: 40000,
        sellingPrice: 55000,
        lastUpdated: DateTime(2023, 10, 1),
        updatedBy: 'Admin',
        status: InventoryStatus.inStock,
      );

      final json = item.toJson();
      final fromJson = InventoryItem.fromJson(json);

      expect(fromJson.productId, item.productId);
      expect(fromJson.currentStock, item.currentStock);
      expect(fromJson.costPrice, item.costPrice);
    });

    test('StockMovement toJson/fromJson', () {
      final movement = StockMovement(
        id: 'm1',
        inventoryItemId: 'inv1',
        productId: 'p1',
        productName: 'Laptop',
        type: MovementType.adjustment,
        quantity: 2,
        previousStock: 10,
        newStock: 12,
        reason: 'Correction',
        timestamp: DateTime(2023, 10, 1),
        performedBy: 'Admin',
      );

      final json = movement.toJson();
      final fromJson = StockMovement.fromJson(json);

      expect(fromJson.type, movement.type);
      expect(fromJson.quantity, movement.quantity);
    });

    test('Employee toJson/fromJson', () {
      final employee = Employee(
        id: 'emp1',
        name: 'John Doe',
        role: 'Manager',
        email: 'john@example.com',
        phone: '1234567890',
        joinDate: DateTime(2023, 1, 1),
        salary: 50000,
      );

      final json = employee.toJson();
      final fromJson = Employee.fromJson(json);

      expect(fromJson.name, employee.name);
      expect(fromJson.salary, employee.salary);
    });

    test('Product toJson/fromJson', () {
      final product = Product(
        id: 'p1',
        name: 'Gadget',
        description: 'New Gadget',
        unitPrice: 100.0,
      );

      final json = product.toJson();
      final fromJson = Product.fromJson(json);

      expect(fromJson.name, product.name);
      expect(fromJson.unitPrice, product.unitPrice);
    });

    test('Client toJson/fromJson', () {
      final client = Client(
        id: 'c1',
        name: 'XYZ Corp',
        email: 'contact@xyz.com',
        phone: '9876543210',
        address: 'Downtown',
        createdAt: DateTime(2023, 10, 1),
        creditLimit: 50000.0,
      );

      final json = client.toJson();
      final fromJson = Client.fromJson(json);

      expect(fromJson.name, client.name);
      expect(fromJson.email, client.email);
      expect(fromJson.creditLimit, client.creditLimit);
    });
  });
}
