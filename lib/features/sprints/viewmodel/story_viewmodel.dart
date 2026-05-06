import 'package:dsv360/features/sprints/repositories/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository();
});

// Legacy provider aliases.
final createStoryRepositoryProvider = Provider<StoryRepository>((ref) => ref.read(storyRepositoryProvider));
final editStoryRepositoryProvider = Provider<StoryRepository>((ref) => ref.read(storyRepositoryProvider));
final updateStoryStatusRepositoryProvider = Provider<StoryRepository>((ref) => ref.read(storyRepositoryProvider));
final deployToCycleRepositoryProvider = Provider<StoryRepository>((ref) => ref.read(storyRepositoryProvider));
