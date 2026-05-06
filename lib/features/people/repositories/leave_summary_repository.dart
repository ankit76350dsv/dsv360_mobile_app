import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/people/model/leave_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveSummaryRepository
    extends AutoDisposeFamilyAsyncNotifier<LeaveSummary, ({String userId, String username})> {
  @override
  Future<LeaveSummary> build(({String userId, String username}) arg) async {
    return _fetch(userId: arg.userId, username: arg.username);
  }

  Future<LeaveSummary> _fetch({
    required String userId,
    required String username,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        'time_entry_management_application_function/leave/count',
        queryParameters: {'UserID': userId, 'Username': username},
      );

      debugPrint("Response From fetchLeaveSummary: ${response.data}");

      final summaryData = (response.data["data"] as Map<String, dynamic>?) ?? {};
      return LeaveSummary.fromJson(summaryData);
    } catch (e, st) {
      debugPrint("Error fetching Leave Summary: $e");
      throw AsyncError(e, st);
    }
  }
}

final leaveSummaryRepositoryProvider = AsyncNotifierProvider.autoDispose
    .family<LeaveSummaryRepository, LeaveSummary, ({String userId, String username})>(
  LeaveSummaryRepository.new,
);
