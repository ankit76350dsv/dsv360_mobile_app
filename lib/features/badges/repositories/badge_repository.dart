import 'dart:async';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:dsv360/features/badges/model/badge_summary.dart';
import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepository();
});

// Legacy provider aliases so existing consumers compile unchanged.
final createBadgeRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final updateBadgeRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final deleteBadgeRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final fetchBadgesRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final fetchBadgeUsersRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final fetchUserBadgesRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final assignBadgeRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));
final deleteAssignedBadgesRepositoryProvider = Provider<BadgeRepository>((ref) => ref.read(badgeRepositoryProvider));

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

// ── Static badge list (legacy) ──────────────────────────────────────────────

class AllDSVBadgesList extends AsyncNotifier<List<DSVBadge>> {
  @override
  FutureOr<List<DSVBadge>> build() async {
    return fetchAllDSVBadgesList(isInitial: true);
  }

  FutureOr<List<DSVBadge>> fetchAllDSVBadgesList({bool isInitial = false}) async {
    return [];
  }
}

final allDSVBadgesListRepositoryProvider =
    Provider<AsyncValue<List<DSVBadge>>>((ref) {
  final dsvBadges = <DSVBadge>[
    DSVBadge.fromJson({"Badge_Level": "Bronze", "Badge_Name": "BFSI", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png", "Badge_ID": "BFSI_BRZ", "ROWID": "17682000000302395"}),
    DSVBadge.fromJson({"Badge_Level": "Diamond", "Badge_Name": "BFSI", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Diamond-min.png", "Badge_ID": "BFSI_DMD", "ROWID": "17682000000302846"}),
    DSVBadge.fromJson({"Badge_Level": "Platinum", "Badge_Name": "BFSI", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png", "Badge_ID": "BFSI_PLT", "ROWID": "17682000000302849"}),
    DSVBadge.fromJson({"Badge_Level": "Titanium", "Badge_Name": "Titanium_test", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png", "Badge_ID": "Tt_test", "ROWID": "17682000000302858"}),
    DSVBadge.fromJson({"Badge_Level": "Gold", "Badge_Name": "Gold-Test", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/GOLD-min.png", "Badge_ID": "Gd-test", "ROWID": "17682000000302864"}),
    DSVBadge.fromJson({"Badge_Level": "Silver", "Badge_Name": "Silver-Test", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png", "Badge_ID": "Silver-test", "ROWID": "17682000000302867"}),
    DSVBadge.fromJson({"Badge_Level": "Silver", "Badge_Name": "Broze_Dsd", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Silver-min.png", "Badge_ID": "adsadsa", "ROWID": "17682000000302874"}),
    DSVBadge.fromJson({"Badge_Level": "Platinum", "Badge_Name": "adasdsa22", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Platinium-min.png", "Badge_ID": "Pt_Test2", "ROWID": "17682000000302877"}),
    DSVBadge.fromJson({"Badge_Level": "Bronze", "Badge_Name": "Broze_Dsd22", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png", "Badge_ID": "asdsa", "ROWID": "17682000000302883"}),
    DSVBadge.fromJson({"Badge_Level": "Titanium", "Badge_Name": "BFSI", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png", "Badge_ID": "BFSI_TITAN", "ROWID": "17682000000302976"}),
    DSVBadge.fromJson({"Badge_Level": "Bronze", "Badge_Name": "bfsi", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Bronze-min.png", "Badge_ID": "bfsi_brz", "ROWID": "17682000000310139"}),
    DSVBadge.fromJson({"Badge_Level": "Titanium", "Badge_Name": "Test_DSVBadges", "Badge_Logo": "https://dsv365-development.zohostratus.in/dsv365/DSVBadges/Titanium-min.png", "Badge_ID": "Test_001", "ROWID": "17682000000331718"}),
  ];
  return AsyncValue.data(dsvBadges);
});
