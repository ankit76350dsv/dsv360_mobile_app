import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/issue_model.dart';
import 'package:flutter/foundation.dart';

class UpdateIssueRepository {
  final _client = ApiClient.instance;

  Future<IssueModel> updateIssue({
    required String issueId,
    required String issueName,
    required String description,
    required String severity,
    required String status,
    required String projectId,
    required String assigneeId,
    required String dueDate,
  }) async {
    final path = 'time_entry_management_application_function/issue/$issueId';

    final body = {
      'Issue_name': issueName,
      'Description': description,
      'Severity': severity,
      'Status': status,
      'Project_ID': projectId,
      'Assignee_ID': assigneeId,
      'Due_Date': dueDate,
    };

    debugPrint('POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return IssueModel.fromJson(jsonResponse['data']);
        }
        throw Exception(jsonResponse['message'] ?? 'Failed to update issue');
      }

      throw Exception('Failed to update issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating issue: $e');
      throw Exception('Error updating issue: $e');
    }
  }
}
