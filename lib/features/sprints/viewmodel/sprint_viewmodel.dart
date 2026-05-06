import 'package:dsv360/features/sprints/repositories/sprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sprintRepositoryProvider = Provider<SprintRepository>((ref) {
  return SprintRepository();
});

// Legacy provider aliases.
final createSprintRepositoryProvider = Provider<SprintRepository>((ref) => ref.read(sprintRepositoryProvider));
final getSprintsRepositoryProvider = Provider<SprintRepository>((ref) => ref.read(sprintRepositoryProvider));
final completeSprintRepositoryProvider = Provider<SprintRepository>((ref) => ref.read(sprintRepositoryProvider));
