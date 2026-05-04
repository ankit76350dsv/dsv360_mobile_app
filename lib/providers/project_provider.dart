import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/features/projects/repositories/project_repository.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

// Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

// Project List Provider with Task Counts
final projectListProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  final projects = await repository.fetchProjects();
  
  // Try to fetch tasks and calculate counts
  try {
    final user = AuthManager.instance.currentUser;
    if (user != null) {
      final taskRepository = TasksListRepository();
      final tasks = await taskRepository.fetchTasks(user.id);
      
      // Count tasks per project
      final taskCounts = <String, int>{};
      for (var task in tasks) {
        taskCounts[task.projectId] = (taskCounts[task.projectId] ?? 0) + 1;
      }
      
      // Update projects with task counts
      return projects.map((project) {
        final count = taskCounts[project.id] ?? 0;
        return project.copyWith(tasksCount: count);
      }).toList();
    }
  } catch (e) {
    // If task fetching fails, just return projects without counts
    print('⚠️ Failed to fetch task counts: $e');
  }
  
  return projects;
});
