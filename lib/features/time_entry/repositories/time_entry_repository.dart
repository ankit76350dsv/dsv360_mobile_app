import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart'; // single import — no raw http or TokenManager needed
import '../model/time_entry_model.dart';
import 'check_timer_status_repository.dart';

// ---------------------------------------------------------------------------
// How this repository uses ApiClient:
//   - ApiClient.instance is the shared singleton defined in api_client.dart.
//   - The base URL and Authorization header are handled inside ApiClient,
//     so this file only passes relative paths and query/body parameters.
// ---------------------------------------------------------------------------

class TimeEntryRepository {

  // Use the centralized client — no manual http, no manual token injection.
  final _client = ApiClient.instance;

  // ============ Timer Management ============

  

 
 
  

  // ============ Time Entry CRUD ============

  /// Get time entries by task ID
  Future<List<TimeEntry>> getTimeEntriesByTask(String taskId, {String? userId}) async {
    try {
      debugPrint('📋 Fetching time entries for taskId: $taskId, userId: $userId');
      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/timeentry/$taskId';
      final response = await _client.get(
        path,
        queryParameters: userId != null ? {'userId': userId} : null,
      );

      debugPrint('📋 Time Entry Response Status: ${response.statusCode}');
      debugPrint('📋 Time Entry Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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
      final startDateStr = startDate?.toString().split(' ')[0];
      final endDateStr = endDate?.toString().split(' ')[0];

      debugPrint('📋 Fetching time entries for taskId: $taskId, userId: $userId, from: $startDateStr to: $endDateStr');

      final queryParameters = <String, dynamic>{};
      if (userId != null) queryParameters['userId'] = userId;
      if (startDateStr != null) queryParameters['startDate'] = startDateStr;
      if (endDateStr != null) queryParameters['endDate'] = endDateStr;

      final path = 'time_entry_management_application_function/timeentry/$taskId';
      final response = await _client.get(
        path,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      debugPrint('📋 Task Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Task Time Entry Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        debugPrint('📋 Full JSON Structure: $jsonData');

        final List<dynamic> data = jsonData['data'] ?? [];
        debugPrint('📋 Data array length: ${data.length}');

        if (data.isEmpty) {
          return [];
        }

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
      final startDateStr = startDate?.toString().split(' ')[0];
      final endDateStr = endDate?.toString().split(' ')[0];
      
      debugPrint('📋 Fetching time entries for projectId: $projectId, from: $startDateStr to: $endDateStr');
      
      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/time_entry/project/$projectId';
      final response = await _client.get(
        path,
        queryParameters: startDateStr != null && endDateStr != null
            ? {'startDate': startDateStr, 'endDate': endDateStr}
            : null,
      );

      debugPrint('📋 Project Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Project Time Entry Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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
      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/time_entry/project/$projectId';
      final response = await _client.get(path);

      debugPrint('📋 Project Time Entry Response: ${response.statusCode}');
      debugPrint('📋 Project Time Entry Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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
      final startDateStr = startDate.toString().split(' ')[0];
      final endDateStr = endDate.toString().split(' ')[0];

      debugPrint(
          '📋 Fetching user time entries - userId: $userId, from: $startDateStr to: $endDateStr');

      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/user-timeentry';
      final response = await _client.get(
        path,
        queryParameters: {'userId': userId, 'startDate': startDateStr, 'endDate': endDateStr},
      );

      debugPrint('📋 User Time Entry Response: ${response.statusCode}');
      debugPrint('📋 User Time Entry Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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

      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/timeentry';
      final response = await _client.post(path, data: body);

      debugPrint('Create Time Entry Response: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = response.data as Map<String, dynamic>;
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

      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/timeentry/$timeEntryId';
      final response = await _client.post(path, data: body);

      debugPrint('✏️ Update Time Entry Response: ${response.statusCode}');
      debugPrint('✏️ Update Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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
      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/timeentry/$timeEntryId';
      final response = await _client.delete(path);

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

      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/timeentry/approval/$userId';
      final response = await _client.post(path, data: body);

      debugPrint('✅ Create Approval Response: ${response.statusCode}');
      debugPrint('✅ Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
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

      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/timeentry/approval';
      final response = await _client.post(path, data: body);

      debugPrint('✅ Approval Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
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
      // Relative path — base URL and token handled by ApiClient.
      final path = 'time_entry_management_application_function/timeentry/approval/$userId';
      final response = await _client.get(path);

      debugPrint('✅ User Approvals Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
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
      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/timeentry/approval';
      final response = await _client.get(path, queryParameters: {'managerId': managerId});

      debugPrint('✅ Team Approvals Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        return jsonData['data'] ?? [];
      } else {
        throw Exception('Failed to fetch team approvals: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching team approvals: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkTimerStatus(String userId) =>
      CheckTimerStatusRepository().checkTimerStatus(userId);
}
