import 'package:dsv360/models/time_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timeLogsRepositoryProvider = Provider<AsyncValue<List<TimeLogs>>>((ref) {
  // Simulate API data
  final timeLogs = <TimeLogs>[
    TimeLogs.fromJson({
      'Day_Date': '2025-12-31',
      'Username': 'Aman Jain',
      'Check_In': '2025-12-31 20:21:38',
      'Check_Out': '2025-12-31 20:21:39',
      'Total_Time': '0',
    }),
    TimeLogs.fromJson({
      'Day_Date': '2025-12-31',
      'Username': 'Aman Jain',
      'Check_In': '2025-12-31 20:21:41',
      'Check_Out': '2025-12-31 20:21:44',
      'Total_Time': '0',
    }),
  ];

  return AsyncValue.data(timeLogs);
});

class TimeLogsRepository extends AsyncNotifier<List<TimeLogs>> {
  @override
  Future<List<TimeLogs>> build() async {
    return fetchTimeLogs(isInitial: true) ?? [];
  }

  Future<List<TimeLogs>> fetchTimeLogs({bool isInitial = false}) async {
    return [];
  }
}

// final timeLogsRepositoryProvider = AsyncNotifierProvider<TimeLogsRepository, List<TimeLogs>>(
//   TimeLogsRepository.new,
// );
