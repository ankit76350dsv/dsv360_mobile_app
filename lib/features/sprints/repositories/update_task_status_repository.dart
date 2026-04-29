import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateTaskStatusRepositoryProvider =
    Provider<UpdateTaskStatusRepository>((ref) {
  return UpdateTaskStatusRepository();
});

class UpdateTaskStatusRepository {
  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final payload = {
      "Status": status,
    };

    final response = await ApiClient.instance.patch(
      'sprints_management_function/tasks/$taskId',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else {
      throw Exception('Invalid update task status response');
    }
  }
}
