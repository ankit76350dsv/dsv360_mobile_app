import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/task_model.dart';
import 'package:flutter/foundation.dart';

class TaskSubtaskRepository {
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
      'Title': title,
      'ProjectID': projectId,
      'StoryID': storyId,
      'AssigneeID': assigneeId,
      'DueDate': dueDate,
      'EstimatedHours': estimatedHours,
      'Status': status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/tasks',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return TaskModel.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception('Failed to create task');
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final response = await ApiClient.instance.patch(
      'sprints_management_function/tasks/$taskId',
      data: {'Status': status},
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception('Invalid update task status response');
  }

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
      'Title': title,
      'ProjectID': projectId,
      'StoryID': storyId,
      'TaskID': taskId,
      'AssigneeID': assigneeId,
      'DueDate': dueDate,
      'EstimatedHours': estimatedHours,
      'Status': status,
    };

    final response = await ApiClient.instance.post(
      'sprints_management_function/subtasks',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception('Failed to create subtask');
  }

  Future<Map<String, dynamic>> updateSubTaskStatus({
    required String subtaskId,
    required String status,
  }) async {
    if (subtaskId.isEmpty) throw Exception('Subtask ID is empty — cannot update status');

    debugPrint('✏️ Updating subtask status: subtaskId=$subtaskId, status=$status');

    final response = await ApiClient.instance.patch(
      'sprints_management_function/subtasks/$subtaskId',
      data: {'Status': status},
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    throw Exception('Invalid update subtask status response');
  }
}

class UpdateTaskStatusRepository extends TaskSubtaskRepository {}
class UpdateSubTaskStatusRepository extends TaskSubtaskRepository {}
