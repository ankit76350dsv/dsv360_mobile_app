import 'package:dio/dio.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class CreateUserRepository {
  final _client = ApiClient.instance;

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String emailId,
    required String roleId,
  }) async {
    const path = 'time_entry_management_application_function/AddEmployees';

    final formData = FormData.fromMap({
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email_id': emailId.trim(),
      'role_id': roleId.trim(),
    });

    debugPrint('POST $path with body fields: ${formData.fields}');

    try {
      final response = await _client.post(path, data: formData);

      debugPrint('Create user response status: ${response.statusCode}');
      debugPrint('Create user response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to create user');
        }
        return;
      }

      throw Exception('Failed to create user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Error creating user: $e');
    }
  }
}