import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/features/task/repositories/task_repository.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/cache/user_cache_provider.dart';

// Provider to get the current user's ID — prefers live AuthManager, falls back to cache.
final currentUserIdProvider = Provider<String>((ref) {
  final live = AuthManager.instance.currentUser?.id ?? '';
  if (live.isNotEmpty) return live;
  final cached = ref.read(globalUserProvider)?.id ?? '';
  debugPrint('👤 Getting userId from cache: $cached');
  return cached;
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

