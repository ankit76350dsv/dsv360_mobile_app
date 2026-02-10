import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/utils/functions.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  @override
  FutureOr<List<UsersModel>> build() async {
    final activeUser = ref.watch(activeUserRepositoryProvider);

    // Check if user is admin
    // if (activeUser != null && Functions.isAdmin(activeUser)) {
    //   return await fetchUsersBatchProfile();
    // }

    return await fetchUsers();
  }

  Future<List<UsersModel>> fetchUsers() async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/employee',
      );
      debugPrint("Response From fetchUsers: $response");

      final data = response.data;
      final List<dynamic> list = data["users"];
      final usersList = list.map((e) => UsersModel.fromJson(e)).toList();

      return usersList;
    } catch (e, st) {
      developer.log("Error fetching users: $e", name: "UsersRepository");
      throw AsyncError(e, st);
    }
  }

  Future<List<UsersModel>> fetchUsersBatchProfile() async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/employee',
      );
      debugPrint("Response From fetchUsers: $response");

      final data = response.data;
      final list = data["users"];

      // Send the list to batchProfile to get full details
      final batchResponse = await DioClient.instance.post(
        'time_entry_management_application_function/batchProfile',
        data: list,
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
