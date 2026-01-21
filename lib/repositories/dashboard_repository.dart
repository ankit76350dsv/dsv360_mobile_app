import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dsv360/core/constants/server_constant.dart';
import 'package:dsv360/models/dashboard_model.dart';

class DashboardRepository {
  Future<DashboardModel> fetchDashboardData({
    required String userId,
    required String orgId,
    required String year,
  }) async {
    final url = Uri.parse(
      '${ServerConstant.serverURL}time_entry_management_application_function/mobile/dashboard',
    ).replace(queryParameters: {
      'User_Id': userId,
      'Org_Id': orgId,
      'Year': year,
    });

    // debugPrint('🩸 Fetching dashboard data | URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return DashboardModel.fromJson(jsonResponse);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception(
            'Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}
