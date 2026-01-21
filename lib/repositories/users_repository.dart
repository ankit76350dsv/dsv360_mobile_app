import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  @override
  FutureOr<List<UsersModel>> build() async {
    return await fetchUsers(isInitial: true);
  }

  Future<List<UsersModel>> fetchUsers({bool isInitial = false}) async {
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
      developer.log(
        "Error fetching users: $e",
        name: "UsersRepository",
      );
      throw AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchUsers);
  }
}

final usersRepositoryProvider =
    AsyncNotifierProvider<UsersRepository, List<UsersModel>>(
  UsersRepository.new,
);

final usersSearchQueryProvider = StateProvider<String>((ref) => '');
