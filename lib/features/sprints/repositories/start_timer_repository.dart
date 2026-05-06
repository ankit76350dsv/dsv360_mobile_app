import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startTimerRepositoryProvider = Provider<StartTimerRepository>((ref) {
  return StartTimerRepository();
});

class StartTimerResult {
  final String rowId;
  final String startTime;

  const StartTimerResult({required this.rowId, required this.startTime});
}

class StartTimerRepository {
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

    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to start timer',
    );
  }
}
