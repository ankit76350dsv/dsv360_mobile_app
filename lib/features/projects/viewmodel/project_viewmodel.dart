import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/features/projects/repositories/project_repository.dart';
import 'package:dsv360/core/cache/user_cache_provider.dart';
import 'package:dsv360/features/task/repositories/task_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final projectListProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final projects = await repository.fetchProjects();

  // Use cached user — works online and offline.
  final cachedUser = ref.read(globalUserProvider);
  if (cachedUser != null && cachedUser.id.isNotEmpty) {
    try {
      final tasks = await FetchAllTasksRepository().fetchAllTasks();
      final taskCounts = <String, int>{};
      for (var task in tasks) {
        taskCounts[task.projectId] = (taskCounts[task.projectId] ?? 0) + 1;
      }
      return projects.map((project) {
        return project.copyWith(tasksCount: taskCounts[project.id] ?? 0);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to fetch task counts: $e');
    }
  }

  return projects;
});
