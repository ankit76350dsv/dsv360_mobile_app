import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dsv360/core/models/attachment.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

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
    List<Attachment>? attachments,
  }) async {
    try {
      final path =
          'time_entry_management_application_function/tasks/$rowId';

      // New local files to upload
      final newFiles = attachments?.where((a) => a.isLocal).toList() ?? [];

      dynamic requestData;
      if (newFiles.isNotEmpty) {
        final formData = FormData.fromMap({
          if (taskName != null) 'Task_Name': taskName,
          if (projectID != null) 'ProjectID': projectID,
          if (projectName != null) 'Project_Name': projectName,
          if (assignToId != null) 'Assign_To_ID': assignToId,
          if (assignToName != null) 'Assign_To': assignToName,
          if (priority != null) 'Priority': priority,
          if (status != null) 'Status': status,
          if (description != null) 'Description': description,
          if (startDate != null) 'Start_Date': startDate,
          if (dueDate != null) 'End_Date': dueDate,
        });
        final now = DateTime.now().millisecondsSinceEpoch;
        for (var i = 0; i < newFiles.length; i++) {
          final a = newFiles[i];
          if (a.localFile != null && a.localFile!.existsSync()) {
            formData.files.add(MapEntry(
              'files',
              MultipartFile.fromFileSync(
                a.localFile!.path,
                filename: '${now}_${i}_${a.fileName}',
              ),
            ));
          }
        }
        requestData = formData;
      } else {
        requestData = {
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
      }

      final response = await _client.post(path, data: requestData);
      debugPrint("Response From updateTask: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.data}");
      debugPrint("📦 Request Body: $requestData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final taskData = jsonResponse["data"] as Map<String, dynamic>;
          return Task.fromJson(taskData);
        }
      }
      throw Exception('Failed to update task: ${response.statusCode}');
    } catch (e) {
      developer.log(
        "Error updating task: $e",
        name: "UpdateTaskRepository",
      );
      rethrow;
    }
  }
}
