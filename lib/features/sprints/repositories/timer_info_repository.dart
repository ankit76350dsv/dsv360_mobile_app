import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/sprints/model/timer_info_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerInfoRepositoryProvider = Provider<TimerInfoRepository>((ref) {
  return TimerInfoRepository();
});

class TimerInfoRepository {
  Future<TimerInfoModel?> getTimerInfo({required String userId}) async {
    final queryParams = {'User_ID': userId};

    debugPrint('⏱️ Fetching timer info for user: $userId');

    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/timeentry/timer',
      queryParameters: queryParams,
    );

    final data = response.data;

    if (data is Map) {
      return TimerInfoModel.fromJson(Map<String, dynamic>.from(data));
    }

    return null;
  }

  Stream<TimerInfoModel?> watchTimerInfo({
    required String userId,
    Duration interval = const Duration(seconds: 10),
  }) async* {
    while (true) {
      try {
        yield await getTimerInfo(userId: userId);
      } catch (e) {
        debugPrint('⏱️ Error polling timer info: $e');
        yield null;
      }
      await Future.delayed(interval);
    }
  }
}
