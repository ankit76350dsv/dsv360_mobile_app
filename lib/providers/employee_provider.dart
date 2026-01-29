import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/employee.dart';
import 'package:dsv360/repositories/employee_repository.dart';

// Repository Provider
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

// All Employees Provider
final employeeListProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.fetchAllEmployees();
});

// Unassigned Employees Provider
final unassignedEmployeeListProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.fetchUnassignedEmployees();
});

// Single Employee Provider
final employeeByIdProvider = FutureProvider.autoDispose.family<Employee?, String>((ref, userId) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.fetchEmployeeById(userId);
});
