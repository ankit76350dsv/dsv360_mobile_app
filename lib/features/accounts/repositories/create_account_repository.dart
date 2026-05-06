import 'package:dsv360/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createAccountRepositoryProvider = Provider<CreateAccountRepository>((ref) {
  return CreateAccountRepository();
});

class CreateAccountRepository {
  Future<void> createAccount(Map<String, dynamic> body) async {
    try {
      await ApiClient.instance.post(
        'time_entry_management_application_function/clientOrg',
        data: body,
      );
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('404') && !msg.contains('not found')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/createClient',
        data: body,
      );
    }
  }
}
