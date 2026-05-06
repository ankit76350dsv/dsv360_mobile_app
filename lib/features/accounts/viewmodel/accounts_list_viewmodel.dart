import 'dart:async';

import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:dsv360/features/accounts/repositories/account_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class AccountsListRepository extends AsyncNotifier<List<Account>> {
  @override
  FutureOr<List<Account>> build() async {
    return ref.read(fetchAccountsRepositoryProvider).fetchAllAccounts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(fetchAccountsRepositoryProvider).fetchAllAccounts(),
    );
  }
}

final accountsListRepositoryProvider =
    AsyncNotifierProvider<AccountsListRepository, List<Account>>(
  AccountsListRepository.new,
);
