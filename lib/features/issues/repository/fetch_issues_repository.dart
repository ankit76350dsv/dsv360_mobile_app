import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/issues/model/issue_model.dart';
import 'package:flutter/foundation.dart';

class FetchIssuesRepository {
  final _client = ApiClient.instance;

  Future<List<IssueModel>> fetchIssues() async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final roleName = user.role?.name ?? '';
    final isAdmin =
        roleName == 'Admin' ||
        roleName == 'Admin (Default)' ||
        roleName == 'Super Admin' ||
        roleName == 'App Administrator';

    final String path;
    if (isAdmin) {
      path = 'time_entry_management_application_function/issue';
    } else {
      path =
          'time_entry_management_application_function/assignissue/${user.id}';
    }

    debugPrint(
      'Fetching issues | isAdmin: $isAdmin | path: $path | Role: ${user.role?.name}',
    );

    try {
      final response = await _client.get(path);

      debugPrint('Issue response status: ${response.statusCode}');
      debugPrint('Issue response data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          final issues = data.map((json) => IssueModel.fromJson(json)).toList();
          return issues;
        }
        throw Exception('API returned success: false');
      }

      throw Exception('Failed to load issues: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      throw Exception('Error fetching issues: $e');
    }
  }
}
