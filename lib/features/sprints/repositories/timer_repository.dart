import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/timer_info_model.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:flutter/foundation.dart';

class StartTimerResult {
  final String rowId;
  final String startTime;
  const StartTimerResult({required this.rowId, required this.startTime});
}

class TimerRepository {
  String _normalizeId(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') return '';
    return normalized;
  }

  Future<StartTimerResult> startTimer({
    required String entryDate,
    required String projectId,
    required String projectName,
    required String sourceType,
    required String sprintId,
    required String sprintTaskId,
    required String storyId,
    required String taskId,
    required String taskName,
    required String userId,
    required String username,
    String? sprintSubTaskId,
  }) async {
    final normalizedEntryDate = _normalizeId(entryDate);
    final normalizedProjectId = _normalizeId(projectId);
    final normalizedProjectName = projectName.trim();
    final normalizedSourceType = sourceType.trim();
    final normalizedSprintId = _normalizeId(sprintId);
    final normalizedSprintTaskId = _normalizeId(sprintTaskId);
    final normalizedStoryId = _normalizeId(storyId);
    final normalizedTaskId = _normalizeId(taskId);
    final normalizedTaskName = taskName.trim();
    final normalizedUserId = _normalizeId(userId);
    final normalizedUsername = username.trim();
    final normalizedSprintSubTaskId = _normalizeId(sprintSubTaskId);

    final missingFields = <String>[];
    if (normalizedEntryDate.isEmpty) missingFields.add('Entry_Date');
    if (normalizedProjectId.isEmpty) missingFields.add('Project_ID');
    if (normalizedSprintId.isEmpty) missingFields.add('Sprint_ID');
    if (normalizedSprintTaskId.isEmpty) missingFields.add('Sprint_Task_ID');
    if (normalizedStoryId.isEmpty) missingFields.add('Story_ID');
    if (normalizedTaskId.isEmpty) missingFields.add('Task_ID');
    if (normalizedTaskName.isEmpty) missingFields.add('Task_Name');
    if (normalizedUserId.isEmpty) missingFields.add('User_ID');
    if (normalizedUsername.isEmpty) missingFields.add('Username');

    if (missingFields.isNotEmpty) {
      throw Exception(
        'Missing required timer fields: ${missingFields.join(', ')}',
      );
    }

    final payload = <String, dynamic>{
      'Entry_Date': normalizedEntryDate,
      'Project_ID': normalizedProjectId,
      'Project_Name': normalizedProjectName,
      'Source_Type': normalizedSourceType,
      'Sprint_ID': normalizedSprintId,
      'Sprint_Task_ID': normalizedSprintTaskId,
      'Story_ID': normalizedStoryId,
      'Task_ID': normalizedTaskId,
      'Task_Name': normalizedTaskName,
      'User_ID': normalizedUserId,
      'Username': normalizedUsername,
    };

    if (normalizedSprintSubTaskId.isNotEmpty) {
      payload['Sprint_SubTask_ID'] = normalizedSprintSubTaskId;
    }

    debugPrint('⏱️ Starting timer payload: $payload');

    final response = await ApiClient.instance.post(
      'time_entry_management_application_function/timeentry/timer/start',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data['data'] != null) {
      final timerData = data['data'] as Map;
      return StartTimerResult(
        rowId: timerData['ROWID']?.toString() ?? '',
        startTime: timerData['Start_time']?.toString() ?? '',
      );
    }
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to start timer',
    );
  }

  Future<void> stopTimer({
    required String rowId,
    required String note,
    required String type,
  }) async {
    final payload = {'ROWID': rowId, 'Note': note, 'Type': type};
    debugPrint('⏹️ Stopping timer: $payload');

    final response = await ApiClient.instance.post(
      'time_entry_management_application_function/timeentry/timer/end',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;
    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to stop timer',
    );
  }

  Future<TimerInfoModel?> getTimerInfo({required String userId}) async {
    debugPrint('⏱️ Fetching timer info for user: $userId');

    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/timeentry/timer',
      queryParameters: {'User_ID': userId},
    );

    final data = response.data;
    if (data is Map)
      return TimerInfoModel.fromJson(Map<String, dynamic>.from(data));
    return null;
  }

  Stream<TimerInfoModel?> watchTimerInfo({
    required String userId,
    Duration interval = const Duration(seconds: 10),
  }) async* {
    while (true) {
      try {
        yield await getTimerInfo(userId: userId);
      } catch (e) {
        debugPrint('⏱️ Error polling timer info: $e');
        yield null;
      }
      await Future.delayed(interval);
    }
  }

  Future<List<TimeEntry>> fetchTimeEntriesForTask({
    required String taskId,
    String? startDate,
    String? endDate,
  }) async {
    final now = DateTime.now();
    final start =
        startDate ??
        DateTime(
          now.year - 1,
          now.month,
          now.day,
        ).toIso8601String().split('T').first;
    final end = endDate ?? now.toIso8601String().split('T').first;

    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/timeentry/$taskId',
      queryParameters: {'startDate': start, 'endDate': end, 'source': 'sprint'},
    );

    final data = response.data;
    if (data is! Map || data['data'] is! List) return [];

    final List<TimeEntry> entries = [];
    for (final dayGroup in data['data'] as List) {
      final details = dayGroup['details'];
      if (details is! List) continue;
      for (final detail in details) {
        final raw = detail['Time_Entries'];
        if (raw is Map)
          entries.add(TimeEntry.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    return entries;
  }

  Future<TimeEntry> createTimeEntry({
    required String taskId,
    required String taskName,
    required String storyId,
    required String sprintId,
    required String projectId,
    required String projectName,
    required String userId,
    required String username,
    required String entryDate,
    required String startTime,
    required String endTime,
    required int totalMinutes,
    required String type,
    required String note,
    String sourceType = 'SPRINT_TASK',
    String? subTaskId,
  }) async {
    final payload = <String, dynamic>{
      'Sprint_Task_ID': _normalizeId(taskId),
      'Task_ID': _normalizeId(taskId),
      'Task_Name': taskName.trim(),
      'Story_ID': _normalizeId(storyId),
      'Sprint_ID': _normalizeId(sprintId),
      'Project_ID': _normalizeId(projectId),
      'Project_Name': projectName.trim(),
      'User_ID': _normalizeId(userId),
      'Username': username.trim(),
      'Entry_Date': _normalizeId(entryDate),
      'Start_time': startTime,
      'End_time': endTime,
      'Total_time': totalMinutes,
      'Type': type,
      'Note': note,
      'Source_Type': sourceType.trim(),
    };

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
      (data is Map ? data['message'] : null) ?? 'Failed to create time entry',
    );
  }
}

class StartTimerRepository extends TimerRepository {}
