import 'dart:async';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/attendance_detail.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_logs_repository.g.dart';

@riverpod
class TimeLogsRepository extends _$TimeLogsRepository {
  @override
  Future<List<AttendanceDetail>> build({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    return fetchTimeLogs(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<AttendanceDetail>> fetchTimeLogs({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await DioClient.instance.post(
        'time_entry_management_application_function/attendance/dashboard?Start_date=$startDate&End_date=$endDate',
        data: {"UserID": userId},
      );
      debugPrint("Response From fetchTimeLogs: $response");

      final data = response.data;
      final List<dynamic> list = data["data"] ?? [];
      final timeLogs = list.map((e) => AttendanceDetail.fromJson(e)).toList();

      return timeLogs;
    } catch (e, st) {
      debugPrint("Error fetching Time Logs: $e");
      throw AsyncError(e, st);
    }
  }
}
