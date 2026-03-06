import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/time_entry_repository.dart';
import '../models/time_entry_model.dart';
import '../core/constants/auth_manager.dart';

final timeEntryRepositoryProvider = Provider((ref) {
  return TimeEntryRepository();
});

/// Get time entries by task
final timeEntriesByTaskProvider = FutureProvider.family<List<TimeEntry>, String>((ref, taskId) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByTask(taskId);
});

/// Get time entries by task with date filter
final timeEntriesByTaskWithDateFilterProvider = FutureProvider.family<List<TimeEntry>, ({String taskId, String? userId, DateTime? startDate, DateTime? endDate})>((ref, params) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByTaskWithDateFilter(
    taskId: params.taskId,
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Get time entries by project
final timeEntriesByProjectProvider = FutureProvider.family<List<TimeEntry>, String>((ref, projectId) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByProject(projectId);
});

/// Get time entries by project with date filter
final timeEntriesByProjectWithDateFilterProvider = FutureProvider.family<List<TimeEntry>, ({String projectId, DateTime? startDate, DateTime? endDate})>((ref, params) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  return repository.getTimeEntriesByProjectWithDateFilter(
    projectId: params.projectId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Get user time entries (current user)
final userTimeEntriesProvider = FutureProvider.family<List<TimeEntry>, (DateTime, DateTime)>((ref, dates) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = AuthManager.instance.currentUser?.id ?? '';
  
  if (userId.isEmpty) {
    throw Exception('User ID not found');
  }
  
  return repository.getTimeEntriesByUser(
    userId: userId,
    startDate: dates.$1,
    endDate: dates.$2,
  );
});

/// Check timer status
final timerStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = AuthManager.instance.currentUser?.id ?? '';
  
  if (userId.isEmpty) {
    throw Exception('User ID not found');
  }
  
  return repository.checkTimerStatus(userId);
});

/// Get user approvals
final userApprovalsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final userId = AuthManager.instance.currentUser?.id ?? '';
  
  if (userId.isEmpty) {
    throw Exception('User ID not found');
  }
  
  return repository.getUserApprovals(userId);
});

/// Get team approvals (for managers)
final teamApprovalsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(timeEntryRepositoryProvider);
  final managerId = AuthManager.instance.currentUser?.id ?? '';
  
  if (managerId.isEmpty) {
    throw Exception('Manager ID not found');
  }
  
  return repository.getTeamApprovals(managerId);
});
