import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

class ProjectRepository {
  Future<List<ProjectModel>> fetchProjects() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/projects',
    );

    final data = response.data;

    List<dynamic> rawList = [];

    if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else if (data is List) {
      rawList = data;
    }

    return rawList
        .whereType<Map>()
        .map((e) => ProjectModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }
}