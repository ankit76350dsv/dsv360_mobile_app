import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/time_entry_repository.dart';
import '../model/time_entry_model.dart';
import '../../../core/cache/user_cache_provider.dart';
import '../../../core/constants/auth_manager.dart';

final timeEntryRepositoryProvider = Provider((ref) {
  return TimeEntryRepository();
});

String _resolveUserId(Ref ref) {
  final live = AuthManager.instance.currentUser?.id;
  if (live != null && live.isNotEmpty) return live;
  return ref.read(globalUserProvider)?.id ?? '';
}

/// Get time entries by task
final timeEntriesByTaskProvider = FutureProvider.family<List<TimeEntry>, String>((ref, taskId) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByTask(taskId);
});

/// Get time entries by project
final timeEntriesByProjectProvider = FutureProvider.family<List<TimeEntry>, String>((ref, projectId) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByProject(projectId);
});

/// Get user time entries (current user)
final userTimeEntriesProvider = FutureProvider.family<List<TimeEntry>, (DateTime, DateTime)>((ref, dates) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = _resolveUserId(ref);
  if (userId.isEmpty) throw Exception('User ID not found');
  return repository.getTimeEntriesByUser(userId: userId, startDate: dates.$1, endDate: dates.$2);
});

/// Check timer status
final timerStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = _resolveUserId(ref);
  if (userId.isEmpty) throw Exception('User ID not found');
  return repository.checkTimerStatus(userId);
});

/// Get user approvals
final userApprovalsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = _resolveUserId(ref);
  if (userId.isEmpty) throw Exception('User ID not found');
  return repository.getUserApprovals(userId);
});

/// Get team approvals (for managers)
final teamApprovalsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final managerId = _resolveUserId(ref);
  if (managerId.isEmpty) throw Exception('Manager ID not found');
  return repository.getTeamApprovals(managerId);
});
