import 'package:dsv360/features/worklogs/model/worklog_model.dart';
import 'package:dsv360/features/worklogs/repositories/get_time_logs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final worklogsViewModelProvider = Provider<WorklogsViewModel>((ref) {
  return WorklogsViewModel(ref.read(getTimeLogsRepositoryProvider));
});

class WorklogsViewModel {
  WorklogsViewModel(this._repository);
  final GetTimeLogsRepository _repository;

  Future<List<WorklogDaySummary>> fetchTimeline({
    required String userId,
    required String startDate,
    required String endDate,
  }) {
    return _repository.fetchUserTimeline(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
