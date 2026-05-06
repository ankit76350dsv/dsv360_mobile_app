import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/worklogs/model/worklog_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTimeLogsRepositoryProvider = Provider<GetTimeLogsRepository>((ref) {
  return GetTimeLogsRepository();
});

class GetTimeLogsRepository {
  Future<List<WorklogDaySummary>> fetchUserTimeline({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/user-timeline',
      queryParameters: {
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    final data = response.data;
    if (data is! Map || data['data'] is! List) return [];

    return (data['data'] as List)
        .whereType<Map>()
        .map((e) => WorklogDaySummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
