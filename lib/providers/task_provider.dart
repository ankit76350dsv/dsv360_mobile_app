import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/repositories/task_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';

// Provider to get the current user's ID from the active user state
final currentUserIdProvider = Provider<String>((ref) {
  final activeUser = ref.watch(activeUserRepositoryProvider);
  return activeUser?.userId ?? '';
});

// Re-export the auto-generated task list repository provider
// This allows using: ref.watch(tasksListRepositoryProvider(userId))
// Generated from @riverpod class TasksListRepository

// Tasks Search Query Provider
final tasksSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Tasks Provider - watches the repository provider directly
final filteredTasksProvider =
    Provider.autoDispose<AsyncValue<List<Task>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(tasksListRepositoryProvider(userId));
});

