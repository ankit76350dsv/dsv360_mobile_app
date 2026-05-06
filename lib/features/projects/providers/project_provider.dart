import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/features/projects/repositories/project_repository.dart';
import 'package:dsv360/features/task/repositories/fetch_all_tasks_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final projectListProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final projects = await repository.fetchProjects();

  try {
    final user = AuthManager.instance.currentUser;
    if (user != null) {
      final tasks = await FetchAllTasksRepository().fetchAllTasks();

      final taskCounts = <String, int>{};
      for (var task in tasks) {
        taskCounts[task.projectId] = (taskCounts[task.projectId] ?? 0) + 1;
      }

      return projects.map((project) {
        final count = taskCounts[project.id] ?? 0;
        return project.copyWith(tasksCount: count);
      }).toList();
    }
  } catch (e) {
    print('⚠️ Failed to fetch task counts: $e');
  }

  return projects;
});
