import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateStoryStatusRepositoryProvider =
    Provider<UpdateStoryStatusRepository>((ref) {
  return UpdateStoryStatusRepository();
});

class UpdateStoryStatusRepository {
  Future<void> updateStatus({
    required String storyId,
    required String status,
  }) async {
    final response = await ApiClient.instance.patch(
      'sprints_management_function/stories/$storyId',
      data: {'Status': status},
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;

    throw Exception('Failed to update story status');
  }
}
