import 'dart:developer' as developer;
import 'package:dsv360/core/network/dio_client.dart';// single import — no raw http, TokenManager, or AppInitManager needed
import 'package:flutter/material.dart';
import 'package:dsv360/models/employee.dart';

// ---------------------------------------------------------------------------
// How this repository uses ApiClient:
//   - ApiClient.instance is the shared singleton defined in api_client.dart.
//   - The base URL and Authorization header are handled inside ApiClient,
//     so this file only passes relative paths and query parameters.
// ---------------------------------------------------------------------------

class EmployeeRepository {

  // Use the centralized client — no manual http, no manual token injection.
  final _client = ApiClient.instance;

  /// Get all employees
  Future<List<Employee>> fetchAllEmployees() async {
    try {
      debugPrint('👥 Fetching all employees');

      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/employee';
      debugPrint('🌐 path: $path');

      final response = await _client.get(path);

      debugPrint('📊 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;

        // API returns "users" array
        if (jsonResponse.containsKey('users')) {
          final List<dynamic> employeeList = jsonResponse['users'] ?? [];
          debugPrint('✅ Employees fetched: ${employeeList.length}');

          return employeeList
              .map((e) => Employee.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint('❌ No users field in response');
          return [];
        }
      } else {
        debugPrint('❌ HTTP Error ${response.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ Error fetching employees: $e');
      debugPrint('📍 Stack: $st');
      developer.log('Error fetching employees: $e', name: 'EmployeeRepository');
      return [];
    }
  }

  /// Get employee by user ID
  Future<Employee?> fetchEmployeeById(String userId) async {
    try {
      debugPrint('👤 Fetching employee by ID: $userId');

      // Relative path — base URL and token handled by ApiClient.
      final path = 'emp/$userId';
      debugPrint('🌐 path: $path');

      final response = await _client.get(path);
      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          final employeeData = jsonResponse['data'] as Map<String, dynamic>;
          debugPrint('✅ Employee fetched: ${employeeData['first_name']}');
          return Employee.fromJson(employeeData);
        } else {
          debugPrint('❌ API returned success: false');
          return null;
        }
      } else {
        debugPrint('❌ HTTP Error ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching employee: $e');
      developer.log('Error fetching employee: $e', name: 'EmployeeRepository');
      return null;
    }
  }

  /// Get unassigned employees
  Future<List<Employee>> fetchUnassignedEmployees() async {
    try {
      debugPrint('👥 Fetching unassigned employees');

      // Relative path — base URL and token handled by ApiClient.
      const path = 'unassignedEmployees';
      debugPrint('🌐 path: $path');

      final response = await _client.get(path);
      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          final List<dynamic> employeeList = jsonResponse['data'] ?? [];
          debugPrint('✅ Unassigned employees fetched: ${employeeList.length}');

          return employeeList
              .map((e) => Employee.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint('❌ API returned success: false');
          return [];
        }
      } else {
        debugPrint('❌ HTTP Error ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching unassigned employees: $e');
      developer.log(
        'Error fetching unassigned employees: $e',
        name: 'EmployeeRepository',
      );
      return [];
    }
  }
}
