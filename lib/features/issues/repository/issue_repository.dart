import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/issues/model/issue_model.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class IssueRepository {
  final _client = ApiClient.instance;

  Future<List<IssueModel>> fetchIssues() async {
    final user = AuthManager.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final roleName = user.role?.name ?? '';
    final isAdmin =
        roleName == 'Admin' ||
        roleName == 'Admin (Default)' ||
        roleName == 'Super Admin' ||
        roleName == 'App Administrator';

    final String path = isAdmin
        ? 'time_entry_management_application_function/issue'
        : 'time_entry_management_application_function/assignissue/${user.id}';

    debugPrint('Fetching issues | isAdmin: $isAdmin | path: $path | Role: ${user.role?.name}');

    try {
      final response = await _client.get(path);

      debugPrint('Issue response status: ${response.statusCode}');
      debugPrint('Issue response data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => IssueModel.fromJson(json)).toList();
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load issues: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<List<ProjectModel>> fetchProjects() async {
    const path = 'time_entry_management_application_function/projects';
    debugPrint('Fetching projects | path: $path');

    try {
      final response = await _client.get(path);

      debugPrint('Project response status: ${response.statusCode}');
      debugPrint('Project response data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data
              .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('API returned success: false');
      }
      throw Exception('Failed to load projects: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

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
    if (user == null) throw Exception('User not logged in');

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
      if (projectName != null && projectName.isNotEmpty) 'Project_Name': projectName,
      if (assigneeName != null && assigneeName.isNotEmpty) 'Assignee_Name': assigneeName,
    });

    if (files != null && files.isNotEmpty) {
      final limitedFiles = files.take(3).toList(growable: false);
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < limitedFiles.length; i++) {
        final file = limitedFiles[i];
        final uniqueFileName = '${now}_${i}_${file.name}';
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromFileSync(file.path, filename: uniqueFileName),
        ));
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
        if (jsonResponse['success'] == true) return IssueModel.fromJson(jsonResponse['data']);
        throw Exception(jsonResponse['message'] ?? 'Failed to create issue');
      }
      throw Exception('Failed to create issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error creating issue: $e');
      throw Exception('Error creating issue. Please try again.');
    }
  }

  Future<void> updateIssueStatus({
    required String issueId,
    required String status,
  }) async {
    final path = 'time_entry_management_application_function/issue/$issueId';
    final formData = FormData.fromMap({'Status': status});

    debugPrint('POST $path with status-only update: $status');

    try {
      final response = await _client.post(path, data: formData);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'Failed to update status');
        }
        return;
      }
      throw Exception('Failed to update status: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating issue status: $e');
      throw Exception('Error updating issue status. Try again later');
    }
  }

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
      'Project_Name': projectName,
      'Assignee_ID': assigneeId,
      'Assignee_Name': assigneeName,
      'Due_Date': dueDate,
    });

    if (files != null && files.isNotEmpty) {
      final limitedFiles = files.take(3).toList(growable: false);
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < limitedFiles.length; i++) {
        final file = limitedFiles[i];
        final uniqueFileName = '${now}_${i}_${file.name}';
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromFileSync(file.path, filename: uniqueFileName),
        ));
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
        if (jsonResponse['success'] == true) return IssueModel.fromJson(jsonResponse['data']);
        throw Exception(jsonResponse['message'] ?? 'Failed to update issue');
      }
      throw Exception('Failed to update issue: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error updating issue: $e');
      throw Exception('Error updating issue. Try again later.');
    }
  }

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
