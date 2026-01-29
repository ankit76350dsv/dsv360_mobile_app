import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/models/issue_model.dart';

class IssueRepository {
  Future<List<IssueModel>> fetchIssues() async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Check if user is Admin
    final isAdmin = user.role?.name == 'Admin';

    String url;
    if (isAdmin) {
      // Admin URL - fetch all issues
      url = '${ServerConstant.serverURL}time_entry_management_application_function/issue';
    } else {
      // AppUser URL - fetch issues assigned to user
      url = '${ServerConstant.serverURL}time_entry_management_application_function/assignissue/${user.id}';
    }

    debugPrint(
      '🩸 Fetching issues | isAdmin: $isAdmin | URL: $url | Role: ${user.role?.name}',
    );

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('🩸 Issue Response Status: ${response.statusCode}');
      debugPrint('🩸 Issue Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        debugPrint('🩸 Parsed JSON Response: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          
          debugPrint('🩸 Total issues fetched: ${data.length}');
          
          // Parse issues from response
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

    final url = '${ServerConstant.serverURL}time_entry_management_application_function/issue';
    
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

    debugPrint('📤 POST $url with body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
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
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/issue/$issueId';
    
    final body = {
      'Issue_name': issueName,
      'Description': description,
      'Severity': severity,
      'Status': status,
      'Project_ID': projectId,
      'Assignee_ID': assigneeId,
      'Due_Date': dueDate,
    };

    debugPrint('📤 POST $url with body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
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
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/issue/$issueId';
    
    debugPrint('🗑️ DELETE $url');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

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
