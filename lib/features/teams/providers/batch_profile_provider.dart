import 'package:dsv360/features/teams/model/batch_profile_model.dart';
import 'package:dsv360/features/teams/repositories/batch_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final batchProfileRepositoryProvider =
    Provider<BatchProfileRepository>((ref) {
  return BatchProfileRepository();
});

final batchProfilesProvider =
    FutureProvider.autoDispose<List<BatchProfile>>((ref) async {
  final repository = ref.watch(batchProfileRepositoryProvider);

  return repository.fetchBatchProfiles();
});