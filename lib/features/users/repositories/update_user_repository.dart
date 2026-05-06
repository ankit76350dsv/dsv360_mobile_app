import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class UpdateUserRepository {
  final _client = ApiClient.instance;

  Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String emailId,
    required String roleId,
  }) async {
    final path =
        'time_entry_management_application_function/UpdateEmployee/$userId';

    final body = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email_id': emailId.trim(),
      'role_id': roleId.trim(),
    };

    debugPrint('POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('Update user response status: ${response.statusCode}');
      debugPrint('Update user response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to update user');
        }
        return;
      }

      throw Exception('Failed to update user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Error updating user: $e');
    }
  }
}