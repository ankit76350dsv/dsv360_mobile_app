import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/features/task/repositories/task_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';

// Provider to get the current user's ID from AuthManager (more reliable)
final currentUserIdProvider = Provider<String>((ref) {
  final user = AuthManager.instance.currentUser;
  final userId = user?.id ?? '';
  debugPrint('👤 Getting userId from AuthManager: $userId (ID: ${user?.id})');
  return userId;
});

// Re-export the auto-generated task list repository provider
// This allows using: ref.watch(tasksListRepositoryProvider(userId))
// Generated from @riverpod class TasksListRepository

// Tasks Search Query Provider
final tasksSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// Filtered Tasks Provider - watches the repository provider directly
final filteredTasksProvider =
    Provider.autoDispose<AsyncValue<List<Task>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  debugPrint('🎯 Filtered Tasks Provider - userId: $userId');
  return ref.watch(tasksListRepositoryProvider(userId));
});

