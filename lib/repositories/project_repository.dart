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
        'tasks_count': 12,
        'start_date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'p2',
        'name': 'Payroll Integration',
        'status': 'Working',
        'tasks_count': 8,
        'start_date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': 'p3',
        'name': 'Mobile App',
        'status': 'Closed',
        'tasks_count': 21,
        'start_date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      },
    ];
    return mock.map((e) => Project.fromJson(e)).toList();
  }

  /// Fetch projects for a specific user
  Future<List<Project>> fetchUserProjects(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    // Mocked data - in production call api.get('/users/$userId/projects')
    final mock = [
      {
        'id': 'p1',
        'name': 'Employee Management',
        'status': 'Open',
        'tasks_count': 12,
        'start_date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'p2',
        'name': 'Payroll Integration',
        'status': 'Working',
        'tasks_count': 8,
        'start_date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
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
