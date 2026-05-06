import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteBadgeRepositoryProvider = Provider<DeleteBadgeRepository>((ref) {
  return DeleteBadgeRepository();
});

class DeleteBadgeRepository {
  Future<void> deleteBadge({required String deleteId}) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/badge/$deleteId',
    );
  }
}
