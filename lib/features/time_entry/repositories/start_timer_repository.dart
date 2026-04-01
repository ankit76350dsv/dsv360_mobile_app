import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart';

class StartTimerRepository {
  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> startTimer({
    required String userId,
    required String username,
    required String taskId,
    required String taskName,
    required String projectId,
    required String projectName,
    required DateTime entryDate,
  }) async {
    try {
      debugPrint('⏱️ Starting timer - userId: $userId, taskId: $taskId');
      final entryDateStr =
          '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}';
      final body = {
        'User_ID': userId,
        'Username': username,
        'Task_ID': taskId,
        'Task_Name': taskName,
        'Project_ID': projectId,
        'Project_Name': projectName,
        'Entry_Date': entryDateStr,
      };
      const path = 'time_entry_management_application_function/timeentry/timer/start';
      final response = await _client.post(path, data: body);
      debugPrint('⏱️ Start Timer Response: ${response.statusCode}');
      debugPrint('⏱️ Start Timer Data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to start timer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error starting timer: $e');
      rethrow;
    }
  }
}