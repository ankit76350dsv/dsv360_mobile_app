import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addSubTaskRepositoryProvider = Provider<AddSubTaskRepository>((ref) {
  return AddSubTaskRepository();
});

class AddSubTaskRepository {
  Future<Map<String, dynamic>> addSubTask({
    required String title,
    required String projectId,
    required String storyId,
    required String taskId,
    required String assigneeId,
    required String dueDate,
    required double estimatedHours,
    required String status,
  }) async {
    final payload = {
      "Title": title,
      "ProjectID": projectId,
      "StoryID": storyId,
      "TaskID": taskId,
      "AssigneeID": assigneeId,
      "DueDate": dueDate,
      "EstimatedHours": estimatedHours,
      "Status": status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/subtasks',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['success'] == true && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    } else {
      throw Exception('Failed to create subtask');
    }
  }
}
