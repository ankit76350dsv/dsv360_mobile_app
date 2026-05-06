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
    final payload = <String, dynamic>{
      'Entry_Date': entryDate,
      'Project_ID': projectId,
      'Project_Name': projectName,
      'Source_Type': sourceType,
      'Sprint_ID': sprintId,
      'Sprint_Task_ID': sprintTaskId,
      'Story_ID': storyId,
      'Task_ID': taskId,
      'Task_Name': taskName,
      'User_ID': userId,
      'Username': username,
    };

    if (sprintSubTaskId != null && sprintSubTaskId.isNotEmpty) {
      payload['Sprint_SubTask_ID'] = sprintSubTaskId;
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
    throw Exception((data is Map ? data['message'] : null) ?? 'Failed to start timer');
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
    throw Exception((data is Map ? data['message'] : null) ?? 'Failed to stop timer');
  }

  Future<TimerInfoModel?> getTimerInfo({required String userId}) async {
    debugPrint('⏱️ Fetching timer info for user: $userId');

    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/timeentry/timer',
      queryParameters: {'User_ID': userId},
    );

    final data = response.data;
    if (data is Map) return TimerInfoModel.fromJson(Map<String, dynamic>.from(data));
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
    final start = startDate ??
        DateTime(now.year - 1, now.month, now.day).toIso8601String().split('T').first;
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
        if (raw is Map) entries.add(TimeEntry.fromJson(Map<String, dynamic>.from(raw)));
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
    throw Exception((data is Map ? data['message'] : null) ?? 'Failed to create time entry');
  }
}

class StartTimerRepository extends TimerRepository {}
