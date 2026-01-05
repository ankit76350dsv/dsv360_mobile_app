import 'package:dsv360/models/attendance_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceDetailListRepository
    extends AsyncNotifier<List<AttendanceDetail>> {
  @override
  Future<List<AttendanceDetail>> build() async {
    return fetchAttendanceDetail(isInitial: true) ?? [];
  }

  Future<List<AttendanceDetail>> fetchAttendanceDetail({
    bool isInitial = false,
  }) async {
    return [];
  }
}

final attendanceDetailListRepositoryProvider =
    Provider<AsyncValue<List<AttendanceDetail>>>((ref) {
      // Simulate API data
      final List<AttendanceDetail> attendanceList = [
        AttendanceDetail.fromJson({
          "Day_Date": "2025-12-26",
          "Username": "Aman Jain",
          "Check_In": "2025-12-26 09:15:12",
          "Check_Out": "2025-12-26 18:05:30",
          "Total_Time": "8h 50m",
        }),
        AttendanceDetail.fromJson({
          "Day_Date": "2025-12-25",
          "Username": "Aman Jain",
          "Check_In": "2025-12-25 09:22:10",
          "Check_Out": "2025-12-25 17:48:00",
          "Total_Time": "8h 26m",
        }),
        AttendanceDetail.fromJson({
          "Day_Date": "2025-12-24",
          "Username": "Aman Jain",
          "Check_In": "2025-12-24 09:10:45",
          "Check_Out": "2025-12-24 18:02:18",
          "Total_Time": "8h 51m",
        }),
        AttendanceDetail.fromJson({
          "Day_Date": "2025-12-23",
          "Username": "Aman Jain",
          "Check_In": "2025-12-23 09:30:00",
          "Check_Out": null,
          "Total_Time": null,
        }),
        AttendanceDetail.fromJson({
          "Day_Date": "2025-12-22",
          "Username": "Aman Jain",
          "Check_In": "2025-12-22 09:18:35",
          "Check_Out": "2025-12-22 17:55:10",
          "Total_Time": "8h 36m",
        }),
      ];

      return AsyncValue.data(attendanceList);
    });


// final attendanceDetailListRepositoryProvider = AsyncNotifierProvider<AttendanceDetailListRepository, List<AttendanceDetail>>(
//   AttendanceDetailListRepository.new,
// );