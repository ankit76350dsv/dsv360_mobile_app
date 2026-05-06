import 'dart:developer' as developer;

import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateTaskRepository {
  final _client = ApiClient.instance;

  Future<Task> updateTask({
    required String rowId,
    String? taskName,
    String? projectID,
    String? projectName,
    String? assignToId,
    String? assignToName,
    String? priority,
    String? status,
    String? description,
    String? startDate,
    String? dueDate,
  }) async {
    try {
      final path =
          'time_entry_management_application_function/tasks/$rowId';
      final body = {
        if (taskName != null) "Task_Name": taskName,
        if (projectID != null) "ProjectID": projectID,
        if (projectName != null) "Project_Name": projectName,
        if (assignToId != null) "Assign_To_ID": assignToId,
        if (assignToName != null) "Assign_To": assignToName,
        if (priority != null) "Priority": priority,
        if (status != null) "Status": status,
        if (description != null) "Description": description,
        if (startDate != null) "Start_Date": startDate,
        if (dueDate != null) "End_Date": dueDate,
      };

      final response = await _client.post(path, data: body);
      debugPrint("Response From updateTask: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.data}");
      debugPrint("📦 Request Body: $body");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final taskData = jsonResponse["data"] as Map<String, dynamic>;
          return Task.fromJson(taskData);
        }
      }
      throw Exception('Failed to update task: ${response.statusCode}');
    } catch (e, st) {
      developer.log(
        "Error updating task: $e",
        name: "UpdateTaskRepository",
      );
      throw AsyncError(e, st);
    }
  }
}
