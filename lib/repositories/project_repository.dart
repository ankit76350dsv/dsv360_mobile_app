import 'dart:async';
import '../models/project.dart';
import '../services/api_client.dart';

class ProjectRepository {
  // Replace with ApiClient() calls for real API
  final ApiClient api;

  ProjectRepository({ApiClient? apiClient}) : api = apiClient ?? ApiClient();

  /// Mocked fetch - in production call api.get('/projects') and map results
  Future<List<Project>> fetchProjects() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    // Mocked data
    final mock = [
      {
        'id': 'p1',
        'name': 'Employee Management',
        'status': 'Open',
        'tasks_count': 12
      },
      {'id': 'p2', 'name': 'Payroll Integration', 'status': 'Working', 'tasks_count': 8},
      {'id': 'p3', 'name': 'Mobile App', 'status': 'Closed', 'tasks_count': 21},
    ];
    return mock.map((e) => Project.fromJson(e)).toList();
  }

  // Example real call (commented)
  // Future<List<Project>> fetchProjects() async {
  //   final res = await api.get('/projects');
  //   final list = (res.data as List).map((e) => Project.fromJson(e)).toList();
  //   return list;
  // }
}
