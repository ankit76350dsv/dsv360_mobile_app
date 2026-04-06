import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart';

class RequestEntryRepository {
  final _client = ApiClient.instance;

  /// Create bulk approval request.
  /// All nullable fields default to empty string so the payload matches
  /// the API spec exactly (no Dart nulls in the JSON body).
  Future<Map<String, dynamic>> createRequestEntry({
    required String projectId,
    required String projectName,
    required String taskId,
    required String taskName,
    required String timeentryData, // JSON-encoded string
    required String userId,
    required String username,
    String approveByID = '',
    String approveDate = '',
    String approvedBy = '',
    String reason = '',
    bool rejected = false,
    String status = 'Pending',
  }) async {
    try {
      debugPrint('📤 Creating Bulk Approval Request');

      final body = {
        'ApproveByID': approveByID,
        'ApproveDate': approveDate,
        'ApprovedBy': approvedBy,
        'Project_ID': projectId,
        'Project_Name': projectName,
        'Reason': reason,
        'Rejected': rejected,
        'Status': status,
        'Task_Id': taskId,
        'Task_Name': taskName,
        'Timeentry_Data': timeentryData,
        'User_Id': userId,
        'Username': username,
      };

      debugPrint('📦 BULK APPROVAL BODY: $body');

      const path =
          'time_entry_management_application_function/timeentry/approval/bulk';

      final response = await _client.post(path, data: body);

      debugPrint('📥 Response Code: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to create bulk approval: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in bulk approval: $e');
      rethrow;
    }
  }
}