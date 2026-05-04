import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fetchAccountsRepositoryProvider = Provider<FetchAccountsRepository>((ref) {
  return FetchAccountsRepository();
});

class FetchAccountsRepository {
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
}
