import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/environment.dart';
import 'package:dsv360/core/models/attachment.dart';
import 'package:dsv360/core/models/task.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/task/repositories/create_task_repository.dart';
import 'package:dsv360/features/task/repositories/delete_task_repository.dart';
import 'package:dsv360/features/task/repositories/update_task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchTasksRepository
    extends FamilyAsyncNotifier<List<Task>, String> {
  final _client = ApiClient.instance;

  @override
  FutureOr<List<Task>> build(String userId) async {
    return fetchTasks(userId);
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final user = AuthManager.instance.currentUser;
      final roleName = user?.role?.name ?? '';

      final isAdmin =
          roleName == 'Admin' ||
          roleName == 'Admin (Default)' ||
          roleName == 'Super Admin' ||
          roleName == 'App Administrator';

      final isManager = roleName == 'Manager/Team Lead';

      debugPrint(
        "📋 Fetching tasks | isAdmin: $isAdmin | isManager: $isManager | Role: ${user?.role?.name} | userId: $userId",
      );

      if (isAdmin) {
        const path = 'time_entry_management_application_function/tasks';
        debugPrint('🔐 Full Environment: ${ENVIRONMENT.environment}');
        debugPrint('🔐 Current User: ${user?.firstName} ${user?.lastName}');
        debugPrint('🔐 User Role: ${user?.role?.name}');
        final response = await _client.get(path);
        debugPrint("Response From fetchTasks - Status: ${response.statusCode}");
        debugPrint("📊 Task API Response Body: ${response.data}");
        return _parseTasks(response);
      } else if (isManager) {
        debugPrint("📋 Manager detected - fetching projects first");
        final projectsPath =
            'time_entry_management_application_function/projects/$userId';
        final projectsResponse = await _client.get(projectsPath);

        if (projectsResponse.statusCode == 200) {
          final projectsJson =
              projectsResponse.data as Map<String, dynamic>;
          if (projectsJson['success'] == true) {
            final List<dynamic> projectsData = projectsJson['data'] ?? [];
            final List<Task> allTasks = [];

            for (var projectItem in projectsData) {
              final projectData = projectItem['Projects'];
              final projectId = projectData['ROWID']?.toString() ?? '';

              if (projectId.isNotEmpty) {
                debugPrint("📋 Fetching tasks for project: $projectId");
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

            debugPrint(
              "📊 Total tasks fetched for manager: ${allTasks.length}",
            );
            return allTasks;
          }
        }
        return [];
      } else {
        final path =
            'time_entry_management_application_function/tasks/employee/$userId';
        debugPrint("📋 User path: $path");
        final response = await _client.get(path);
        debugPrint("Response From fetchTasks - Status: ${response.statusCode}");
        debugPrint("📊 Task API Response Body: ${response.data}");
        return _parseTasks(response);
      }
    } catch (e) {
      developer.log("Error fetching tasks: $e", name: "FetchTasksRepository");
      debugPrint("❌ Error fetching tasks: $e");
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    state = const AsyncLoading<List<Task>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => fetchTasks(userId));
  }

  // Delegates to CreateTaskRepository so callers on the notifier continue to work.
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
    return CreateTaskRepository().createTask(
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

  // Delegates to UpdateTaskRepository so callers on the notifier continue to work.
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
  }) {
    return UpdateTaskRepository().updateTask(
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
    );
  }

  // Delegates to DeleteTaskRepository so callers on the notifier continue to work.
  Future<void> deleteTask(String rowId) {
    return DeleteTaskRepository().deleteTask(rowId);
  }

  List<Task> _parseTasks(dynamic response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        final List<dynamic> list = jsonResponse["data"] ?? [];
        debugPrint("📊 Task Data List Length: ${list.length}");

        return list
            .map((e) {
              try {
                final taskData = e as Map<String, dynamic>;
                final taskId = taskData['ROWID']?.toString() ?? '';

                if (taskId == '17682000000712507' ||
                    taskId == '2507' ||
                    taskData['Task_Name']?.toString().contains('2507') ==
                        true) {
                  debugPrint("🔍 FOUND TASK WITH ATTACHMENT (ID: $taskId)");
                  debugPrint("🔍 Full Task Data: $taskData");
                }

                return Task.fromJson(taskData);
              } catch (parseError) {
                debugPrint("⚠️ Error parsing task: $parseError");
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
