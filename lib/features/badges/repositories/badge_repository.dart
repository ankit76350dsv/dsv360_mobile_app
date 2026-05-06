import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';

class BadgeRepository {
  // ── Badge CRUD ─────────────────────────────────────────────────────────────

  Future<void> createBadge(Map<String, dynamic> body) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/badge',
      data: body,
    );
  }

  Future<void> updateBadge({
    required String rowId,
    required Map<String, dynamic> body,
  }) async {
    await ApiClient.instance.put(
      'time_entry_management_application_function/badge/$rowId',
      data: body,
    );
  }

  Future<void> deleteBadge({required String deleteId}) async {
    await ApiClient.instance.delete(
      'time_entry_management_application_function/badge/$deleteId',
    );
  }

  // ── Badge Fetch ─────────────────────────────────────────────────────────────

  Future<List<DSVBadge>> fetchAllBadgesForAssign() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/badge',
    );

    final data = response.data;
    final badgesList = (data is Map && data['data'] is List)
        ? data['data'] as List
        : (data is List ? data : <dynamic>[]);

    return badgesList
        .whereType<Map>()
        .map((e) => DSVBadge.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<BadgeSummary>> fetchAllBadgesForList() async {
    final response = await ApiClient.instance.get(
      'time_entry_management_application_function/badge/',
    );

    final data = response.data;
    List<dynamic> rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['badges'] is List) {
        rawList = data['badges'];
      } else if (data['response'] is List) {
        rawList = data['response'];
      }
    }

    return rawList
        .whereType<Map>()
        .map((e) => BadgeSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

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

  // ── Badge Assignment ────────────────────────────────────────────────────────

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

