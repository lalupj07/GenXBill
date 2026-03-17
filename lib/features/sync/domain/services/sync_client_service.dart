import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:genx_bill/features/inventory/data/models/inventory_item_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/inventory/providers/inventory_providers.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';
import 'package:genx_bill/features/employees/data/repositories/employee_repository.dart';
import 'package:genx_bill/core/services/logger_service.dart';

final syncClientServiceProvider = Provider((ref) => SyncClientService(ref));

class SyncClientService {
  final Ref _ref;

  SyncClientService(this._ref);

  Future<void> syncFromHost(String hostIp, {int port = 8080}) async {
    final baseUrl = 'http://$hostIp:$port/api';

    try {
      // 1. Sync Products
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final products = jsonList.map((j) => Product.fromJson(j)).toList();

        final repo = _ref.read(productRepositoryProvider);
        for (var p in products) {
          // Upsert products
          await repo.updateProduct(p);
        }
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }

      // 2. Sync Clients
      final clientResponse = await http.get(Uri.parse('$baseUrl/clients'));
      if (clientResponse.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(clientResponse.body);
        final clients = jsonList.map((j) => Client.fromJson(j)).toList();

        final clientRepo = _ref.read(clientRepositoryProvider);
        for (var c in clients) {
          // We assume the repository has updateClient or similar.
          // If updateClient doesn't exist, we might need addClient or direct box access if we exposed it.
          // Usually repos have add/update.
          await clientRepo.updateClient(c);
        }
      }

      // 3. Sync Expenses
      final expenseResponse = await http.get(Uri.parse('$baseUrl/expenses'));
      if (expenseResponse.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(expenseResponse.body);
        final expenses = jsonList.map((j) => Expense.fromJson(j)).toList();
        final expenseRepo = _ref.read(expenseRepositoryProvider);
        for (var e in expenses) {
          await expenseRepo.updateExpense(e);
        }
      }

      // 4. Sync Inventory Items
      final inventoryResponse = await http.get(Uri.parse('$baseUrl/inventory'));
      if (inventoryResponse.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(inventoryResponse.body);
        final items = jsonList.map((j) => InventoryItem.fromJson(j)).toList();
        final inventoryRepo = _ref.read(inventoryRepositoryProvider);
        for (var i in items) {
          await inventoryRepo.updateItem(i);
        }
      }

      // 5. Sync Stock Movements
      final movementResponse =
          await http.get(Uri.parse('$baseUrl/stock-movements'));
      if (movementResponse.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(movementResponse.body);
        final movements =
            jsonList.map((j) => StockMovement.fromJson(j)).toList();
        final movementRepo = _ref.read(stockMovementRepositoryProvider);
        for (var m in movements) {
          await movementRepo.addMovement(m);
        }
      }

      // 6. Sync Employees
      final employeeResponse = await http.get(Uri.parse('$baseUrl/employees'));
      if (employeeResponse.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(employeeResponse.body);
        final employees = jsonList.map((j) => Employee.fromJson(j)).toList();
        final employeeRepo = _ref.read(employeeRepositoryProvider);
        for (var e in employees) {
          await employeeRepo.updateEmployee(e);
        }
      }
    } catch (e) {
      _ref.read(loggerServiceProvider).log('Sync Client', 'Error syncing: $e');
      rethrow;
    }
  }

  Future<void> pushInvoice(String hostIp, Invoice invoice,
      {int port = 8080}) async {
    final url = Uri.parse('http://$hostIp:$port/api/invoices');
    try {
      final response = await http.post(url,
          body: jsonEncode(invoice.toJson()),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Failed to push invoice: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushExpense(String hostIp, Expense expense,
      {int port = 8080}) async {
    final url = Uri.parse('http://$hostIp:$port/api/expenses');
    try {
      final response = await http.post(url,
          body: jsonEncode(expense.toJson()),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Failed to push expense: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushStockMovement(String hostIp, StockMovement movement,
      {int port = 8080}) async {
    final url = Uri.parse('http://$hostIp:$port/api/stock-movements');
    try {
      final response = await http.post(url,
          body: jsonEncode(movement.toJson()),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Failed to push movement: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushEmployee(String hostIp, Employee employee,
      {int port = 8080}) async {
    final url = Uri.parse('http://$hostIp:$port/api/employees');
    try {
      final response = await http.post(url,
          body: jsonEncode(employee.toJson()),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Failed to push employee: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkConnection(String hostIp, {int port = 8080}) async {
    try {
      final response =
          await http.get(Uri.parse('http://$hostIp:$port/api/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
