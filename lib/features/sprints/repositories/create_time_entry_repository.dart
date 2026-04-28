import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createTimeEntryRepositoryProvider =
    Provider<CreateTimeEntryRepository>((ref) {
  return CreateTimeEntryRepository();
});

class CreateTimeEntryRepository {
  /// POST time_entry_management_application_function/timeentry
  Future<TimeEntry> createTimeEntry({
    required String taskId,
    required String taskName,
    required String storyId,
    required String sprintId,
    required String projectId,
    required String projectName,
    required String userId,
    required String username,
    required String entryDate,   // yyyy-MM-dd
    required String startTime,   // h:mm AM/PM
    required String endTime,     // h:mm AM/PM
    required int totalMinutes,
    required String type,        // "Billable" or "Non-Billable"
    required String note,
    String sourceType = 'SPRINT_TASK',
    String? subTaskId,
  }) async {
    final payload = {
      'Sprint_Task_ID': taskId,
      'Task_ID': taskId,
      'Task_Name': taskName,
      'Story_ID': storyId,
      'Sprint_ID': sprintId,
      'Project_ID': projectId,
      'Project_Name': projectName,
      'User_ID': userId,
      'Username': username,
      'Entry_Date': entryDate,
      'Start_time': startTime,
      'End_time': endTime,
      'Total_time': totalMinutes,
      'Type': type,
      'Note': note,
      'Source_Type': sourceType,
    };

    // Add subTaskId to payload if present (for SPRINT_SUBTASK source type)
    if (subTaskId != null && subTaskId.isNotEmpty) {
      payload['Sprint_SubTask_ID'] = subTaskId;
    }

    final response = await ApiClient.instance.post(
      'time_entry_management_application_function/timeentry',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data['data'] != null) {
      return TimeEntry.fromJson(Map<String, dynamic>.from(data['data']));
    }
    throw Exception(
        (data is Map ? data['message'] : null) ?? 'Failed to create time entry');
  }
}
