import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientContactsRepository extends AsyncNotifier<List<ClientContacts>> {
  @override
  Future<List<ClientContacts>> build() async {
    return fetchClientContactsList(isInitial: true) ?? [];
  }

  Future<List<ClientContacts>> fetchClientContactsList({
    bool isInitial = false,
  }) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/contact',
      );
      debugPrint("Response From fetchClientContactsList: $response");

      final data = response.data;
      final List<dynamic> list = data["data"];
      final clientContactsList = list
          .map((e) => ClientContacts.fromJson(e))
          .toList();

      return clientContactsList;
    } catch (e, st) {
      debugPrint("Error fetching fetchClientContactsList: $e");
      throw AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchClientContactsList);
  }
}

final clientContactsListRepositoryProvider =
    AsyncNotifierProvider<ClientContactsRepository, List<ClientContacts>>(
      ClientContactsRepository.new,
    );

final clientContactsSearchQueryProvider = StateProvider<String>((ref) => '');
