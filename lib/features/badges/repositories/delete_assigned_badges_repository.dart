import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAssignedBadgesRepositoryProvider = Provider<DeleteAssignedBadgesRepository>((ref) {
  return DeleteAssignedBadgesRepository();
});

class DeleteAssignedBadgesRepository {
  Future<void> deleteAssignedBadges(List<String> rowIds) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/assignBadge',
      data: {'rowIDs': rowIds},
    );
  }
}
