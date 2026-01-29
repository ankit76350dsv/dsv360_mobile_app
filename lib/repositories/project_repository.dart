import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/models/project_model.dart';
import 'package:dsv360/models/attachment.dart';
import 'package:zcatalyst_sdk/zcatalyst_sdk.dart'; // For UserRole or similar if needed

class ProjectRepository {
  Future<List<ProjectModel>> fetchProjects() async {
    final user = AuthManager.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final isDevelopment = ServerConstant.serverURL.contains('development');
    // Using simple string check for role for now based on context, or just checking fetching logic.
    // The user provided URLs:
    // User: .../projects/17682000000114004 (ID)
    // Admin: .../projects or .../projects/
    
    // We need to know if the user is Admin or AppUser.
    // AuthManager has currentUser.role.name usually.
    // Let's assume 'Super Admin' or similar for Admin.
    
    final isAdmin = user.role?.name == 'Admin'; 
    // Adjust based on actual role names if known, typically 'Super Admin' in Catalyst.


    String url;
    if (isAdmin) {
       // Admin URL logic
       url = '${ServerConstant.serverURL}time_entry_management_application_function/projects';
    } else {
       // AppUser URL logic
       url = '${ServerConstant.serverURL}time_entry_management_application_function/projects/${user.id}';
    }
    debugPrint(
      '🩸 Fetching projects | isAdmin: $isAdmin | URL: $url | Role: ${user.role?.name}',
    );
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          
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
      debugPrint('Error fetching projects: $e');
      throw Exception('Error fetching projects: $e');
    }
  }

  // Create project
  Future<ProjectModel> createProject({
    required String projectName,
    required String status,
    required String clientId,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? description,
    List<Attachment>? attachments,
  }) async {
    debugPrint('🔵 Creating project: $projectName');
    
    if (attachments != null && attachments.isNotEmpty) {
      return _createWithMultipart(
        projectName: projectName,
        status: status,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        description: description,
        attachments: attachments,
      );
    } else {
      return _createWithJson(
        projectName: projectName,
        status: status,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        description: description,
      );
    }
  }

  Future<ProjectModel> _createWithJson({
    required String projectName,
    required String status,
    required String clientId,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? description,
  }) async {
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/projects';
    
    final body = {
      'Project_Name': projectName,
      'Status': status,
      'Client_ID': clientId,
      'Start_Date': startDate.toIso8601String().split('T')[0],
      'End_Date': endDate.toIso8601String().split('T')[0],
      if (assignedToId != null) 'Assigned_To_Id': assignedToId,
      if (description != null && description.isNotEmpty) 'Description': description,
    };

    debugPrint('📤 POST $url with body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
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
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? description,
    required List<Attachment> attachments,
  }) async {
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/projects';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['Project_Name'] = projectName;
      request.fields['Status'] = status;
      request.fields['Client_ID'] = clientId;
      request.fields['Start_Date'] = startDate.toIso8601String().split('T')[0];
      request.fields['End_Date'] = endDate.toIso8601String().split('T')[0];
      if (assignedToId != null) request.fields['Assigned_To_Id'] = assignedToId;
      if (description != null && description.isNotEmpty) request.fields['Description'] = description;

      // Add files
      for (var attachment in attachments) {
        if (attachment.localFile != null) {
          final file = attachment.localFile!;
          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              file.path,
              filename: attachment.fileName,
            ),
          );
        }
      }

      debugPrint('📤 Multipart POST $url with ${attachments.length} files');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
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
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
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
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        description: description,
        attachments: attachments,
      );
    } else {
      return _updateWithJson(
        projectId: projectId,
        projectName: projectName,
        status: status,
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
        assignedToId: assignedToId,
        description: description,
      );
    }
  }

  Future<ProjectModel> _updateWithJson({
    required String projectId,
    required String projectName,
    required String status,
    required String clientId,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? description,
  }) async {
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/projects/$projectId';

    final body = {
      'Project_Name': projectName,
      'Status': status,
      'Client_ID': clientId,
      'Start_Date': startDate.toIso8601String().split('T')[0],
      'End_Date': endDate.toIso8601String().split('T')[0],
      if (assignedToId != null) 'Assigned_To_Id': assignedToId,
      if (description != null && description.isNotEmpty) 'Description': description,
    };

    debugPrint('📤 POST $url with body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
    required DateTime startDate,
    required DateTime endDate,
    String? assignedToId,
    String? description,
    required List<Attachment> attachments,
  }) async {
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/projects/$projectId';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['Project_Name'] = projectName;
      request.fields['Status'] = status;
      request.fields['Client_ID'] = clientId;
      request.fields['Start_Date'] = startDate.toIso8601String().split('T')[0];
      request.fields['End_Date'] = endDate.toIso8601String().split('T')[0];
      if (assignedToId != null) request.fields['Assigned_To_Id'] = assignedToId;
      if (description != null && description.isNotEmpty) request.fields['Description'] = description;

      // Add new files (those with localFile)
      for (var attachment in attachments) {
        if (attachment.localFile != null) {
          final file = attachment.localFile!;
          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              file.path,
              filename: attachment.fileName,
            ),
          );
        }
      }

      debugPrint('📤 Multipart POST $url with ${attachments.where((a) => a.localFile != null).length} new files');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
    final url = '${ServerConstant.serverURL}time_entry_management_application_function/delete/$projectId';

    debugPrint('🔴 DELETE $url');

    try {
      final response = await http.delete(Uri.parse(url));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
