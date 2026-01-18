import 'dart:async';

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsListRepositoryProvider =
    Provider<AsyncValue<List<Account>>>((ref) {
  final accountsList = <Account>[
    Account.fromJson({
      "CREATORID": "17682000000045367",
      "Org_Name": "Test Corp",
      "Status": "Active",
      "MODIFIEDTIME": "2026-01-02 16:56:26:502",
      "Email": "test@gmail.com",
      "Org_Img": "",
      "Website": "testcorp.com",
      "CREATEDTIME": "2026-01-02 16:56:26:502",
      "Org_Type": "Startup",
      "ROWID": "17682000000605001",
    }),
    Account.fromJson({
      "CREATORID": "17682000000045368",
      "Org_Name": "Blue Tech",
      "Status": "Inactive",
      "MODIFIEDTIME": "2026-01-01 11:20:10:112",
      "Email": "info@bluetech.com",
      "Org_Img": "",
      "Website": "bluetech.io",
      "CREATEDTIME": "2025-12-20 09:10:45:890",
      "Org_Type": "Enterprise",
      "ROWID": "17682000000605002",
    }),
    Account.fromJson({
      "CREATORID": "17682000000045369",
      "Org_Name": "Green Solutions",
      "Status": "Active",
      "MODIFIEDTIME": "2025-12-30 18:45:02:330",
      "Email": "contact@greensolutions.com",
      "Org_Img": "",
      "Website": "greensolutions.org",
      "CREATEDTIME": "2025-12-10 14:32:18:654",
      "Org_Type": "Startup",
      "ROWID": "17682000000605003",
    }),
    Account.fromJson({
      "CREATORID": "17682000000045370",
      "Org_Name": "NextGen Labs",
      "Status": "Active",
      "MODIFIEDTIME": "2026-01-03 10:05:55:777",
      "Email": "hello@nextgenlabs.ai",
      "Org_Img": "",
      "Website": "nextgenlabs.ai",
      "CREATEDTIME": "2025-11-25 08:40:00:120",
      "Org_Type": "Product",
      "ROWID": "17682000000605004",
    }),
  ];

  return AsyncValue.data(accountsList);
});


final accountsSearchQueryProvider = StateProvider<String>((ref) => '');

class AccountsListRepository extends AsyncNotifier<List<Account>>{
  @override
  FutureOr<List<Account>> build() async{
    return await fetchAccountsList();
  }

  Future<List<Account>> fetchAccountsList() async {
    try{
      final response = await DioClient.instance.get('/server/time_entry_management_application_function/clientOrg');
      debugPrint("Response From Accounts List: ${response.data["success"]}");

      if (response.data["success"] != true) {
        throw Exception("API returned success=false");
      }

      final List list = response.data["data"];

      return list
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    
    }catch (e, st){
      debugPrint('Error fetching accounts: $e');
      throw AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchAccountsList);
  }
}

// final accountsListRepositoryProvider =
//   AsyncNotifierProvider<AccountsListRepository, List<Account>>(
//     AccountsListRepository.new,
// );
