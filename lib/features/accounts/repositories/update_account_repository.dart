import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateAccountRepositoryProvider = Provider<UpdateAccountRepository>((ref) {
  return UpdateAccountRepository();
});

class UpdateAccountRepository {
  Future<void> updateAccount({
    required String rowId,
    required Map<String, dynamic> body,
  }) async {
    try {
      await ApiClient.instance.put(
        'time_entry_management_application_function/clientOrg/$rowId',
        data: body,
      );
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('404') && !msg.contains('not found')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateClient/$rowId',
        data: body,
      );
    }
  }
}
