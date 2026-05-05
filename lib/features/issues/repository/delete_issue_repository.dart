import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';

class DeleteIssueRepository {
  final _client = ApiClient.instance;

  Future<void> deleteIssue(String issueId) async {
    final path = 'time_entry_management_application_function/issue/$issueId';

    debugPrint('DELETE $path');

    try {
      final response = await _client.delete(path);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Issue deleted successfully');
        return;
      }

      throw Exception('Failed to delete issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error deleting issue: $e');
      throw Exception('Error deleting issue. Try again later.');
    }
  }
}
