import 'package:flutter/foundation.dart';
import 'package:dsv360/core/network/dio_client.dart';// single import — no raw Dio needed
import 'package:dsv360/models/dashboard_model.dart';

// ---------------------------------------------------------------------------
// How this repository uses ApiClient:
//   - ApiClient.instance is the shared singleton defined in api_client.dart.
//   - The base URL and Authorization header are handled inside ApiClient,
//     so this file only passes the relative path and query parameters.
// ---------------------------------------------------------------------------

class DashboardRepository {

  // Use the centralized client — no manual Dio, no manual token injection.
  final _client = ApiClient.instance;

  Future<DashboardModel> fetchDashboardData({
    required String userId,
    required String orgId,
    required String year,
  }) async {
    //full url : '${ServerConstant.serverURL}time_entry_management_application_function/mobile/dashboard';

    // Relative path — base URL is already set inside ApiClient.
    const path = 'time_entry_management_application_function/mobile/dashboard';

    try {
      final response = await _client.get(
        path,
        queryParameters: {
          'User_Id': userId,
          'Org_Id': orgId,
          'Year': year,
        },
      );

      final Map<String, dynamic> jsonResponse = response.data;

      if (jsonResponse['success'] == true) {
        debugPrint('📋 yearTaskData raw from API: ${jsonResponse['yearTaskData']}');
        return DashboardModel.fromJson(jsonResponse);
      } else {
        throw Exception('API returned success: false');
      }

    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}