import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/attendance_detail.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_tracker_list.g.dart';

@riverpod
class AttendanceTrackerListRepository
    extends _$AttendanceTrackerListRepository {
  @override
  Future<List<AttendanceDetail>> build({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    return fetchAttendance(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<AttendanceDetail>> fetchAttendance({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/attendance/dashboard?Start_date=$startDate&End_date=$endDate',
        data: {"UserID": userId},
      );
      debugPrint("Response From fetchAttendance: $response");

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final attendanceList = list
          .map((e) => AttendanceDetail.fromJson(e))
          .toList();

      return attendanceList;
    } catch (e, st) {
      debugPrint(
        "Error fetching Attendance Tracker: $e"
      );
      throw AsyncError(e, st);
    }
  }
}
