import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/models/task.dart';
import 'package:dsv360/models/attachment.dart';

part 'task_repository.g.dart';

@riverpod
class TasksListRepository extends _$TasksListRepository {
  @override
  Future<List<Task>> build(String userId) async {
    return fetchTasks(userId);
  }

  /// 2.2 Get Tasks by Employee (Current implementation) or All Tasks if Admin
  Future<List<Task>> fetchTasks(String userId) async {
    try {
      // Check if user is Admin or Manager to determine which endpoint to use
      final user = AuthManager.instance.currentUser;
      final roleName = user?.role?.name ?? '';
      
      final isAdmin = roleName == 'Admin' ||
                      roleName == 'Admin (Default)' || 
                      roleName == 'Super Admin' || 
                      roleName == 'App Administrator';
      
      final isManager = roleName == 'Manager/Team Lead';

      debugPrint("📋 Fetching tasks | isAdmin: $isAdmin | isManager: $isManager | Role: ${user?.role?.name} | userId: $userId");

      if (isAdmin) {
        // Admin gets all tasks
        final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks';
        debugPrint("📋 Admin endpoint: $url");
        
        final response = await http.get(Uri.parse(url));
        debugPrint("Response From fetchTasks - Status: ${response.statusCode}");
        debugPrint("📊 Task API Response Body: ${response.body}");

        return _parseTasks(response);
      } else if (isManager) {
        // Manager gets tasks by projects - need to fetch all manager's projects first
        debugPrint("📋 Manager detected - fetching projects first");
        
        // Fetch manager's projects
        final projectsUrl = '${ServerConstant.serverURL}time_entry_management_application_function/projects/$userId';
        final projectsResponse = await http.get(Uri.parse(projectsUrl));
        
        if (projectsResponse.statusCode == 200) {
          final projectsJson = json.decode(projectsResponse.body);
          if (projectsJson['success'] == true) {
            final List<dynamic> projectsData = projectsJson['data'] ?? [];
            
            // Collect all tasks from all manager's projects
            List<Task> allTasks = [];
            
            for (var projectItem in projectsData) {
              // Extract project data (it's wrapped in "Projects" key)
              final projectData = projectItem['Projects'];
              final projectId = projectData['ROWID']?.toString() ?? '';
              
              if (projectId.isNotEmpty) {
                debugPrint("📋 Fetching tasks for project: $projectId");
                
                // Fetch tasks for this project using POST /tasks/project
                final tasksUrl = '${ServerConstant.serverURL}time_entry_management_application_function/tasks/project';
                final tasksResponse = await http.post(
                  Uri.parse(tasksUrl),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({'projectID': projectId}),
                );
                
                if (tasksResponse.statusCode == 200) {
                  final tasks = _parseTasks(tasksResponse);
                  allTasks.addAll(tasks);
                }
              }
            }
            
            debugPrint("📊 Total tasks fetched for manager: ${allTasks.length}");
            return allTasks;
          }
        }
        
        // Fallback if projects fetch fails
        return [];
      } else {
        // Regular users get only their assigned tasks
        final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks/employee/$userId';
        debugPrint("📋 User endpoint: $url");
        
        final response = await http.get(Uri.parse(url));
        debugPrint("Response From fetchTasks - Status: ${response.statusCode}");
        debugPrint("📊 Task API Response Body: ${response.body}");

        return _parseTasks(response);
      }
    } catch (e, st) {
      developer.log(
        "Error fetching tasks: $e",
        name: "TasksListRepository",
      );
      // Return empty list as fallback if endpoint is not available
      debugPrint("⚠️ Tasks endpoint not available. Returning empty list.");
      debugPrint("📌 To fix: Ensure the tasks endpoint is properly configured on the server.");
      return [];
    }
  }

  // Helper method to parse task response
  List<Task> _parseTasks(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      debugPrint("📊 Parsed Task JSON Response: $jsonResponse");
      
      if (jsonResponse['success'] == true) {
        final List<dynamic> list = jsonResponse["data"] ?? [];
        debugPrint("📊 Task Data List Length: ${list.length}");
        debugPrint("📊 Task Data List: $list");

        // All tasks come as direct objects in the list
        // Parse each task directly from the response
        return list.map((e) {
          try {
            final taskData = e as Map<String, dynamic>;
            final taskId = taskData['ROWID']?.toString() ?? '';
            
            // Print detailed info for task 2507 to see attachment structure
            if (taskId == '17682000000712507' || taskId == '2507' || taskData['Task_Name']?.toString().contains('2507') == true) {
              debugPrint("🔍 ============================================");
              debugPrint("🔍 FOUND TASK WITH ATTACHMENT (ID: $taskId)");
              debugPrint("🔍 ============================================");
              debugPrint("🔍 Full Task Data: $taskData");
              debugPrint("🔍 Task Name: ${taskData['Task_Name']}");
              debugPrint("🔍 Files Field: ${taskData['Files']}");
              debugPrint("🔍 Files Type: ${taskData['Files'].runtimeType}");
              if (taskData['Files'] != null && taskData['Files'].toString().isNotEmpty) {
                debugPrint("🔍 Files Content: ${taskData['Files']}");
              }
              debugPrint("🔍 ============================================");
            }
            
            return Task.fromJson(taskData);
          } catch (parseError) {
            debugPrint("⚠️ Error parsing task: $parseError");
            return null;
          }
        }).whereType<Task>().toList();
      } else {
        throw Exception('API returned success: false');
      }
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  /// 2.1 Get All Tasks (Admin only)
  Future<List<Task>> fetchAllTasks() async {
    try {
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks';
      final response = await http.get(Uri.parse(url));
      debugPrint("Response From fetchAllTasks: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse["data"] ?? [];
          return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e, st) {
      developer.log("Error fetching all tasks: $e", name: "TasksListRepository");
      return [];
    }
  }

  /// 2.3 Get Tasks by Project
  Future<List<Task>> fetchTasksByProject(String projectID) async {
    try {
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks/project';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"projectID": projectID}),
      );
      debugPrint("Response From fetchTasksByProject: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse["data"] ?? [];
          return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e, st) {
      developer.log("Error fetching tasks by project: $e",
          name: "TasksListRepository");
      return [];
    }
  }

  /// 2.4 Get Tasks by Project and User
  Future<List<Task>> fetchTasksByProjectAndUser(
      String projectId, String userId) async {
    try {
      final uri = Uri.parse(
        '${ServerConstant.serverURL}time_entry_management_application_function/taskByProjectAndUser',
      ).replace(queryParameters: {"projectId": projectId, "userId": userId});
      final response = await http.get(uri);
      debugPrint("Response From fetchTasksByProjectAndUser: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> list = jsonResponse["data"] ?? [];
          return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e, st) {
      developer.log("Error fetching tasks by project and user: $e",
          name: "TasksListRepository");
      return [];
    }
  }

  /// 2.5 Create Task (with optional file attachments)
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
      
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks';
      debugPrint("🌐 URL: $url");
      
      // Check if we have attachments - use multipart if we do
      if (attachments != null && attachments.isNotEmpty) {
        return await _createTaskWithMultipart(
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
          url: url,
        );
      } else {
        // Use JSON request for tasks without attachments
        return await _createTaskWithJson(
          taskName: taskName,
          projectID: projectID,
          projectName: projectName,
          assignToId: assignToId,
          assignToName: assignToName,
          status: status,
          description: description,
          startDate: startDate,
          dueDate: dueDate,
          url: url,
        );
      }
    } catch (e, st) {
      debugPrint("❌ EXCEPTION in createTask: $e");
      debugPrint("📍 Stack Trace: $st");
      developer.log("Error creating task: $e", name: "TaskRepository");
      rethrow;
    }
  }

  /// Create task with JSON (no attachments)
  Future<Task> _createTaskWithJson({
    required String taskName,
    required String projectID,
    String? projectName,
    String? assignToId,
    String? assignToName,
    String? status,
    String? description,
    String? startDate,
    String? dueDate,
    required String url,
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
    debugPrint("📦 Request Body: ${json.encode(body)}");

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    debugPrint("✅ Response Status Code: ${response.statusCode}");
    debugPrint("📄 Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        debugPrint("✨ Parsed JSON Success: ${jsonResponse['success']}");
        
        if (jsonResponse['success'] == true) {
          final taskData = jsonResponse["data"] as Map<String, dynamic>;
          debugPrint("📋 Task Data: $taskData");
          final createdTask = Task.fromJson(taskData);
          debugPrint("✅ Task created successfully: ${createdTask.taskId}");
          return createdTask;
        } else {
          debugPrint("❌ API returned success: false. Message: ${jsonResponse['message']}");
          throw Exception('API returned success: false - ${jsonResponse['message'] ?? "Unknown error"}');
        }
      } catch (parseError) {
        debugPrint("❌ JSON Parse Error: $parseError");
        rethrow;
      }
    } else {
      debugPrint("❌ HTTP Error ${response.statusCode}: ${response.body}");
      throw Exception('Failed to create task: ${response.statusCode} - ${response.body}');
    }
  }

  /// Create task with multipart form-data (with attachments)
  Future<Task> _createTaskWithMultipart({
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
    required String url,
  }) async {
    try {
      debugPrint("📤 Using multipart form-data for file upload");
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add form fields
      request.fields['Task_Name'] = taskName;
      request.fields['ProjectID'] = projectID;
      if (projectName != null) request.fields['Project_Name'] = projectName;
      if (assignToId != null) request.fields['Assign_To_ID'] = assignToId;
      if (assignToName != null) request.fields['Assign_To'] = assignToName;
      if (status != null) request.fields['Status'] = status;
      if (description != null) request.fields['Description'] = description;
      if (startDate != null) request.fields['Start_Date'] = startDate;
      if (dueDate != null) request.fields['End_Date'] = dueDate;
      
      // Add files
      for (var i = 0; i < attachments.length; i++) {
        final attachment = attachments[i];
        if (attachment.localFile != null && attachment.localFile!.existsSync()) {
          debugPrint("📎 Adding file $i: ${attachment.fileName} (${attachment.fileSize} bytes)");
          
          final file = attachment.localFile!;
          final mimeType = _getMimeType(attachment.fileName);
          debugPrint("📄 File MIME type: $mimeType");
          
          // Use indexed field name for multiple files
          request.files.add(
            await http.MultipartFile.fromPath(
              'attachments',
              file.path,
              filename: attachment.fileName,
              contentType: http.MediaType.parse(mimeType),
            ),
          );
          debugPrint("✅ File added to multipart request");
        }
      }
      
      debugPrint("🚀 Sending multipart request");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("✅ Response Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          debugPrint("✨ Parsed JSON Success: ${jsonResponse['success']}");
          
          if (jsonResponse['success'] == true) {
            final taskData = jsonResponse["data"] as Map<String, dynamic>;
            debugPrint("📋 Task Data: $taskData");
            final createdTask = Task.fromJson(taskData);
            debugPrint("✅ Task created successfully with ${attachments.length} attachment(s): ${createdTask.taskId}");
            return createdTask;
          } else {
            debugPrint("❌ API returned success: false. Message: ${jsonResponse['message']}");
            throw Exception('API returned success: false - ${jsonResponse['message'] ?? "Unknown error"}');
          }
        } catch (parseError) {
          debugPrint("❌ JSON Parse Error: $parseError");
          rethrow;
        }
      } else {
        debugPrint("❌ HTTP Error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to create task: ${response.statusCode} - ${response.body}');
      }
    } catch (e, st) {
      debugPrint("❌ Multipart request failed: $e");
      debugPrint("📍 Stack Trace: $st");
      rethrow;
      developer.log("Error creating task: $e", name: "TasksListRepository");
      throw AsyncError(e, st);
    }
  }

  /// 2.6 Update Task
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
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks/$rowId';
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

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      debugPrint("Response From updateTask: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.body}");
      debugPrint("📦 Request Body: ${json.encode(body)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final taskData = jsonResponse["data"] as Map<String, dynamic>;
          final updatedTask = Task.fromJson(taskData);
          return updatedTask;
        }
      }
      throw Exception('Failed to update task: ${response.statusCode}');
    } catch (e, st) {
      developer.log("Error updating task: $e", name: "TasksListRepository");
      throw AsyncError(e, st);
    }
  }

  /// 2.7 Delete Task
  Future<void> deleteTask(String rowId) async {
    try {
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/tasks/$rowId';
      final response = await http.delete(Uri.parse(url));
      debugPrint("Response From deleteTask: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e, st) {
      developer.log("Error deleting task: $e", name: "TasksListRepository");
      throw AsyncError(e, st);
    }
  }

  /// Refresh method for pull-to-refresh (keeps cache, shows loading)
  Future<void> refresh(String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchTasks(userId));
  }

  /// Helper method to get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      
      // PDFs
      case 'pdf':
        return 'application/pdf';
      
      // Documents
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      
      // Spreadsheets
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      
      default:
        return 'application/octet-stream';
    }
  }
}