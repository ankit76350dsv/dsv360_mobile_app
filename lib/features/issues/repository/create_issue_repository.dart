import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/issue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreateIssueRepository {
  final _client = ApiClient.instance;

  Future<IssueModel> createIssue({
    required String issueName,
    required String description,
    required String severity,
    required String status,
    required String projectId,
    required String assigneeId,
    required String dueDate,
    String? projectName,
    String? assigneeName,
    List<XFile>? files,
  }) async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    const path = 'time_entry_management_application_function/issue';

    final formData = FormData.fromMap({
      'Issue_name': issueName,
      'Description': description,
      'Severity': severity,
      'Status': status,
      'Project_ID': projectId,
      'Assignee_ID': assigneeId,
      'Due_Date': dueDate,
      'Reporter_ID': user.id,
      'Reporter_Name': '${user.firstName} ${user.lastName}'.trim(),
      if (projectName != null && projectName.isNotEmpty)
        'Project_Name': projectName,
      if (assigneeName != null && assigneeName.isNotEmpty)
        'Assignee_Name': assigneeName,
    });

    if (files != null && files.isNotEmpty) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }

    debugPrint('POST $path with body fields: ${formData.fields}');
    debugPrint('POST $path with files count: ${formData.files.length}');

    try {
      final response = await _client.post(path, data: formData);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return IssueModel.fromJson(jsonResponse['data']);
        }
        throw Exception(jsonResponse['message'] ?? 'Failed to create issue');
      }

      throw Exception('Failed to create issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error creating issue: $e');
      throw Exception('Error creating issue: $e');
    }
  }
}
