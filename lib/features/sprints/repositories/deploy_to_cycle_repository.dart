import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deployToCycleRepositoryProvider =
    Provider<DeployToCycleRepository>((ref) {
  return DeployToCycleRepository();
});

class DeployToCycleRepository {
  Future<void> deployToSprint({
    required String storyId,
    required String sprintId,
  }) async {
    final response = await ApiClient.instance.patch(
      'sprints_management_function/stories/$storyId',
      data: {'SprintID': sprintId},
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;

    throw Exception('Failed to deploy story to sprint');
  }
}
