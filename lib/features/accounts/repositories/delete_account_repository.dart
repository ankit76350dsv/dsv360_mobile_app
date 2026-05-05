import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountRepositoryProvider = Provider<DeleteAccountRepository>((ref) {
  return DeleteAccountRepository();
});

class DeleteAccountRepository {
  Future<void> deleteAccount({required String rowId}) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/org/$rowId',
    );
  }
}
