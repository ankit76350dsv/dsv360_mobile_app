import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class DeleteUserRepository {
  final _client = ApiClient.instance;

  Future<void> deleteUser({
    required String userId,
    List<Map<String, dynamic>> reassignmentPayload = const [],
  }) async {
    final path = 'time_entry_management_application_function/employee/$userId';

    debugPrint('POST $path with reassignment payload: $reassignmentPayload');

    try {
      final response = await _client.post(path, data: reassignmentPayload);

      debugPrint('Delete user response status: ${response.statusCode}');
      debugPrint('Delete user response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('success') &&
            data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete user');
        }
        return;
      }

      throw Exception('Failed to delete user: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Error deleting user: $e');
    }
  }
}