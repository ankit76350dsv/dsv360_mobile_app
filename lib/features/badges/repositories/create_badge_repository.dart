import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createBadgeRepositoryProvider = Provider<CreateBadgeRepository>((ref) {
  return CreateBadgeRepository();
});

class CreateBadgeRepository {
  Future<void> createBadge(Map<String, dynamic> body) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/badge',
      data: body,
    );
  }
}
