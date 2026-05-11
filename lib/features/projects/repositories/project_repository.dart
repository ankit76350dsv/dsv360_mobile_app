import 'package:dio/dio.dart'; // needed only for FormData and MultipartFile (file uploads)
import 'package:dsv360/core/network/dio_client.dart'; // single import — no raw http, Dio, or TokenManager needed
import 'package:flutter/foundation.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/cache/user_cache_service.dart';
import 'package:dsv360/features/projects/model/project_model.dart';
import 'package:dsv360/core/models/attachment.dart';

// ---------------------------------------------------------------------------
// How this repository uses ApiClient:
//   - ApiClient.instance is the shared singleton defined in api_client.dart.
//   - The base URL and Authorization header are handled inside ApiClient,
//     so this file only passes relative paths and query/body parameters.
// ---------------------------------------------------------------------------

class ProjectRepository {

  // Use the centralized client — no manual http, no manual token injection.
  final _client = ApiClient.instance;
  Future<List<ProjectModel>> fetchProjects() async {
    // Prefer live auth; fall back to SharedPrefs cache for offline resilience.
    final liveUser = AuthManager.instance.currentUser;
    String userId;
    String roleName;
    if (liveUser != null) {
      userId = liveUser.id;
      roleName = liveUser.role?.name ?? '';
    } else {
      final cached = await UserCacheService.loadUserMap();
      if (cached == null) throw Exception('User not logged in');
      userId = cached['UserId'] ?? '';
      roleName = cached['Role'] ?? '';
    }
    if (userId.isEmpty) throw Exception('User not logged in');

    final isAdmin = roleName == 'Admin' ||
                    roleName == 'Admin (Default)' ||
                    roleName == 'Super Admin' ||
                    roleName == 'App Administrator';

    String url;
    if (isAdmin) {
      url = 'time_entry_management_application_function/projects';
    } else {
      url = 'time_entry_management_application_function/projects/$userId';
    }
    debugPrint(
      '🩸 Fetching projects | isAdmin: $isAdmin | path: $url | Role: $roleName',
    );
    try {
      final response = await _client.get(url);

      debugPrint('📊 Project API Response Status: ${response.statusCode}');
      debugPrint('📊 Project API Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;
        debugPrint('📊 Parsed JSON Response: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          debugPrint('📊 Data List: $data');
          
          if (isAdmin) {
            // Admin response: direct list of project objects
            return data.map((json) => ProjectModel.fromJson(json)).toList();
          } else {
             // AppUser response: list of objects with "Projects" key
             return data.map((json) {
               final projectData = json['Projects'];
               return ProjectModel.fromJson(projectData);
             }).toList();
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching projects: $e');
      throw Exception('Error fetching projects: $e');
    }
  }

  // Create project
  Future<ProjectModel> createProject({
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
    List<Attachment>? attachments,
  }) async {
    debugPrint('🔵 Creating project: $projectName');
    
    if (attachments != null && attachments.isNotEmpty) {
      return _createWithMultipart(
        projectName: projectName,
        status: status,
        clientId: clientId,
        clientName: clientName,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
        ownerId: ownerId,
        ownerName: ownerName,
        description: description,
        attachments: attachments,
      );
    } else {
      return _createWithJson(
        projectName: projectName,
        status: status,
        clientId: clientId,
        clientName: clientName,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
        ownerId: ownerId,
        ownerName: ownerName,
        description: description,
      );
    }
  }

  Future<ProjectModel> _createWithJson({
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
  }) async {
    // Relative path — base URL and token handled by ApiClient.
    const path = 'time_entry_management_application_function/projects';

    final body = {
      'Project_Name': projectName,
      'Status': status,
      'Client_ID': clientId,
      'Client_Name': clientName,
      'Start_Date': startDate.toIso8601String().split('T')[0],
      'End_Date': endDate.toIso8601String().split('T')[0],
      if (assignedToId != null) 'Assigned_To_Id': assignedToId,
      if (assignedToName != null) 'Assigned_To': assignedToName,
      if (ownerId != null) 'Owner_Id': ownerId,
      if (ownerName != null) 'Owner': ownerName,
      if (description != null && description.isNotEmpty) 'Description': description,
    };

    debugPrint('📤 POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return ProjectModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create project');
        }
      } else {
        throw Exception('Failed to create project: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating project: $e');
      throw Exception('Error creating project: $e');
    }
  }

  Future<ProjectModel> _createWithMultipart({
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
    required List<Attachment> attachments,
  }) async {
    // Relative path — base URL and token handled by ApiClient.
    const path = 'time_entry_management_application_function/projects';

    try {
      // Build multipart form data using Dio's FormData.
      final formData = FormData.fromMap({
        'Project_Name': projectName,
        'Status': status,
        'Client_ID': clientId,
        'Client_Name': clientName,
        'Start_Date': startDate.toIso8601String().split('T')[0],
        'End_Date': endDate.toIso8601String().split('T')[0],
        if (assignedToId != null) 'Assigned_To_Id': assignedToId,
        if (assignedToName != null) 'Assigned_To': assignedToName,
        if (ownerId != null) 'Owner_Id': ownerId,
        if (ownerName != null) 'Owner': ownerName,
        if (description != null && description.isNotEmpty) 'Description': description,
      });

      for (var attachment in attachments) {
        if (attachment.localFile != null) {
          final file = attachment.localFile!;
          formData.files.add(MapEntry(
            'files',
            MultipartFile.fromFileSync(file.path, filename: attachment.fileName),
          ));
        }
      }

      debugPrint('📤 Multipart POST $path with ${attachments.length} files');

      final response = await _client.post(path, data: formData);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return ProjectModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to create project');
        }
      } else {
        throw Exception('Failed to create project: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating project with files: $e');
      throw Exception('Error creating project: $e');
    }
  }

  // Update project
  Future<ProjectModel> updateProject({
    required String projectId,
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
    List<Attachment>? attachments,
  }) async {
    debugPrint('🔵 Updating project: $projectId');

    if (attachments != null && attachments.any((a) => a.localFile != null)) {
      return _updateWithMultipart(
        projectId: projectId,
        projectName: projectName,
        status: status,
        clientId: clientId,
        clientName: clientName,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
        ownerId: ownerId,
        ownerName: ownerName,
        description: description,
        attachments: attachments,
      );
    } else {
      return _updateWithJson(
        projectId: projectId,
        projectName: projectName,
        status: status,
        clientId: clientId,
        clientName: clientName,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        assignedToName: assignedToName,
        ownerId: ownerId,
        ownerName: ownerName,
        description: description,
      );
    }
  }

  Future<ProjectModel> _updateWithJson({
    required String projectId,
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
  }) async {
    // Relative path — base URL and token handled by ApiClient.
    final path = 'time_entry_management_application_function/projects/$projectId';

    final body = {
      'Project_Name': projectName,
      'Status': status,
      'Client_ID': clientId,
      'Client_Name': clientName,
      'Start_Date': startDate.toIso8601String().split('T')[0],
      'End_Date': endDate.toIso8601String().split('T')[0],
      if (assignedToId != null) 'Assigned_To_Id': assignedToId,
      if (assignedToName != null) 'Assigned_To': assignedToName,
      if (ownerId != null) 'Owner_Id': ownerId,
      if (ownerName != null) 'Owner': ownerName,
      if (description != null && description.isNotEmpty) 'Description': description,
    };

    debugPrint('📤 POST $path with body: $body');

    try {
      final response = await _client.post(path, data: body);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return ProjectModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update project');
        }
      } else {
        throw Exception('Failed to update project: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating project: $e');
      throw Exception('Error updating project: $e');
    }
  }

  Future<ProjectModel> _updateWithMultipart({
    required String projectId,
    required String projectName,
    required String status,
    required String clientId,
    required String clientName,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? assignedToName,
    String? ownerId,
    String? ownerName,
    String? description,
    required List<Attachment> attachments,
  }) async {
    // Relative path — base URL and token handled by ApiClient.
    final path = 'time_entry_management_application_function/projects/$projectId';

    try {
      // Build multipart form data using Dio's FormData.
      final formData = FormData.fromMap({
        'Project_Name': projectName,
        'Status': status,
        'Client_ID': clientId,
        'Client_Name': clientName,
        'Start_Date': startDate.toIso8601String().split('T')[0],
        'End_Date': endDate.toIso8601String().split('T')[0],
        if (assignedToId != null) 'Assigned_To_Id': assignedToId,
        if (assignedToName != null) 'Assigned_To': assignedToName,
        if (ownerId != null) 'Owner_Id': ownerId,
        if (ownerName != null) 'Owner': ownerName,
        if (description != null && description.isNotEmpty) 'Description': description,
      });

      for (var attachment in attachments) {
        if (attachment.localFile != null) {
          final file = attachment.localFile!;
          formData.files.add(MapEntry(
            'files',
            MultipartFile.fromFileSync(file.path, filename: attachment.fileName),
          ));
        }
      }

      debugPrint('📤 Multipart POST $path with ${attachments.where((a) => a.localFile != null).length} new files');

      final response = await _client.post(path, data: formData);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return ProjectModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to update project');
        }
      } else {
        throw Exception('Failed to update project: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating project with files: $e');
      throw Exception('Error updating project: $e');
    }
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    // Relative path — base URL and token handled by ApiClient.
    final path = 'time_entry_management_application_function/delete/$projectId';

    debugPrint('🔴 DELETE $path');

    try {
      final response = await _client.delete(path);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        if (jsonResponse['success'] != true) {
          throw Exception(jsonResponse['message'] ?? 'Failed to delete project');
        }
      } else {
        throw Exception('Failed to delete project: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting project: $e');
      throw Exception('Error deleting project: $e');
    }
  }
}
