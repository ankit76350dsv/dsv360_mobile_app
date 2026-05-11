import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/cache/user_cache_service.dart';
import 'package:dsv360/core/constants/environment.dart';
import 'package:dsv360/core/models/attachment.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Main notifier (fetch + CRUD delegates) ──────────────────────────────────

class FetchTasksRepository extends FamilyAsyncNotifier<List<Task>, String> {
  final _client = ApiClient.instance;

  @override
  FutureOr<List<Task>> build(String userId) async {
    return fetchTasks(userId);
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final user = AuthManager.instance.currentUser;
      final cachedMap = user == null ? await UserCacheService.loadUserMap() : null;
      final roleName = user?.role?.name ?? cachedMap?['Role'] ?? '';

      final isAdmin =
          roleName == 'Admin' ||
          roleName == 'Admin (Default)' ||
          roleName == 'Super Admin' ||
          roleName == 'App Administrator';

      final isManager = roleName == 'Manager/Team Lead';

      debugPrint(
        '📋 Fetching tasks | isAdmin: $isAdmin | isManager: $isManager | Role: ${user?.role?.name} | userId: $userId',
      );

      if (isAdmin) {
        const path = 'time_entry_management_application_function/tasks';
        debugPrint('🔐 Full Environment: ${ENVIRONMENT.environment}');
        debugPrint('🔐 Current User: ${user?.firstName} ${user?.lastName}');
        debugPrint('🔐 User Role: ${user?.role?.name}');
        final response = await _client.get(path);
        debugPrint('Response From fetchTasks - Status: ${response.statusCode}');
        debugPrint('📊 Task API Response Body: ${response.data}');
        return _parseTasks(response);
      } else if (isManager) {
        debugPrint('📋 Manager detected - fetching projects first');
        final projectsPath =
            'time_entry_management_application_function/projects/$userId';
        final projectsResponse = await _client.get(projectsPath);

        if (projectsResponse.statusCode == 200) {
          final projectsJson = projectsResponse.data as Map<String, dynamic>;
          if (projectsJson['success'] == true) {
            final List<dynamic> projectsData = projectsJson['data'] ?? [];
            final List<Task> allTasks = [];

            for (var projectItem in projectsData) {
              final projectData = projectItem['Projects'];
              final projectId = projectData['ROWID']?.toString() ?? '';

              if (projectId.isNotEmpty) {
                debugPrint('📋 Fetching tasks for project: $projectId');
                const tasksPath =
                    'time_entry_management_application_function/tasks/project';
                final tasksResponse = await _client.post(
                  tasksPath,
                  data: {'projectID': projectId},
                );
                if (tasksResponse.statusCode == 200) {
                  allTasks.addAll(_parseTasks(tasksResponse));
                }
              }
            }

            debugPrint('📊 Total tasks fetched for manager: ${allTasks.length}');
            return allTasks;
          }
        }
        return [];
      } else {
        final path =
            'time_entry_management_application_function/tasks/employee/$userId';
        debugPrint('📋 User path: $path');
        final response = await _client.get(path);
        debugPrint('Response From fetchTasks - Status: ${response.statusCode}');
        debugPrint('📊 Task API Response Body: ${response.data}');
        return _parseTasks(response);
      }
    } catch (e) {
      developer.log('Error fetching tasks: $e', name: 'FetchTasksRepository');
      debugPrint('❌ Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    state = const AsyncLoading<List<Task>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => fetchTasks(userId));
  }

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
  }) {
    return TaskRepository().createTask(
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
    );
  }

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
  }) {
    return TaskRepository().updateTask(
      rowId: rowId,
      taskName: taskName,
      projectID: projectID,
      projectName: projectName,
      assignToId: assignToId,
      assignToName: assignToName,
      priority: priority,
      status: status,
      description: description,
      startDate: startDate,
      dueDate: dueDate,
      attachments: attachments,
    );
  }

  Future<void> deleteTask(String rowId) {
    return TaskRepository().deleteTask(rowId);
  }

  List<Task> _parseTasks(dynamic response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        final List<dynamic> list = jsonResponse['data'] ?? [];
        debugPrint('📊 Task Data List Length: ${list.length}');

        return list
            .map((e) {
              try {
                final taskData = e as Map<String, dynamic>;
                final taskId = taskData['ROWID']?.toString() ?? '';

                if (taskId == '17682000000712507' ||
                    taskId == '2507' ||
                    taskData['Task_Name']?.toString().contains('2507') == true) {
                  debugPrint('🔍 FOUND TASK WITH ATTACHMENT (ID: $taskId)');
                  debugPrint('🔍 Full Task Data: $taskData');
                }

                return Task.fromJson(taskData);
              } catch (parseError) {
                debugPrint('⚠️ Error parsing task: $parseError');
                return null;
              }
            })
            .whereType<Task>()
            .toList();
      } else {
        throw Exception('API returned success: false');
      }
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }
}

final tasksListRepositoryProvider =
    AsyncNotifierProvider.family<FetchTasksRepository, List<Task>, String>(
  FetchTasksRepository.new,
);

// ── Plain CRUD + fetch repository ───────────────────────────────────────────

class TaskRepository {
  final _client = ApiClient.instance;

  Future<List<Task>> fetchAllTasks() async {
    try {
      const path = 'time_entry_management_application_function/tasks';
      final response = await _client.get(path);
      debugPrint('Response From fetchAllTasks: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse['data'] ?? [];
          return list
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      developer.log('Error fetching all tasks: $e', name: 'TaskRepository');
      return [];
    }
  }

  Future<List<Task>> fetchTasksByProject(String projectID) async {
    try {
      const path = 'time_entry_management_application_function/tasks/project';
      final response = await _client.post(path, data: {'projectID': projectID});
      debugPrint('Response From fetchTasksByProject: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse['data'] ?? [];
          return list
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      developer.log('Error fetching tasks by project: $e', name: 'TaskRepository');
      return [];
    }
  }

  Future<List<Task>> fetchTasksByProjectAndUser(
    String projectId,
    String userId,
  ) async {
    try {
      const path =
          'time_entry_management_application_function/taskByProjectAndUser';
      final response = await _client.get(
        path,
        queryParameters: {'projectId': projectId, 'userId': userId},
      );
      debugPrint(
        'Response From fetchTasksByProjectAndUser: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse['data'] ?? [];
          return list
              .map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      developer.log(
        'Error fetching tasks by project and user: $e',
        name: 'TaskRepository',
      );
      return [];
    }
  }

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
      debugPrint('🔧 CREATE TASK - Starting task creation');
      debugPrint('📝 Task Name: $taskName');
      debugPrint('📁 Project ID: $projectID');
      debugPrint('👤 Assign To ID: $assignToId');
      debugPrint('⚡ Status: $status');
      debugPrint('📅 Start Date: $startDate');
      debugPrint('📅 Due Date: $dueDate');
      debugPrint('📎 Attachments: ${attachments?.length ?? 0} file(s)');

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
      debugPrint('❌ EXCEPTION in createTask: $e');
      debugPrint('📍 Stack Trace: $st');
      developer.log('Error creating task: $e', name: 'TaskRepository');
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
      'Task_Name': taskName,
      'ProjectID': projectID,
      if (projectName != null) 'Project_Name': projectName,
      if (assignToId != null) 'Assign_To_ID': assignToId,
      if (assignToName != null) 'Assign_To': assignToName,
      if (status != null) 'Status': status,
      if (description != null) 'Description': description,
      if (startDate != null) 'Start_Date': startDate,
      if (dueDate != null) 'End_Date': dueDate,
    };
    debugPrint('📦 Request Body: $body');
    final response = await _client.post(path, data: body);
    debugPrint('✅ Response Status Code: ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final taskData = jsonResponse['data'] as Map<String, dynamic>;
        final createdTask = Task.fromJson(taskData);
        debugPrint('✅ Task created successfully: ${createdTask.taskId}');
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
    debugPrint('📤 Using multipart form-data for file upload');

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
        debugPrint('⚠️ File $i: localFile is null, skipping');
        continue;
      }
      if (!attachment.localFile!.existsSync()) {
        debugPrint(
          '❌ File $i (${attachment.fileName}): does not exist at ${attachment.localFile!.path}',
        );
        continue;
      }
      debugPrint(
        '📎 Adding file $i: ${attachment.fileName} (${attachment.fileSize} bytes)',
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
      debugPrint('✅ File $i added to multipart request');
    }

    if (filesAdded == 0) {
      debugPrint('⚠️ WARNING: No files were added! Total attachments: ${attachments.length}');
    }

    debugPrint('🚀 Sending multipart request with $filesAdded file(s)');
    final response = await _client.post(path, data: formData);
    debugPrint('✅ Response Status Code: ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ Task submission successful!');
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
      debugPrint('✅ Task created with $filesAdded attachment(s): ${createdTask.taskId}');
      return createdTask;
    }
    throw Exception(
      'Failed to create task: ${response.statusCode} - ${response.data}',
    );
  }

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
      final path = 'time_entry_management_application_function/tasks/$rowId';
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
        };
      }

      final response = await _client.post(path, data: requestData);
      debugPrint('Response From updateTask: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('📦 Request Body: $requestData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse =
            response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final taskData = jsonResponse['data'] as Map<String, dynamic>;
          return Task.fromJson(taskData);
        }
      }
      throw Exception('Failed to update task: ${response.statusCode}');
    } catch (e) {
      developer.log('Error updating task: $e', name: 'TaskRepository');
      rethrow;
    }
  }

  Future<void> deleteTask(String rowId) async {
    try {
      final path = 'time_entry_management_application_function/tasks/$rowId';
      final response = await _client.delete(path);
      debugPrint('Response From deleteTask: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e, st) {
      developer.log('Error deleting task: $e', name: 'TaskRepository');
      throw AsyncError(e, st);
    }
  }
}

// Legacy class aliases so existing consumers compile unchanged.
class CreateTaskRepository extends TaskRepository {}
class UpdateTaskRepository extends TaskRepository {}
class DeleteTaskRepository extends TaskRepository {}
class FetchAllTasksRepository extends TaskRepository {}
class FetchTasksByProjectRepository extends TaskRepository {}
class FetchTasksByProjectAndUserRepository extends TaskRepository {}
