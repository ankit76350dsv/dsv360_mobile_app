import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart';

class RequestEntryRepository {
  final _client = ApiClient.instance;

  /// Create bulk approval request
  Future<Map<String, dynamic>> createRequestEntry({
    required String projectId,
    required String projectName,
    required String taskId,
    required String taskName,
    required String timeentryData, // JSON string
    required String userId,
    required String username,

    String? approveByID,
    String? approveDate,
    String? approvedBy,
    String? reason,
    bool rejected = false,
    String status = "Pending",
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

      debugPrint("📦 BULK APPROVAL BODY:");
      debugPrint(body.toString());

      const path =
          'time_entry_management_application_function/timeentry/approval/bulk';

      final response = await _client.post(path, data: body);

      debugPrint('📥 Bulk Approval Response Code: ${response.statusCode}');
      debugPrint('📥 Bulk Approval Response Data: ${response.data}');

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