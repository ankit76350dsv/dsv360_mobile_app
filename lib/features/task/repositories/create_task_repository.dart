import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dsv360/core/models/attachment.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class CreateTaskRepository {
  final _client = ApiClient.instance;

  Future<Task> createTask({
    required String taskName,
    required String projectID,
    String? projectName,
    String? assignToId,
    String? assignToName,
    String? status,
    String? description,
    String? startDate,
    String? dueDate,
    List<Attachment>? attachments,
  }) async {
    try {
      debugPrint("🔧 CREATE TASK - Starting task creation");
      debugPrint("📝 Task Name: $taskName");
      debugPrint("📁 Project ID: $projectID");
      debugPrint("👤 Assign To ID: $assignToId");
      debugPrint("⚡ Status: $status");
      debugPrint("📅 Start Date: $startDate");
      debugPrint("📅 Due Date: $dueDate");
      debugPrint("📎 Attachments: ${attachments?.length ?? 0} file(s)");

      const path = 'time_entry_management_application_function/tasks';

      if (attachments != null && attachments.isNotEmpty) {
        return await _createWithMultipart(
          taskName: taskName,
          projectID: projectID,
          projectName: projectName,
          assignToId: assignToId,
          assignToName: assignToName,
          status: status,
          description: description,
          startDate: startDate,
          dueDate: dueDate,
          attachments: attachments,
          path: path,
        );
      }

      return await _createWithJson(
        taskName: taskName,
        projectID: projectID,
        projectName: projectName,
        assignToId: assignToId,
        assignToName: assignToName,
        status: status,
        description: description,
        startDate: startDate,
        dueDate: dueDate,
        path: path,
      );
    } catch (e, st) {
      debugPrint("❌ EXCEPTION in createTask: $e");
      debugPrint("📍 Stack Trace: $st");
      developer.log("Error creating task: $e", name: "CreateTaskRepository");
      rethrow;
    }
  }

  Future<Task> _createWithJson({
    required String taskName,
    required String projectID,
    String? projectName,
    String? assignToId,
    String? assignToName,
    String? status,
    String? description,
    String? startDate,
    String? dueDate,
    required String path,
  }) async {
    final body = {
      "Task_Name": taskName,
      "ProjectID": projectID,
      if (projectName != null) "Project_Name": projectName,
      if (assignToId != null) "Assign_To_ID": assignToId,
      if (assignToName != null) "Assign_To": assignToName,
      if (status != null) "Status": status,
      if (description != null) "Description": description,
      if (startDate != null) "Start_Date": startDate,
      if (dueDate != null) "End_Date": dueDate,
    };
    debugPrint("📦 Request Body: $body");

    final response = await _client.post(path, data: body);
    debugPrint("✅ Response Status Code: ${response.statusCode}");
    debugPrint("📄 Response Body: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        final taskData = jsonResponse["data"] as Map<String, dynamic>;
        final createdTask = Task.fromJson(taskData);
        debugPrint("✅ Task created successfully: ${createdTask.taskId}");
        return createdTask;
      }

      throw Exception(
        'API returned success: false - ${jsonResponse['message'] ?? "Unknown error"}',
      );
    }

    throw Exception(
      'Failed to create task: ${response.statusCode} - ${response.data}',
    );
  }

  Future<Task> _createWithMultipart({
    required String taskName,
    required String projectID,
    String? projectName,
    String? assignToId,
    String? assignToName,
    String? status,
    String? description,
    String? startDate,
    String? dueDate,
    required List<Attachment> attachments,
    required String path,
  }) async {
    debugPrint("📤 Using multipart form-data for file upload");

    final formData = FormData.fromMap({
      'Task_Name': taskName,
      'ProjectID': projectID,
      if (projectName != null) 'Project_Name': projectName,
      if (assignToId != null) 'Assign_To_ID': assignToId,
      if (assignToName != null) 'Assign_To': assignToName,
      if (status != null) 'Status': status,
      if (description != null) 'Description': description,
      if (startDate != null) 'Start_Date': startDate,
      if (dueDate != null) 'End_Date': dueDate,
    });

    int filesAdded = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < attachments.length; i++) {
      final attachment = attachments[i];

      if (attachment.localFile == null) {
        debugPrint("⚠️ File $i: localFile is null, skipping");
        continue;
      }

      if (!attachment.localFile!.existsSync()) {
        debugPrint(
          "❌ File $i (${attachment.fileName}): does not exist at ${attachment.localFile!.path}",
        );
        continue;
      }

      debugPrint(
        "📎 Adding file $i: ${attachment.fileName} (${attachment.fileSize} bytes)",
      );

      final uniqueName = '${now}_${i}_${attachment.fileName}';
      formData.files.add(
        MapEntry(
          'files',
          MultipartFile.fromFileSync(
            attachment.localFile!.path,
            filename: uniqueName,
          ),
        ),
      );
      filesAdded++;
      debugPrint("✅ File $i added to multipart request");
    }

    if (filesAdded == 0) {
      debugPrint(
        "⚠️ WARNING: No files were added! Total attachments: ${attachments.length}",
      );
    }

    debugPrint("🚀 Sending multipart request with $filesAdded file(s)");
    final response = await _client.post(path, data: formData);

    debugPrint("✅ Response Status Code: ${response.statusCode}");
    debugPrint("📄 Response Body: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("✅ Task submission successful!");

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data.containsKey('success') &&
          data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to create task');
      }

      final taskData = data is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final createdTask = Task.fromJson(taskData);
      debugPrint(
        "✅ Task created with $filesAdded attachment(s): ${createdTask.taskId}",
      );
      return createdTask;
    }

    throw Exception(
      'Failed to create task: ${response.statusCode} - ${response.data}',
    );
  }
}
