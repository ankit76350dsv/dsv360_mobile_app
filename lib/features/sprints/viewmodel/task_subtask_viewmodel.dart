import 'package:dsv360/features/sprints/repositories/task_subtask_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskSubtaskRepositoryProvider = Provider<TaskSubtaskRepository>((ref) {
  return TaskSubtaskRepository();
});

// Legacy provider aliases.
final createTaskRepositoryProvider = Provider<TaskSubtaskRepository>((ref) => ref.read(taskSubtaskRepositoryProvider));
final addSubTaskRepositoryProvider = Provider<TaskSubtaskRepository>((ref) => ref.read(taskSubtaskRepositoryProvider));
final sprintTaskStatusRepositoryProvider = Provider<TaskSubtaskRepository>((ref) => ref.read(taskSubtaskRepositoryProvider));
