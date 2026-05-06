import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stopTimerRepositoryProvider = Provider<StopTimerRepository>((ref) {
  return StopTimerRepository();
});

class StopTimerRepository {
  Future<void> stopTimer({
    required String rowId,
    required String note,
    required String type,
  }) async {
    final payload = {
      'ROWID': rowId,
      'Note': note,
      'Type': type,
    };

    debugPrint('⏹️ Stopping timer: $payload');

    final response = await ApiClient.instance.post(
      'time_entry_management_application_function/timeentry/timer/end',
      data: payload,
    );

    final data = response.data;
    if (data is Map && data['success'] == true) return;

    throw Exception(
      (data is Map ? data['message'] : null) ?? 'Failed to stop timer',
    );
  }
}
