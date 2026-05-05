import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/badges/model/assigned_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fetchUserBadgesRepositoryProvider = Provider<FetchUserBadgesRepository>((ref) {
  return FetchUserBadgesRepository();
});

class FetchUserBadgesRepository {
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
}
