import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateBadgeRepositoryProvider = Provider<UpdateBadgeRepository>((ref) {
  return UpdateBadgeRepository();
});

class UpdateBadgeRepository {
  Future<void> updateBadge({
    required String rowId,
    required Map<String, dynamic> body,
  }) async {
    await ApiClient.instance.put(
      'time_entry_management_application_function/badge/$rowId',
      data: body,
    );
  }
}
