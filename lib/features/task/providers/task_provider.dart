import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/features/task/repositories/fetch_tasks_repository.dart';
import 'package:dsv360/features/task/repositories/fetch_tasks_by_project_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

// Provider to get the current user's ID from AuthManager (more reliable)
final currentUserIdProvider = Provider<String>((ref) {
  final user = AuthManager.instance.currentUser;
  final userId = user?.id ?? '';
  debugPrint('👤 Getting userId from AuthManager: $userId (ID: ${user?.id})');
  return userId;
});

// Tasks Search Query Provider
final tasksSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// Filtered Tasks Provider - watches the repository provider directly
final filteredTasksProvider =
    Provider.autoDispose<AsyncValue<List<Task>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  debugPrint('🎯 Filtered Tasks Provider - userId: $userId');
  return ref.watch(tasksListRepositoryProvider(userId));
});

// Tasks by Project Provider - fetches tasks for a specific project
final tasksByProjectProvider = FutureProvider.family.autoDispose<List<Task>, String>((ref, projectId) async {
  final repository = FetchTasksByProjectRepository();
  debugPrint('📋 Fetching tasks for project: $projectId');
  return await repository.fetchTasksByProject(projectId);
});

