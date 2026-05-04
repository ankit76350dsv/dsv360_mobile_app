import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/teams/model/employee_model.dart';
import 'package:dsv360/features/teams/repositories/employee_repository.dart';

// Repository Provider
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

// All Employees Provider
final employeeListProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.fetchAllEmployees();
});

// Batch Profile Provider (includes team assignments)
final batchProfileProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.fetchBatchProfiles();
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
