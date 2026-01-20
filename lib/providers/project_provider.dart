import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/project_model.dart';
import 'package:dsv360/repositories/project_repository.dart';

// Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

// Project List Provider
final projectListProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProjects();
});
