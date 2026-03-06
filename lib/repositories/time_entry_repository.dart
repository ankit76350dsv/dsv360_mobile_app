import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/time_entry_model.dart';
import '../core/constants/server_constant.dart';
import '../core/constants/token_manager.dart';

class TimeEntryRepository {
  final http.Client httpClient;

  TimeEntryRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  // ============ Timer Management ============

  /// Check if timer is running for user
  Future<Map<String, dynamic>> checkTimerStatus(String userId) async {
    try {
      debugPrint('⏱️ Checking timer status for userId: $userId');
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/timer?userId=$userId'),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('⏱️ Timer Status Response: ${response.statusCode}');
      debugPrint('⏱️ Timer Status Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check timer status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error checking timer status: $e');
      rethrow;
    }
  }

  /// Start timer for a task
  Future<Map<String, dynamic>> startTimer({
    required String userId,
    required String taskId,
    required String projectId,
    String? description,
  }) async {
    try {
      debugPrint('⏱️ Starting timer - userId: $userId, taskId: $taskId');
      final body = {
        'userId': userId,
        'taskId': taskId,
        'projectId': projectId,
        if (description != null) 'description': description,
      };

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/timer/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⏱️ Start Timer Response: ${response.statusCode}');
      debugPrint('⏱️ Start Timer Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start timer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error starting timer: $e');
      rethrow;
    }
  }

  /// End/Stop timer
  Future<Map<String, dynamic>> endTimer({
    required String userId,
    required String timerId,
  }) async {
    try {
      debugPrint('⏱️ Stopping timer - timerId: $timerId');
      final body = {
        'userId': userId,
        'timerId': timerId,
      };

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/timer/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⏱️ End Timer Response: ${response.statusCode}');
      debugPrint('⏱️ End Timer Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to end timer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error ending timer: $e');
      rethrow;
    }
  }

  // ============ Time Entry CRUD ============

  /// Get time entries by task ID
  Future<List<TimeEntry>> getTimeEntriesByTask(String taskId, {String? userId}) async {
    try {
      debugPrint('📋 Fetching time entries for taskId: $taskId, userId: $userId');
      final url = userId != null 
          ? '${ServerConstant.serverURL}time_entry_management_application_function/timeentry/$taskId?userId=$userId'
          : '${ServerConstant.serverURL}time_entry_management_application_function/timeentry/$taskId';
      
      debugPrint('🌐 Time Entry URL: $url');
      
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('📋 Time Entry Response Status: ${response.statusCode}');
      debugPrint('📋 Time Entry Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 Full JSON Structure: $jsonData');
        debugPrint('📋 Response Keys: ${jsonData.keys}');
        
        final List<dynamic> data = jsonData['data'] ?? [];
        debugPrint('📋 Data array: $data');
        
        if (data.isEmpty) {
          return [];
        }
        
        // Check if response has nested structure (like project endpoint: data[i].details[j].Time_Entries)
        if (data.isNotEmpty && data.first is Map && data.first.containsKey('details')) {
          final List<TimeEntry> timeEntries = [];
          for (final taskItem in data) {
            final details = taskItem['details'] as List<dynamic>?;
            if (details != null) {
              for (final detailItem in details) {
                final timeEntry = detailItem['Time_Entries'];
                if (timeEntry != null) {
                  timeEntries.add(TimeEntry.fromJson(timeEntry));
                }
              }
            }
          }
          debugPrint('📋 Parsed ${timeEntries.length} time entries (nested structure)');
          return timeEntries;
        } else {
          // Direct array of time entries
          debugPrint('📋 First entry sample: ${data.first}');
          if (data.isNotEmpty && data.first is Map) {
            debugPrint('📋 First entry keys: ${(data.first as Map).keys}');
          }
          return data.map((item) => TimeEntry.fromJson(item)).toList();
        }
      } else {
        throw Exception('Failed to fetch time entries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching time entries: $e');
      rethrow;
    }
  }

  /// Get time entries by task ID with optional date range filter
  Future<List<TimeEntry>> getTimeEntriesByTaskWithDateFilter({
    required String taskId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final startDateStr = startDate?.toString().split(' ')[0]; // YYYY-MM-DD
      final endDateStr = endDate?.toString().split(' ')[0]; // YYYY-MM-DD
      
      debugPrint('📋 Fetching time entries for taskId: $taskId, userId: $userId, from: $startDateStr to: $endDateStr');
      
      // Build URL with optional parameters
      String url = '${ServerConstant.serverURL}time_entry_management_application_function/timeentry/$taskId';
      final params = <String>[];
      if (userId != null) params.add('userId=$userId');
      if (startDateStr != null) params.add('startDate=$startDateStr');
      if (endDateStr != null) params.add('endDate=$endDateStr');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      debugPrint('🌐 Time Entry URL: $url');
      
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('📋 Task Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Task Time Entry Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 Full JSON Structure: $jsonData');
        
        final List<dynamic> data = jsonData['data'] ?? [];
        debugPrint('📋 Data array length: ${data.length}');
        
        if (data.isEmpty) {
          return [];
        }
        
        // Check if response has nested structure
        if (data.isNotEmpty && data.first is Map && data.first.containsKey('details')) {
          final List<TimeEntry> timeEntries = [];
          for (final taskItem in data) {
            final details = taskItem['details'] as List<dynamic>?;
            if (details != null) {
              for (final detailItem in details) {
                final timeEntry = detailItem['Time_Entries'];
                if (timeEntry != null) {
                  timeEntries.add(TimeEntry.fromJson(timeEntry));
                }
              }
            }
          }
          debugPrint('📋 Parsed ${timeEntries.length} time entries with date filter (nested structure)');
          return timeEntries;
        } else {
          // Direct array of time entries
          final timeEntries = data.map((item) => TimeEntry.fromJson(item)).toList();
          debugPrint('📋 Parsed ${timeEntries.length} time entries with date filter');
          return timeEntries;
        }
      } else {
        throw Exception('Failed to fetch task time entries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching task time entries with date filter: $e');
      rethrow;
    }
  }

  /// Get time entries by project ID with optional date range filter
  Future<List<TimeEntry>> getTimeEntriesByProjectWithDateFilter({
    required String projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final startDateStr = startDate?.toString().split(' ')[0]; // YYYY-MM-DD
      final endDateStr = endDate?.toString().split(' ')[0]; // YYYY-MM-DD
      
      debugPrint('📋 Fetching time entries for projectId: $projectId, from: $startDateStr to: $endDateStr');
      
      final url = startDateStr != null && endDateStr != null
          ? '${ServerConstant.serverURL}time_entry_management_application_function/time_entry/project/$projectId?startDate=$startDateStr&endDate=$endDateStr'
          : '${ServerConstant.serverURL}time_entry_management_application_function/time_entry/project/$projectId';
      
      debugPrint('🌐 Time Entry URL: $url');
      
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('📋 Project Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Project Time Entry Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 Full JSON Structure: $jsonData');
        
        final List<dynamic> data = jsonData['data'] ?? [];
        debugPrint('📋 Data array length: ${data.length}');
        
        // Parse nested structure: data[i].details[j].Time_Entries
        final List<TimeEntry> timeEntries = [];
        for (final taskItem in data) {
          final details = taskItem['details'] as List<dynamic>?;
          if (details != null) {
            for (final detailItem in details) {
              final timeEntry = detailItem['Time_Entries'];
              if (timeEntry != null) {
                timeEntries.add(TimeEntry.fromJson(timeEntry));
              }
            }
          }
        }
        
        debugPrint('📋 Parsed ${timeEntries.length} time entries with date filter');
        return timeEntries;
      } else {
        throw Exception(
            'Failed to fetch project time entries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching project time entries: $e');
      rethrow;
    }
  }

  /// Get time entries by project ID
  Future<List<TimeEntry>> getTimeEntriesByProject(String projectId) async {
    try {
      debugPrint('📋 Fetching time entries for projectId: $projectId');
      final url = '${ServerConstant.serverURL}time_entry_management_application_function/time_entry/project/$projectId';
      debugPrint('🌐 Time Entry URL: $url');
      
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse(url),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('📋 Project Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Project Time Entry Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 Full JSON Structure: $jsonData');
        
        final List<dynamic> data = jsonData['data'] ?? [];
        debugPrint('📋 Data array length: ${data.length}');
        
        // Parse nested structure: data[i].details[j].Time_Entries
        final List<TimeEntry> timeEntries = [];
        for (final taskItem in data) {
          final details = taskItem['details'] as List<dynamic>?;
          if (details != null) {
            for (final detailItem in details) {
              final timeEntry = detailItem['Time_Entries'];
              if (timeEntry != null) {
                timeEntries.add(TimeEntry.fromJson(timeEntry));
              }
            }
          }
        }
        
        debugPrint('📋 Parsed ${timeEntries.length} time entries');
        return timeEntries;
      } else {
        throw Exception(
            'Failed to fetch project time entries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching project time entries: $e');
      rethrow;
    }
  }

  /// Get time entries by user ID with date range
  Future<List<TimeEntry>> getTimeEntriesByUser({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toString().split(' ')[0]; // YYYY-MM-DD
      final endDateStr = endDate.toString().split(' ')[0]; // YYYY-MM-DD

      debugPrint(
          '📋 Fetching user time entries - userId: $userId, from: $startDateStr to: $endDateStr');

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse(
            '${ServerConstant.serverURL}time_entry_management_application_function/user-timeentry?userId=$userId&startDate=$startDateStr&endDate=$endDateStr'),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('📋 User Time Entry Response: ${response.statusCode}');
      debugPrint('📋 User Time Entry Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        return data.map((item) => TimeEntry.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch user time entries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user time entries: $e');
      rethrow;
    }
  }

  /// Create time entry
  Future<TimeEntry> createTimeEntry({
    required String taskId,
    required String projectId,
    required String userId,
    required String username,
    required String taskName,
    required String projectName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? description,
    int? totalMinutes,
    String? type,
  }) async {
    try {
      debugPrint('Creating time entry');
      final body = {
        'Task_ID': taskId,
        'Project_ID': projectId,
        'User_ID': userId,
        'Username': username,
        'Task_Name': taskName,
        'Project_Name': projectName,
        'Entry_Date': date.toString().split(' ')[0],
        'Start_time': startTime,
        'End_time': endTime,
        if (description != null && description.isNotEmpty) 'Note': description,
        if (totalMinutes != null) 'Total_time': totalMinutes,
        if (type != null) 'Type': type,
      };

      debugPrint('Request Body: $body');

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('Create Time Entry Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true || jsonData['data'] != null) {
          return TimeEntry.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to create time entry');
        }
      } else {
        throw Exception('Failed to create time entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating time entry: $e');
      rethrow;
    }
  }

  /// Update time entry
  Future<TimeEntry> updateTimeEntry({
    required String timeEntryId,
    String? taskId,
    String? projectId,
    String? userId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? description,
    int? totalMinutes,
    String? type,
  }) async {
    try {
      debugPrint('✏️ Updating time entry: $timeEntryId');
      final body = <String, dynamic>{
        if (taskId != null) 'Task_ID': taskId,
        if (projectId != null) 'Project_ID': projectId,
        if (userId != null) 'User_ID': userId,
        if (date != null) 'Entry_Date': date.toString().split(' ')[0],
        if (startTime != null) 'Start_time': startTime,
        if (endTime != null) 'End_time': endTime,
        if (description != null && description.isNotEmpty) 'Note': description,
        if (totalMinutes != null) 'Total_time': totalMinutes,
        if (type != null) 'Type': type,
      };

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/$timeEntryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('✏️ Update Time Entry Response: ${response.statusCode}');
      debugPrint('✏️ Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true || jsonData['data'] != null) {
          return TimeEntry.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to update time entry');
        }
      } else {
        throw Exception('Failed to update time entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating time entry: $e');
      rethrow;
    }
  }

  /// Delete time entry
  Future<bool> deleteTimeEntry(String timeEntryId) async {
    try {
      debugPrint('🗑️ Deleting time entry: $timeEntryId');
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.delete(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/$timeEntryId'),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('🗑️ Delete Time Entry Response: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Error deleting time entry: $e');
      rethrow;
    }
  }

  // ============ Time Entry Approval ============

  /// Create approval request
  Future<Map<String, dynamic>> createApprovalRequest({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> timeEntryIds,
  }) async {
    try {
      debugPrint('✅ Creating approval request for userId: $userId');
      final body = {
        'startDate': startDate.toString().split(' ')[0],
        'endDate': endDate.toString().split(' ')[0],
        'timeEntryIds': timeEntryIds,
      };

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/approval/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('✅ Create Approval Response: ${response.statusCode}');
      debugPrint('✅ Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to create approval request: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating approval request: $e');
      rethrow;
    }
  }

  /// Approve or reject time entry
  Future<Map<String, dynamic>> respondToApproval({
    required String approvalId,
    required String status, // 'Approved' or 'Rejected'
    String? comments,
    String? reviewerId,
  }) async {
    try {
      debugPrint('✅ Responding to approval: $approvalId - Status: $status');
      final body = {
        'approvalId': approvalId,
        'status': status,
        if (comments != null) 'comments': comments,
        if (reviewerId != null) 'reviewerId': reviewerId,
      };

      final token = await TokenManager.instance.getToken();
      final response = await httpClient.post(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/approval'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Zoho-oauthtoken $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('✅ Approval Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to respond to approval: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error responding to approval: $e');
      rethrow;
    }
  }

  /// Get user time entry approvals (pending approvals for a user)
  Future<List<dynamic>> getUserApprovals(String userId) async {
    try {
      debugPrint('✅ Fetching user approvals for: $userId');
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/approval/$userId'),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('✅ User Approvals Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? [];
      } else {
        throw Exception('Failed to fetch user approvals: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user approvals: $e');
      rethrow;
    }
  }

  /// Get team time entry approvals (for managers to review)
  Future<List<dynamic>> getTeamApprovals(String managerId) async {
    try {
      debugPrint('✅ Fetching team approvals for manager: $managerId');
      final token = await TokenManager.instance.getToken();
      final response = await httpClient.get(
        Uri.parse('${ServerConstant.serverURL}time_entry_management_application_function/timeentry/approval?managerId=$managerId'),
        headers: {'Authorization': 'Zoho-oauthtoken $token'},
      );

      debugPrint('✅ Team Approvals Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? [];
      } else {
        throw Exception('Failed to fetch team approvals: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching team approvals: $e');
      rethrow;
    }
  }
}
