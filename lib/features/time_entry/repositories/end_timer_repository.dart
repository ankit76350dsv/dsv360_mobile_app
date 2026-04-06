import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart';

class EndTimerRepository {
  final _client = ApiClient.instance;
  /// End/Stop timer
  Future<Map<String, dynamic>> endTimer({
    
    required String rowId,
    required String note,
    required String type,


  }) async {
    try {
      debugPrint('⏱️ Stopping timer - timerId: $rowId');
      final body = {
        
        'ROWID': rowId,
        'Note': note,
        'Type': type,
      };
      
      debugPrint("BODY AREA");
      debugPrint(body.toString());

      // Relative path — base URL and token handled by ApiClient.
      const path = 'time_entry_management_application_function/timeentry/timer/end';
      final response = await _client.post(path, data: body);

      debugPrint('⏱️ End Timer Response: ${response.statusCode}');
      debugPrint('⏱️ End Timer Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to end timer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error ending timer: $e');
      rethrow;
    }
  }
}