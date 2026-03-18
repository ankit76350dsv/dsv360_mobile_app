import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgeAssignmentRepositoryProvider = Provider<BadgeAssignmentRepository>(
  (ref) {
    return BadgeAssignmentRepository();
  },
);

class BadgeAssignmentRepository {
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

  Future<List<AssignedBadge>> fetchUserBadges(String userId) async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/badge/$userId',
    );

    final data = response.data;
    final rawList = (data is Map && data['data'] is List)
        ? data['data'] as List
        : <dynamic>[];

    return rawList
        .whereType<Map>()
        .map((e) => AssignedBadge.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> assignBadge(Map<String, dynamic> payload) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/assignBadge',
      data: payload,
    );
  }

  Future<void> deleteAssignedBadges(List<String> rowIds) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/assignBadge',
      data: {'rowIDs': rowIds},
    );
  }
}
