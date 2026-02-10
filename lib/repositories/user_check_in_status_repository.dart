import 'dart:async';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/user_check_in_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatusRepository
    extends AutoDisposeFamilyAsyncNotifier<UserCheckInStatus, String> {
  @override
  FutureOr<UserCheckInStatus> build(String userId) async {
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

final userStatusRepositoryProvider = AsyncNotifierProvider.family
    .autoDispose<UserStatusRepository, UserCheckInStatus, String>(
      UserStatusRepository.new,
    );
