import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fetchBadgeUsersRepositoryProvider = Provider<FetchBadgeUsersRepository>((ref) {
  return FetchBadgeUsersRepository();
});

class FetchBadgeUsersRepository {
  Future<List<BadgeUser>> fetchUsers() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/employee',
    );

    final data = response.data;
    final usersList = (data is Map && data['users'] is List)
        ? data['users'] as List
        : <dynamic>[];

    return usersList
        .whereType<Map>()
        .map((e) => BadgeUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
