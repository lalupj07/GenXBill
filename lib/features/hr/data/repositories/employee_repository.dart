import 'package:hive_flutter/hive_flutter.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  static const String _boxName = 'hr_employees';

  Box<HREmployee> get box => Hive.box<HREmployee>(_boxName);

  // Create
  Future<void> addEmployee(HREmployee employee) async {
    await box.put(employee.id, employee);
  }

  // Read
  HREmployee? getEmployee(String id) {
    return box.get(id);
  }

  List<HREmployee> getAllEmployees() {
    return box.values.toList();
  }

  List<HREmployee> getActiveEmployees() {
    return box.values
        .where((emp) => emp.status == EmployeeStatus.active)
        .toList();
  }

  List<HREmployee> getEmployeesByDepartment(String department) {
    return box.values.where((emp) => emp.department == department).toList();
  }

  HREmployee? getEmployeeByCode(String employeeCode) {
    return box.values.firstWhere(
      (emp) => emp.employeeCode == employeeCode,
      orElse: () => throw Exception('Employee not found'),
    );
  }

  // Update
  Future<void> updateEmployee(HREmployee employee) async {
    await box.put(employee.id, employee);
  }

  Future<void> updateLeaveBalance(
    String employeeId,
    String leaveType,
    double balance,
  ) async {
    final employee = getEmployee(employeeId);
    if (employee != null) {
      final updated = employee.updateLeaveBalance(leaveType, balance);
      await updateEmployee(updated);
    }
  }

  Future<void> deactivateEmployee(String employeeId) async {
    final employee = getEmployee(employeeId);
    if (employee != null) {
      final updated = employee.copyWith(status: EmployeeStatus.inactive);
      await updateEmployee(updated);
    }
  }

  // Delete
  Future<void> deleteEmployee(String id) async {
    await box.delete(id);
  }

  // Statistics
  int getTotalEmployees() => box.length;

  int getActiveEmployeesCount() {
    return box.values
        .where((emp) => emp.status == EmployeeStatus.active)
        .length;
  }

  List<String> getAllDepartments() {
    return box.values.map((emp) => emp.department).toSet().toList();
  }

  double getTotalSalaryExpense() {
    return box.values
        .where((emp) => emp.status == EmployeeStatus.active)
        .fold(0.0, (sum, emp) => sum + emp.salary);
  }

  // Search
  List<HREmployee> searchEmployees(String query) {
    final lowerQuery = query.toLowerCase();
    return box.values.where((emp) {
      return emp.name.toLowerCase().contains(lowerQuery) ||
          emp.employeeCode.toLowerCase().contains(lowerQuery) ||
          emp.email.toLowerCase().contains(lowerQuery) ||
          emp.department.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear all data (for testing)
  Future<void> clearAll() async {
    await box.clear();
  }
}
