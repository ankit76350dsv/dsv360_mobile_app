import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:flutter/foundation.dart';

class FetchProjectsRepository {
  final _client = ApiClient.instance;

  Future<List<ProjectModel>> fetchProjects() async {
    const path = 'time_entry_management_application_function/projects';

    debugPrint('Fetching projects | path: $path');

    try {
      final response = await _client.get(path);

      debugPrint('Project response status: ${response.statusCode}');
      debugPrint('Project response data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data
              .map(
                (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
        throw Exception('API returned success: false');
      }

      throw Exception('Failed to load projects: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      throw Exception('Error fetching projects: $e');
    }
  }
}
