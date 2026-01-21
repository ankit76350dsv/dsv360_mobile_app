import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/models/project_model.dart';
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
}
