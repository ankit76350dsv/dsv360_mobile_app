import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignBadgeRepositoryProvider = Provider<AssignBadgeRepository>((ref) {
  return AssignBadgeRepository();
});

class AssignBadgeRepository {
  Future<void> assignBadge(Map<String, dynamic> payload) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/assignBadge',
      data: payload,
    );
  }
}
