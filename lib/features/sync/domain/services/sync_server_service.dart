import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/invoices/data/repositories/invoice_repository.dart';
import 'package:genx_bill/features/invoices/data/models/invoice_model.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/inventory/data/models/stock_movement_model.dart';
import 'package:genx_bill/features/inventory/providers/inventory_providers.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';
import 'package:genx_bill/features/employees/data/repositories/employee_repository.dart';
import 'package:genx_bill/core/services/logger_service.dart';

final syncServerServiceProvider = Provider((ref) {
  return SyncServerService(ref);
});

final serverStatusProvider = StateProvider<bool>((ref) => false);
final serverIpProvider = StateProvider<String?>((ref) => null);

class SyncServerService {
  final Ref _ref;
  HttpServer? _server;

  SyncServerService(this._ref);

  Future<String?> getIpAddress() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  Future<void> startServer({int port = 8080}) async {
    if (_server != null) return;

    final app = Router();

    app.get('/api/health', (Request request) {
      return Response.ok(jsonEncode({'status': 'running', 'app': 'GenXBill'}));
    });

    app.get('/api/products', (Request request) {
      final productRepo = _ref.read(productRepositoryProvider);
      final products = productRepo.getAllProducts();
      final jsonList = products.map((p) => p.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.get('/api/clients', (Request request) {
      final clientRepo = _ref.read(clientRepositoryProvider);
      final clients = clientRepo.getAllClients();
      final jsonList = clients.map((c) => c.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.get('/api/expenses', (Request request) {
      final expenseRepo = _ref.read(expenseRepositoryProvider);
      final expenses = expenseRepo.getAllExpenses();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.get('/api/inventory', (Request request) {
      final inventoryRepo = _ref.read(inventoryRepositoryProvider);
      final items = inventoryRepo.getAllItems();
      final jsonList = items.map((i) => i.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.get('/api/stock-movements', (Request request) {
      final movementRepo = _ref.read(stockMovementRepositoryProvider);
      final movements = movementRepo.getAllMovements();
      final jsonList = movements.map((m) => m.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.get('/api/employees', (Request request) {
      final employeeRepo = _ref.read(employeeRepositoryProvider);
      final employees = employeeRepo.getAllEmployees();
      final jsonList = employees.map((e) => e.toJson()).toList();
      return Response.ok(jsonEncode(jsonList),
          headers: {'Content-Type': 'application/json'});
    });

    app.post('/api/invoices', (Request request) async {
      try {
        final payload = await request.readAsString();
        final json = jsonDecode(payload);
        final invoice = Invoice.fromJson(json);

        final invoiceRepo = _ref.read(invoiceRepositoryProvider);
        await invoiceRepo.addInvoice(invoice);

        return Response.ok(jsonEncode({'status': 'success', 'id': invoice.id}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}));
      }
    });

    app.post('/api/expenses', (Request request) async {
      try {
        final payload = await request.readAsString();
        final json = jsonDecode(payload);
        final expense = Expense.fromJson(json);

        final expenseRepo = _ref.read(expenseRepositoryProvider);
        await expenseRepo.addExpense(expense);

        return Response.ok(jsonEncode({'status': 'success', 'id': expense.id}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}));
      }
    });

    app.post('/api/stock-movements', (Request request) async {
      try {
        final payload = await request.readAsString();
        final json = jsonDecode(payload);
        final movement = StockMovement.fromJson(json);

        final movementRepo = _ref.read(stockMovementRepositoryProvider);
        await movementRepo.addMovement(movement);

        return Response.ok(
            jsonEncode({'status': 'success', 'id': movement.id}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}));
      }
    });

    app.post('/api/employees', (Request request) async {
      try {
        final payload = await request.readAsString();
        final json = jsonDecode(payload);
        final employee = Employee.fromJson(json);

        final employeeRepo = _ref.read(employeeRepositoryProvider);
        await employeeRepo.addEmployee(employee);

        return Response.ok(
            jsonEncode({'status': 'success', 'id': employee.id}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}));
      }
    });

    final handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(app.call);

    try {
      // Bind to any interface
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      final ip = await getIpAddress();

      _ref.read(serverStatusProvider.notifier).state = true;
      _ref.read(serverIpProvider.notifier).state = ip ?? 'Unknown';

      // Log only, remove print for production
      _ref
          .read(loggerServiceProvider)
          .log('Sync Server', 'Server running on $ip:$port');
    } catch (e) {
      _ref
          .read(loggerServiceProvider)
          .log('Sync Server', 'Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
    _ref.read(serverStatusProvider.notifier).state = false;
    _ref.read(serverIpProvider.notifier).state = null;
  }
}
