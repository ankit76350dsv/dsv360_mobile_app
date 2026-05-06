import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateTaskStatusRepositoryProvider =
    Provider<UpdateSubTaskStatusRepository>((ref) {
  return UpdateSubTaskStatusRepository();
});

class UpdateSubTaskStatusRepository {
  Future<Map<String, dynamic>> updateSubTaskStatus({
    required String subtaskId,
    required String status,
  }) async {
    if (subtaskId.isEmpty) {
      throw Exception('Subtask ID is empty — cannot update status');
    }

    final payload = {
      "Status": status,
    };

    debugPrint('✏️ Updating subtask status: subtaskId=$subtaskId, status=$status');

    final response = await ApiClient.instance.patch(
      'sprints_management_function/subtasks/$subtaskId',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else {
      throw Exception('Invalid update subtask status response');
    }
  }
}