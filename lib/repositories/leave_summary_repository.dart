import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/leave_summary.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leave_summary_repository.g.dart';

@Riverpod(keepAlive: true)
class LeaveSummaryRepository extends _$LeaveSummaryRepository {
  @override
  Future<LeaveSummary> build({
    required String userId,
    required String username,
  }) async {
    return fetchLeaveSummary(userId: userId, username: username);
  }

  Future<LeaveSummary> fetchLeaveSummary({
    required String userId,
    required String username,
  }) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/leave/count',
        queryParameters: {'UserID': userId, 'Username': username},
      );

      debugPrint("Response From fetchLeaveSummary: ${response.data}");

      final data = response.data;
      final summaryData = data["data"] ?? {};

      return LeaveSummary.fromJson(summaryData);
    } catch (e, st) {
      debugPrint("Error fetching Leave Summary: $e");
      throw AsyncError(e, st);
    }
  }

  Future<void> refreshLeaveSummary() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => fetchLeaveSummary(userId: userId, username: username),
    );
  }
}
