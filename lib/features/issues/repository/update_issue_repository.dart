import 'package:dio/dio.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/issue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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
    required String projectName,
    required String assigneeName,
    List<XFile>? files,
  }) async {
    final path = 'time_entry_management_application_function/issue/$issueId';

    final formData = FormData.fromMap({
  'Issue_name': issueName,
  'Description': description,
  'Severity': severity,
  'Status': status,
  'Project_ID': projectId,
  'Project_Name': projectName,     // ✅ added
  'Assignee_ID': assigneeId,
  'Assignee_Name': assigneeName,   // ✅ added
  'Due_Date': dueDate,
});

    if (files != null && files.isNotEmpty) {
      final limitedFiles = files.take(3).toList(growable: false);
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < limitedFiles.length; i++) {
        final file = limitedFiles[i];
        final uniqueFileName = '${now}_${i}_${file.name}';
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromFileSync(file.path, filename: uniqueFileName),
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
        throw Exception(jsonResponse['message'] ?? 'Failed to update issue');
      }

      throw Exception('Failed to update issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating issue: $e');
      throw Exception('Error updating issue: $e');
    }
  }
}
