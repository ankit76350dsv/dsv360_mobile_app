import 'dart:async';

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsSearchQueryProvider = StateProvider<String>((ref) => '');

class AccountsListRepository extends AsyncNotifier<List<Account>> {
  @override
  FutureOr<List<Account>> build() async {
    return await fetchAccountsList(isInitial: true);
  }

  Future<List<Account>> fetchAccountsList({bool isInitial = false}) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/clientOrg',
      );
      debugPrint('Response From fetchAccounts: $response');

      final data = response.data;
      final List<dynamic> list = data['data'] ?? [];

      final accounts = list
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();

      return accounts;
    } catch (e, st) {
      debugPrint('Error fetching accounts: $e');
      throw AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchAccountsList);
  }
}

final accountsListRepositoryProvider =
  AsyncNotifierProvider<AccountsListRepository, List<Account>>(
    AccountsListRepository.new,
);
