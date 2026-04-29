import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final completeSprintRepositoryProvider = Provider<CompleteSprintRepository>((
  ref,
) {
  return CompleteSprintRepository();
});

class CompleteSprintRepository {
  Future<Map<String, dynamic>> completeSprint({
    required String sprintId,
    required String carryOverSprintId,
  }) async {
    final payload = {
      "carryOverSprintId": carryOverSprintId,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/sprints/$sprintId/complete',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else {
      throw Exception('Invalid complete sprint response');
    }
  }
}