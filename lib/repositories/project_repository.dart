import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';

class ProjectsRepository extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    return fetchProjects();
  }

  Future<List<Project>> fetchProjects() async {
    // TODO: replace with Dio call
    await Future.delayed(const Duration(seconds: 2));

    return [
      Project(
        id: "1",
        name: "Employee Management",
        status: "active",
        tasksCount: 12,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}

// final projectsRepositoryProvider =
//     AsyncNotifierProvider<ProjectsRepository, List<Project>>(
//   ProjectsRepository.new,
// );




/// Temporary Projects Repository (Mock)
/// Replace with AsyncNotifier when API is ready
final projectsRepositoryProvider =
    FutureProvider<List<Project>>((ref) async {
  // ⏳ Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  // ❌ Uncomment to test error state
  // throw Exception("Failed to load projects");

  return <Project>[
    Project(
      id: "1",
      name: "Employee Management",
      status: "active",
      tasksCount: 12,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Project(
      id: "2",
      name: "Payroll Integration",
      status: "active",
      tasksCount: 7,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Project(
      id: "3",
      name: "Mobile App Development",
      status: "on_hold",
      tasksCount: 20,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Project(
      id: "4",
      name: "Analytics Dashboard",
      status: "completed",
      tasksCount: 25,
      startDate: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];
});
