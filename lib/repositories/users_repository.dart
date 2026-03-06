import 'dart:async';
import 'dart:developer' as developer;

//import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  @override
  FutureOr<List<UsersModel>> build() async {
    return await fetchUsersBatchProfile();
  }

  Future<List<UsersModel>> fetchUsersBatchProfile() async {
    try {
      // Send the list to batchProfile to get full details
      final batchResponse = await DioClient.instance.post(
        'time_entry_management_application_function/batchProfile',
      );
      debugPrint("Batch Response: $batchResponse");

      final batchData = batchResponse.data;
      final usersJsonList = batchData["data"];

      if (usersJsonList is List) {
        final usersList = usersJsonList
            .map((e) => UsersModel.fromJson(e))
            .toList();

        return usersList;
      } else {
        developer.log("batchData is not list", name: "UsersRepository");
        return [];
      }
    } catch (e, st) {
      developer.log(
        "Error fetching users batch profile: $e",
        name: "UsersRepository",
      );
      throw AsyncError(e, st);
    }
  }
}

final usersRepositoryProvider =
    AsyncNotifierProvider<UsersRepository, List<UsersModel>>(
      UsersRepository.new,
    );

final usersSearchQueryProvider = StateProvider<String>((ref) => '');
