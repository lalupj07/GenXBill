import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:genx_bill/features/employees/data/models/employee_model.dart';

final employeeBoxProvider = Provider<Box<Employee>>((ref) {
  return Hive.box<Employee>('employees');
});

class EmployeeRepository {
  final Box<Employee> _box;

  EmployeeRepository(this._box);

  Future<void> addEmployee(Employee employee) async {
    await _box.put(employee.id, employee);
  }

  Future<void> updateEmployee(Employee employee) async {
    await _box.put(employee.id, employee);
  }

  Future<void> deleteEmployee(String id) async {
    await _box.delete(id);
  }

  List<Employee> getAllEmployees() {
    return _box.values.toList();
  }

  List<Employee> getActiveEmployees() {
    return _box.values.where((e) => e.isActive).toList();
  }
}

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final box = ref.watch(employeeBoxProvider);
  return EmployeeRepository(box);
});
