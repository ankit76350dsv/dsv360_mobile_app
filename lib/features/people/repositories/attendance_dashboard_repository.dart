import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/people/model/attendance_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceDashboardRepositoryProvider =
    Provider<AttendanceDashboardRepository>((ref) {
  return AttendanceDashboardRepository();
});

class AttendanceDashboardRepository {
  Future<AttendanceDashboardResponse> fetchAttendanceDashboard({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        'time_entry_management_application_function/attendance/dashboard?Start_date=$startDate&End_date=$endDate',
        data: {"UserID": userId},
      );

      return AttendanceDashboardResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }
}