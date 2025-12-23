import 'dart:async';
import 'dart:developer' as developer;

import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersRepository extends AsyncNotifier<List<UsersModel>> {
  int _start = 1;
  int _end = 10;
  bool _hasMore = true;

  final List<UsersModel> _allUsers = [];

  @override
  FutureOr<List<UsersModel>> build() async {
    // reset pagination
    _start = 1;
    _end = 10;
    _hasMore = true;
    _allUsers.clear();

    return await fetchUsers(isInitial: true);
  }

  Future<List<UsersModel>> fetchUsers({bool isInitial = false}) async {
    try {
      final response = await DioClient.instance.get(
        '/server/esd_portal_function/getUsers?start=$_start&end=$_end',
      );

      final data = response.data;
      final List<dynamic> newList = data['users'] ?? [];

      final newUsers =
          newList.map((e) => UsersModel.fromJson(e)).toList();

      if (isInitial) {
        _allUsers.clear();
      }

      _allUsers.addAll(newUsers);

      // If API returned fewer items than requested → no more data
      if (newUsers.length < (_end - _start + 1)) {
        _hasMore = false;
      }

      return _allUsers;
    } catch (e, s) {
      developer.log(
        "fetchUsers error: $e",
        stackTrace: s,
        name: "UsersRepository",
      );
      return _allUsers;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    _start = _end + 1;
    _end = _start + 9;

    await fetchUsers();

    // Important: notify UI
    state = AsyncData(List.from(_allUsers));
  }

  void clearUsers() {
    _allUsers.clear();
    _hasMore = true;
    state = const AsyncData([]);
  }
}

final usersRepositoryProvider =
    AsyncNotifierProvider<UsersRepository, List<UsersModel>>(
  UsersRepository.new,
);
