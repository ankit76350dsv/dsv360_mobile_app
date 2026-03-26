import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/employee.dart';
import 'package:dsv360/providers/employee_provider.dart';

/// Provider that returns a list of reporting managers
/// Filters employees to only include those with role:
/// - "Manager/Team Lead"
/// - "Admin"
final reportingManagersProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final allEmployees = await ref.watch(employeeListProvider.future);
  
  // Filter employees by role
  final reportingManagers = allEmployees.where((employee) {
    final role = employee.roleName.toLowerCase();
    return role == 'manager/team lead' || role == 'admin';
  }).toList();
  
  return reportingManagers;
});
