import 'package:dsv360/core/network/dio_client.dart'; // single import — no raw http or TokenManager needed
import 'package:flutter/foundation.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/models/issue_model.dart';

// ---------------------------------------------------------------------------
// How this repository uses ApiClient:
//   - ApiClient.instance is the shared singleton defined in api_client.dart.
//   - The base URL and Authorization header are handled inside ApiClient,
//     so this file only passes relative paths and query/body parameters.
// ---------------------------------------------------------------------------

class IssueRepository {

  // Use the centralized client — no manual http, no manual token injection.
  final _client = ApiClient.instance;

  Future<List<IssueModel>> fetchIssues() async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Check if user is Admin (only admin can CRUD issues)
    final roleName = user.role?.name ?? '';
    final isAdmin = roleName == 'Admin' ||
                    roleName == 'Admin (Default)' || 
                    roleName == 'Super Admin' || 
                    roleName == 'App Administrator';

    // Relative path — base URL and token handled by ApiClient.
    final String path;
    if (isAdmin) {
      path = 'time_entry_management_application_function/issue';
    } else {
      path = 'time_entry_management_application_function/assignissue/${user.id}';
    }

    debugPrint(
      '🩸 Fetching issues | isAdmin: $isAdmin | path: $path | Role: ${user.role?.name}',
    );

    try {
      final response = await _client.get(path);

      debugPrint('🩸 Issue Response Status: ${response.statusCode}');
      debugPrint('🩸 Issue Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;
        
        debugPrint('🩸 Parsed JSON Response: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          
          debugPrint('🩸 Total issues fetched: ${data.length}');
          
          final issues = data.map((json) => IssueModel.fromJson(json)).toList();
          
          debugPrint('🩸 Successfully parsed ${issues.length} issues');
          
          return issues;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching issues: $e');
      throw Exception('Error fetching issues: $e');
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
  }) async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Relative path — base URL and token handled by ApiClient.
    const path = 'time_entry_management_application_function/issue';
    
    final body = {
      'Issue_name': issueName,
      'Description': description,
      'Severity': severity,
      'Status': status,
      'Project_ID': projectId,
      'Assignee_ID': assigneeId,
      'Due_Date': dueDate,
      'Reporter_ID': user.id,
    };

    debugPrint('📤 POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return IssueModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create issue');
        }
      } else {
        throw Exception('Failed to create issue: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating issue: $e');
      throw Exception('Error creating issue: $e');
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
  }) async {
    // Relative path — base URL and token handled by ApiClient.
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

    debugPrint('📤 POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return IssueModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update issue');
        }
      } else {
        throw Exception('Failed to update issue: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating issue: $e');
      throw Exception('Error updating issue: $e');
    }
  }

  Future<void> deleteIssue(String issueId) async {
    // Relative path — base URL and token handled by ApiClient.
    final path = 'time_entry_management_application_function/issue/$issueId';
    
    debugPrint('🗑️ DELETE $path');

    try {
      final response = await _client.delete(path);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Issue deleted successfully');
      } else {
        throw Exception('Failed to delete issue: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting issue: $e');
      throw Exception('Error deleting issue: $e');
    }
  }
}
