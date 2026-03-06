import 'dart:developer' as developer;
import 'package:dsv360/core/constants/init_zcatalyst_app.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/core/constants/token_manager.dart';
import 'package:dsv360/models/employee.dart';

class EmployeeRepository {
  /// Get all employees
  Future<List<Employee>> fetchAllEmployees() async {
    try {
      debugPrint('👥 Fetching all employees');

      final app = AppInitManager.instance.catalystApp;
      final token = await app.getAccessToken();

      debugPrint('🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑 Access Token: $token');
   

      final url =
          '${ServerConstant.serverURL}time_entry_management_application_function/employee';
      debugPrint('🌐 URL: $url');

      //this is the first method how i am calling the api but it is not working
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        },
      );


      // this is the second method how i am calling the api and it is also not woking working fine
      // Step 2: Make API request
      // final response = await http.get(
      //   Uri.parse(url),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Zoho-oauthtoken $token',
      //   },
      // );
      debugPrint('📊 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = convert.json.decode(
          response.body,
        );

        // API returns "users" array, not "success" and "data"
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

      // Get access token
      final accessToken = await TokenManager.instance.getToken();
      if (accessToken == null) {
        debugPrint('❌ No access token available');
        return null;
      }

      final url = '${ServerConstant.serverURL}emp/$userId';
      debugPrint('🌐 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = convert.json.decode(
          response.body,
        );

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

      final url = '${ServerConstant.serverURL}unassignedEmployees';
      debugPrint('🌐 URL: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = convert.json.decode(
          response.body,
        );

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
