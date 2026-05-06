import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

// Keep legacy provider aliases so existing consumers don't break.
final createAccountRepositoryProvider = Provider<AccountRepository>((ref) => ref.read(accountRepositoryProvider));
final updateAccountRepositoryProvider = Provider<AccountRepository>((ref) => ref.read(accountRepositoryProvider));
final deleteAccountRepositoryProvider = Provider<AccountRepository>((ref) => ref.read(accountRepositoryProvider));
final fetchAccountsRepositoryProvider = Provider<AccountRepository>((ref) => ref.read(accountRepositoryProvider));

class AccountRepository {
  Future<List<Account>> fetchAllAccounts() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/clientOrg',
    );

    final data = response.data;
    final List<dynamic> list = data['data'] ?? [];

    return list
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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

  Future<void> deleteAccount({required String rowId}) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/org/$rowId',
    );
  }
}
