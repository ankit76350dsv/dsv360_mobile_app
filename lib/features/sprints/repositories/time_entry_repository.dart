import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sprintTimeEntryRepositoryProvider =
    Provider<SprintTimeEntryRepository>((ref) {
  return SprintTimeEntryRepository();
});

class SprintTimeEntryRepository {
  /// Fetch time entries for a sprint task.
  /// API: GET time_entry_management_application_function/timeentry/{taskId}
  ///      ?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD&source=sprint
  Future<List<TimeEntry>> fetchTimeEntriesForTask({
    required String taskId,
    String? startDate,
    String? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ??
        DateTime(now.year - 1, now.month, now.day)
            .toIso8601String()
            .split('T')
            .first;
    final end =
        endDate ?? now.toIso8601String().split('T').first;

    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/timeentry/$taskId',
      queryParameters: {
        'startDate': start,
        'endDate': end,
        'source': 'sprint',
      },
    );

    final data = response.data;
    if (data is! Map || data['data'] is! List) return [];

    final List<TimeEntry> entries = [];
    for (final dayGroup in data['data'] as List) {
      final details = dayGroup['details'];
      if (details is! List) continue;
      for (final detail in details) {
        final raw = detail['Time_Entries'];
        if (raw is Map) {
          entries.add(
              TimeEntry.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
    }
    return entries;
  }
}
