import 'dart:async';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/attendance_detail.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_list_repository.g.dart';

@riverpod
class AttendanceDetailListRepository extends _$AttendanceDetailListRepository {
  @override
  Future<List<AttendanceDetail>> build({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    return fetchAttendanceDetail(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<AttendanceDetail>> fetchAttendanceDetail({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/attendance/dashboard?Start_date=$startDate&End_date=$endDate',
        data: {"UserID": userId},
      );

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final attendanceList = list
          .map((e) => AttendanceDetail.fromJson(e))
          .toList();

      return attendanceList;
    } catch (e, st) {
      debugPrint("Error fetching Attendance Detail: $e");
      throw AsyncError(e, st);
    }
  }
}
