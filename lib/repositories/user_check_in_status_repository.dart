import 'dart:async';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/user_check_in_status.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatusRepository extends AutoDisposeAsyncNotifier<UserCheckInStatus> {
  @override
  FutureOr<UserCheckInStatus> build() async {
    final activeUser = ref.watch(activeUserRepositoryProvider);
    final userId = activeUser?.userId ?? '';
    if (userId.isEmpty) {
      throw Exception("User ID is missing.");
    }
    return fetchStatus(userId);
  }

  Future<UserCheckInStatus> fetchStatus(String userId) async {
    try {
      final response = await DioClient.instance.get(
        'time_entry_management_application_function/status/$userId',
      );
      debugPrint("Response From UserStatusRepository: $response");

      final data = response.data;
      return UserCheckInStatus.fromJson(data);
    } catch (e, st) {
      debugPrint("Error fetching UserStatus: $e");
      throw AsyncError(e, st);
    }
  }
}

final userStatusRepositoryProvider =
    AsyncNotifierProvider.autoDispose<UserStatusRepository, UserCheckInStatus>(
      UserStatusRepository.new,
    );
