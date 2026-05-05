
import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/material.dart';

class CheckTimerStatusRepository {
  final _client = ApiClient.instance;
   /// Check if timer is running for user
  Future<Map<String, dynamic>> checkTimerStatus(String userId) async {
    try {
      debugPrint('⏱️ Checking timer status for userId: $userId');
      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/timeentry/timer';
      final response = await _client.get(path, queryParameters: {'User_ID': userId});

      debugPrint('⏱️ Timer Status Response: ${response.statusCode}');
      debugPrint('⏱️ Timer Status Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check timer status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error checking timer status: $e');
      rethrow;
    }
  }
}