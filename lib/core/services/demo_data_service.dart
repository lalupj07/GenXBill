import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/features/products/data/models/product_model.dart';
import 'package:genx_bill/features/clients/data/models/client_model.dart';
import 'package:genx_bill/features/products/data/repositories/product_repository.dart';
import 'package:genx_bill/features/clients/data/repositories/client_repository.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';
import 'package:genx_bill/features/employees/data/repositories/employee_repository.dart';
import 'package:genx_bill/features/expenses/data/models/expense_model.dart';
import 'package:genx_bill/features/expenses/data/repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:genx_bill/core/utils/app_logger.dart';

class DemoDataService {
  final WidgetRef ref;

  DemoDataService(this.ref);

  void populateDemoData() {
    AppLogger.info('Starting Demo Data Population...');
    _populateProducts();
    _populateClients();
    _populateEmployees();
    _populateExpenses();
    AppLogger.info('Demo Data Populated Successfully!');
  }

  void _populateProducts() {
    final productRepo = ref.read(productRepositoryProvider);
    if (productRepo.getAllProducts().isNotEmpty) return;

    final products = [
      Product.create(
        name: 'Web Design Package',
        description: 'Complete website design including UI/UX',
        unitPrice: 1500.0,
        sku: 'WEB-DES-001',
        stockQuantity: 100,
        minStockLevel: 5,
      ),
      Product.create(
        name: 'Mobile App Development',
        description: 'Native Flutter mobile application development',
        unitPrice: 5000.0,
        sku: 'MOB-APP-001',
        stockQuantity: 50,
        minStockLevel: 5,
        hsnCode: '998313',
      ),
      Product.create(
        name: 'SEO Consultation',
        description: 'Monthly SEO optimization and reporting',
        unitPrice: 500.0,
        sku: 'SEO-M-001',
        stockQuantity: 1000,
        minStockLevel: 0,
      ),
      Product.create(
        name: 'Hosting Server (Annual)',
        description: 'Premium cloud hosting server subscription',
        unitPrice: 120.0,
        sku: 'HOST-001',
        stockQuantity: 9999,
        minStockLevel: 0,
      ),
      Product.create(
        name: 'Logo Design',
        description: 'Professional vector logo design with 3 revisions',
        unitPrice: 300.0,
        sku: 'GRA-LOG-001',
        stockQuantity: 999,
        minStockLevel: 0,
      ),
    ];

    for (var p in products) {
      productRepo.addProduct(p);
    }
  }

  void _populateClients() {
    final clientRepo = ref.read(clientRepositoryProvider);
    if (clientRepo.getAllClients().isNotEmpty) return;

    final clients = [
      Client(
        id: const Uuid().v4(),
        name: 'Acme Corp',
        email: 'contact@acmecorp.com',
        phone: '123-456-7890',
        address: '123 Business Rd, Tech City, CA',
        taxId: 'US123456789',
        type: ClientType.customer,
        createdAt: DateTime.now(),
      ),
      Client(
        id: const Uuid().v4(),
        name: 'Global Tech Solutions',
        email: 'info@globaltech.com',
        phone: '987-654-3210',
        address: '456 Innovation Dr, New York, NY',
        taxId: 'US987654321',
        type: ClientType.customer,
        createdAt: DateTime.now(),
      ),
      Client(
        id: const Uuid().v4(),
        name: 'Office Supplies Co.',
        email: 'sales@officesupplies.com',
        phone: '555-123-4567',
        address: '789 Paper St, Scranton, PA',
        type: ClientType.supplier,
        createdAt: DateTime.now(),
      ),
    ];

    for (var c in clients) {
      clientRepo.addClient(c);
    }
  }

  void _populateEmployees() {
    final employeeRepo = ref.read(employeeRepositoryProvider);
    if (employeeRepo.getAllEmployees().isNotEmpty) return;

    final employees = [
      Employee.create(
        name: 'John Doe',
        role: 'Senior Developer',
        email: 'john@genxis.com',
        phone: '555-0101',
        salary: 85000,
      ),
      Employee.create(
        name: 'Jane Smith',
        role: 'UI/UX Designer',
        email: 'jane@genxis.com',
        phone: '555-0102',
        salary: 75000,
      ),
      Employee.create(
        name: 'Bob Johnson',
        role: 'Project Manager',
        email: 'bob@genxis.com',
        phone: '555-0103',
        salary: 95000,
      ),
    ];

    for (var e in employees) {
      employeeRepo.addEmployee(e);
    }
  }

  void _populateExpenses() {
    final expenseRepo = ref.read(expenseRepositoryProvider);
    if (expenseRepo.getAllExpenses().isNotEmpty) return;

    final expenses = [
      Expense(
        id: const Uuid().v4(),
        description: 'Office Rent - Jan',
        amount: 2500.0,
        date: DateTime.now().subtract(const Duration(days: 15)),
        category: ExpenseCategory.rent,
        vendor: 'Tech Park Realty',
      ),
      Expense(
        id: const Uuid().v4(),
        description: 'Software Licenses',
        amount: 350.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: ExpenseCategory.software,
        vendor: 'Adobe Creative Cloud',
      ),
      Expense(
        id: const Uuid().v4(),
        description: 'Team Lunch',
        amount: 120.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: ExpenseCategory.other,
      ),
    ];

    for (var e in expenses) {
      expenseRepo.addExpense(e);
    }
  }
}
