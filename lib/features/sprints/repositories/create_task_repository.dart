import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createTaskRepositoryProvider = Provider<CreateTaskRepository>((ref) {
  return CreateTaskRepository();
});

class CreateTaskRepository {
  Future<TaskModel> createTask({
    required String title,
    required String projectId,
    required String storyId,
    required String assigneeId,
    required String dueDate,
    required double estimatedHours,
    required String status,
  }) async {
    final payload = {
      "Title": title,
      "ProjectID": projectId,
      "StoryID": storyId,
      "AssigneeID": assigneeId,
      "DueDate": dueDate,
      "EstimatedHours": estimatedHours,
      "Status": status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/tasks',
      data: payload,
    );

    final data = response.data;

    if (data is Map && data['data'] != null) {
      return TaskModel.fromJson(Map<String, dynamic>.from(data['data']));
    } else {
      throw Exception('Failed to create task');
    }
  }
}
