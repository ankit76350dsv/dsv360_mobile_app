import 'package:dsv360/features/sprints/repositories/epic_release_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final epicReleaseRepositoryProvider = Provider<EpicReleaseRepository>((ref) {
  return EpicReleaseRepository();
});

// Legacy provider aliases.
final createEpicRepositoryProvider = Provider<EpicReleaseRepository>((ref) => ref.read(epicReleaseRepositoryProvider));
final createReleaseRepositoryProvider = Provider<EpicReleaseRepository>((ref) => ref.read(epicReleaseRepositoryProvider));
